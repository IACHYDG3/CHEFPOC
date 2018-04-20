#
# Cookbook Name:: learn_chef_iis
# Recipe:: default
#
# Copyright (C) 2014
#
#
#
powershell_script 'Install IIS' do
  code 'Add-WindowsFeature Web-Server'
  guard_interpreter :powershell_script
  not_if "(Get-WindowsFeature -Name Web-Server).InstallState -eq 'Installed'"
end


powershell_script 'Install IIS Management Console' do
  code 'Add-WindowsFeature Web-Mgmt-Console'
  guard_interpreter :powershell_script
  not_if "$MgmtConsoleState = (Get-WindowsFeature Web-Mgmt-Console).InstallState
                 If ($MgmtConsoleState -eq 'Available')
                 {
                         echo $false
                 }
                 Elseif ($MgmtConsoleState -eq 'Installed')
                 {
                         echo $true
                 }"
end 

service 'w3svc' do
  action [:enable, :start]
end

template 'c:\inetpub\wwwroot\Default.htm' do
  source 'Default.htm.erb'
end
