$startDate = Get-Date -format "yyyy-MM-dd"
$startTimeonly=Get-Date -format "HH:mm:ss:fff"
$updateSession = new-object -com "Microsoft.Update.Session"
$logFilePath= "C:\EZ_Automation\EZPatch\Log_EZPatch_"+$startDate+"_"+$startTimeonly.Replace(':','')+".txt"
"[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) + "End:Create update session object"| out-file $logFilePath -Append

$criteria = "IsInstalled=0 and DeploymentAction='Installation' or IsPresent=1 and DeploymentAction='Uninstallation' or IsInstalled=1 and DeploymentAction='Installation' and RebootRequired=1 or IsInstalled=0 and DeploymentAction='Uninstallation' and RebootRequired=1"
"[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) + "Search Criteria:$criteria"| out-file $logFilePath -Append

"[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) + "Start:Create update service manager object"| out-file $logFilePath -Append
$objServiceManager = New-Object -ComObject "Microsoft.Update.ServiceManager"
"[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) + "End:Create update service manager object"| out-file $logFilePath -Append

"[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) + "Start:Create update searcher object"| out-file $logFilePath -Append
$objSearcher = $updateSession.CreateUpdateSearcher()
"[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) + "End:Create update searcher object"| out-file $logFilePath -Append

"[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) + "Start:Check whether WSUS service is registered on the server"| out-file $logFilePath -Append
$IsUpdateServiceRegistered = $false
$updateService="Windows Update"
$updateServiceName=""
 $ServiceID="3da21691-e39d-4da6-8a4b-b43877bcb1b7"
 $ServerSelection=3
 $AddServiceFlag=4
    switch ($updateService) 
    { 
        "WSUS" {$ServiceID="3da21691-e39d-4da6-8a4b-b43877bcb1b7";$ServerSelection=1;$updateServiceName="Windows Server Update Service";break} 
        "Windows Update"{$ServiceID="9482f4b4-e343-43b6-b170-9a65bc822c77";$ServerSelection=2;$updateServiceName="Windows Update";break} 
        "MU"{$ServiceID="7971f918-a847-4430-9279-4a52d1efe18d";$ServerSelection=3;$AddServiceFlag=2;$updateServiceName="Microsoft Update";break} 
    
    }
Foreach ($objsvc in $objServiceManager.Services) 
{
	If($objsvc.Name -eq $updateServiceName)
	{
		$objSearcher.ServerSelection = $ServerSelection
		$objSearcher.ServiceID = $ServiceID
		$IsUpdateServiceRegistered = $true
		Break
	}
}


if(!$IsUpdateServiceRegistered)
{
     "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) + "Trying to register WSUS service on server"| out-file $logFilePath -Append
    $authorizationCabPath=""
    try
    {
        $objService = $objServiceManager.AddService2($ServiceID,$AddServiceFlag,$authorizationCabPath)
        $objService.PSTypeNames.Clear()
        $objService.PSTypeNames.Add('PSWindowsUpdate.WUServiceManager')
        $objSearcher.ServerSelection = $ServerSelection
        $objSearcher.ServiceID = $objService.ServiceID
        $IsUpdateServiceRegistered=$true
    }
    catch
    {
        "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) + $_ | out-file $logFilePath -Append
    }
    if($IsUpdateServiceRegistered)
    {
        "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) + "WSUS service is registered on the server now, Registration Status:$IsUpdateServiceRegistered"| out-file $logFilePath -Append
    }
    else
    {
        "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) + "WSUS service registration failed on server"| out-file $logFilePath -Append
    }
   
}
else
{
"[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) + "End:WSUS service is already registered on the server"| out-file $logFilePath -Append
}

