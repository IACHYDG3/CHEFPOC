# This is a Chef recipe file. It can be used to specify resources which will
# apply configuration to a server.
# For more information, see the documentation: https://docs.chef.io/essentials_cookbook_recipes.html
powershell_script 'RunCode' do
  guard_interpreter :powershell_script
  code "& \"C:/powershelltest/test1.ps1\""
  not_if "$false"
end

