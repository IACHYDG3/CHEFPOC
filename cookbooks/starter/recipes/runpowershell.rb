powershell_script 'RunCode' do
  cwd 'C:\Users\Administrators'
  code <<-EOH
  & C:\chef\cache\cookbooks\starter\files\default\WSUS.ps1
  EOH
  elevated True
end