if($IsUpdateServiceRegistered -eq $false)
{
    "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) + "Patching Failed: due to service registration failure on the server, refer http://inetexplorer.mvps.org/archive/windows_update_codes.htm"| out-file $logFilePath -Append
}
else
{
"[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) + "Start:Searching for updates as per criteria"| out-file $logFilePath -Append
$searchStatus=$false

try
{
    $startSearchDate=Get-Date
    $objResults=$objSearcher.Search($criteria);
    $endSearchDate=Get-Date
    $searchTime=NEW-TIMESPAN -Start $startSearchDate -End $endSearchDate
    $searchStatus=$true;
    }
catch
{
     "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) + $_.Exception.Message | out-file $logFilePath -Append
    If($_ -match "HRESULT: 0x80072EE2")
	{
        "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) + "This server may not be able to connect to Windows Update server" | out-file $logFilePath -Append		
	}
    elseIf($_ -match "HRESULT: 0x8024402F")
	{
		"[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) + "Internet may not be enabled on this server" | out-file $logFilePath -Append		
       
	}
}

#$RootCategoriesString="Critical Updates,Security Updates,Update Rollups,Updates"
$RootCategoriesString="Critical Updates,Security Updates,Update Rollups,Updates"
[String[]]$RootCategories=$RootCategoriesString.Split(',')
$SeverityString="Critical,Important,Moderate"
[String[]]$Severity=$SeverityString.Split(',')
$InstallKBString=""
[String[]]$InstallKBs=$InstallKBString.Split(',')
$ExcludeKBString=""
[String[]]$ExcludeKBs=$ExcludeKBString.Split(',')
$NOSQLTitle=""
if($searchStatus)
{
"[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) + "End:Search, $($objResults.Updates.Count) updates found, search duration is $($searchTime.Hours)hours $($searchTime.Minutes)minutes $($searchTime.Seconds)seconds"| out-file $logFilePath -Append
if($objResults.Updates.Count -gt 0)
{
    $UpdateCollection = New-Object -ComObject Microsoft.Update.UpdateColl
    if(($InstallKBString -ne "") -and ($InstallKBs.Count -gt 0))
    {
     foreach($update in $objResults.Updates)
     {        			
		If(($update.KBArticleIDs -ne "") -and ($InstallKBs -match $update.KBArticleIDs))
		{
			$UpdateCollection.Add($update)				
		}
     }
    }
    else
    {
    $RootCatUpdateCollection = New-Object -ComObject Microsoft.Update.UpdateColl
            foreach($RootCategory in $RootCategories)
            {
                switch ($RootCategory) 
                { 
                    "Critical Updates" {$CatID = 0} 
                    "Definition Updates"{$CatID = 1} 
                    "Drivers"{$CatID = 2} 
                    "Feature Packs"{$CatID = 3} 
                    "Security Updates"{$CatID = 4} 
                    "Service Packs"{$CatID = 5} 
                    "Tools"{$CatID = 6} 
                    "Update Rollups"{$CatID = 7} 
                    "Updates"{$CatID = 8} 
                    "Upgrades"{$CatID = 9} 
                    "Microsoft"{$CatID = 10} 
                }

                $objResults.RootCategories.item($CatID).Updates | foreach{
                    $RootCatUpdateCollection.Add($_)
                }
           
            }
            foreach($rUpdate in $RootCatUpdateCollection)
            {
                If(($rUpdate.KBArticleIDs -ne "") -and ($ExcludeKBString -ne "") -and ($ExcludeKBs -match $rUpdate.KBArticleIDs))
		        {
			        Continue;				
		        }
                If(($Severity -notcontains [String]$rUpdate.MsrcSeverity) -and ([String]$rUpdate.MsrcSeverity -ne ""))
				{
					Continue;
				}
                if($NOSQLTitle)
                {
                    If($rUpdate.Title -match $NOSQLTitle)
					{
						Continue;	
					} 
				}
                $UpdateCollection.Add($rUpdate)
            }
            
        } 
    "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) +"Start:Create Downloader object"| out-file $logFilePath -Append
    $downloader = $updateSession.CreateUpdateDownloader() 
    "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) +"End:Create Downloader object"| out-file $logFilePath -Append
     
     $downloader.Updates = $UpdateCollection
     
    if ($downloader.Updates.Count -eq "0")
    {
       if(($InstallKBString -ne "") -and ($InstallKBs.Count -gt 0))
       {
        "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) +"Patching Completed: No updates found that match the specified KBs $InstallKBString through WSUS service"| out-file $logFilePath -Append
       }
       else
       {
        "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) +"Patching Completed: No pending updates found in specified rootcategories:'$([string]::join(", ", $RootCategories))'"| out-file $logFilePath -Append
       }
    }
    else
    {
        "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) +"$($downloader.Updates.Count) updates found in specified rootcategories:'$([string]::join(", ", $RootCategories))'"| out-file $logFilePath -Append
        $resultcode= @{0="Not Started"; 1="In Progress"; 2="Succeeded"; 3="Succeeded With Errors"; 4="Failed" ; 5="Aborted" } 
         
        "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) +"Start:Download"| out-file $logFilePath -Append
        $downloadStatus=$false
        try
        {  
        $startDownloadDate=Get-Date
        $Result= $downloader.Download() 
        $downloadStatus=$true
        $endDownloadDate=Get-Date
        $downloadTime=NEW-TIMESPAN -Start $startDownloadDate -End $endDownloadDate
        }
        catch
        {
        "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) +"Download Failed with the error:"+ $_.Exception.Message| out-file $logFilePath -Append
        }
        if($downloadStatus)
        {
        if (($Result.Hresult -eq 0) -and (($result.resultCode -eq 2) -or ($result.resultCode -eq 3)) ) 
        { 
        
            $updatesToInstall = New-object -com "Microsoft.Update.UpdateColl" 
            $downloader.Updates | where {$_.isdownloaded} | foreach-Object {$updatesToInstall.Add($_) | out-null}  
               
             "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) +"End:Downloaded with resultcode as $($resultcode[$result.resultCode]),$($updatesToInstall.Count) updates downloaded, download duration is $($downloadTime.Hours)hours $($downloadTime.Minutes)minutes $($downloadTime.Seconds)seconds"| out-file $logFilePath -Append
              
             "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) +"Start:Create update installer object"| out-file $logFilePath -Append                                                                                                                                             
             $installer = $updateSession.CreateUpdateInstaller()  
             "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) +"End:Create update installer object"| out-file $logFilePath -Append 
                 
            $installer.Updates = $updatesToInstall 
                  
            "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) +"Start:Install"| out-file $logFilePath -Append 
              $installStatus=$false    
              try
              { 
              $startInstallDate=Get-Date
              $installationResult = $installer.Install()
              $installStatus=$true 
              $endInstallDate=Get-Date
              $installTime=NEW-TIMESPAN -Start $startInstallDate 
	      End $endInstallDate
              }
              catch
              {
              "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) +"Install Failed with the error:"+ $_.Exception.Message| out-file $logFilePath -Append
              }
              if($installStatus)
              {
              "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) +"End:Install,Install duration is $($installTime.Hours)hours $($installTime.Minutes)minutes $($installTime.Seconds)seconds"| out-file $logFilePath -Append 
             $counter=-1 
             $IsRebootRequired=$false
             $rebootString="reboot not required"
             $failedUpdatesCount=0    
             $succeededUpdatesCount=0 
             $suceededWithErrorsCount=0
             "<Start: Update History>"| out-file $logFilePath -Append
             foreach($installedUpdate in $installer.updates)
             {
                $counter++;
                $strUpdateInfo=""
                $rebootRequired=$installationResult.GetUpdateResult($counter).RebootRequired
                $resultcodeofupdate=$installationResult.GetUpdateResult($counter).resultCode
                $strUpdateInfo+="`r`nTitle:" + $installedUpdate.Title +"`r`n" + "Patching Status:" + $ResultCode[$resultcodeofupdate] +"`r`nReboot Required:"+$rebootRequired
                
                if($rebootRequired)
                {
                    $IsRebootRequired=$true
                    $rebootString="reboot required"
                }
                switch ($resultcodeofupdate) 
                { 
                    0 {break} 
                    1 {break} 
                    2 {$succeededUpdatesCount++; break} 
                    3 {$suceededWithErrorsCount++; break} 
                    4 {$failedUpdatesCount++; break} 
                    5 {$failedUpdatesCount++; break} 
                }

                $strUpdateInfo|out-file $logFilePath -Append               
             }
             "<End: Update History>"| out-file $logFilePath -Append

             "
[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) +"Total Updates:$($installer.updates.Count) Succeed:$succeededUpdatesCount  Failed:$failedUpdatesCount  Succeeded with errors:$suceededWithErrorsCount 
"| out-file $logFilePath -Append

             if($failedUpdatesCount -eq $installer.updates.Count)
             {
                "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) +"Patching Failed:Install Failed, refer http://inetexplorer.mvps.org/archive/windows_update_codes.htm"| out-file $logFilePath -Append
             }
             elseif($suceededWithErrorsCount -or $failedUpdatesCount -gt 0)
             {
                 "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) +"Patching Completed with errors,$rebootString"| out-file $logFilePath -Append
             }
             else
             {
                 "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) +"Patching Completed sucessfully,$rebootString"| out-file $logFilePath -Append
             }
             }
             else
             {
             "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) +"Patching Failed:Install Failed,refer http://inetexplorer.mvps.org/archive/windows_update_codes.htm"| out-file $logFilePath -Append    
             }                      
           
        }
        else
        {
        "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) +"Patching Failed:Download Failed with result code as $($resultcode[$result.resultcode]), refer http://inetexplorer.mvps.org/archive/windows_update_codes.htm"| out-file $logFilePath -Append    
        }
        }
        else
        {
        "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) +"Patching Failed:Download Failed, refer http://inetexplorer.mvps.org/archive/windows_update_codes.htm"| out-file $logFilePath -Append    
        }
    }
}
else
{
"[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) +"Patching Completed: No pending updates returned as part of search operation"| out-file $logFilePath -Append
}
}
else
{
"[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) + "End:Search, Failed to search for updates"| out-file $logFilePath -Append
"[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) + "Patching Failed: Search Failed with errors, refer http://inetexplorer.mvps.org/archive/windows_update_codes.htm"| out-file $logFilePath -Append

}

}
$searchString=$startDate+"	"+$startTimeonly
$log = Get-Content $env:windir\windowsupdate.log | ConvertTo-Xml -NoTypeInformation 
$result = $log.Objects.Object | where {$_ -gt $searchString}
"
##########################################   LOGS from WINDOWSUPDATE.Log file    #########################################"| out-file $logFilePath -Append
$result | out-file $logFilePath -Append 

if($IsRebootRequired)
{
Shutdown -r -t 0
}
