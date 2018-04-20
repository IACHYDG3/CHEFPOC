powershell_script 'RunCode' do
  cwd 'C:\Users\Administrators'
  code <<-EOH
  & C:\powershelltest\test.ps1
  EOH
  elevated True
end
