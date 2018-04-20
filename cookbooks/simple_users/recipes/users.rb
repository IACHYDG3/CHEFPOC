#
# Cookbook Name:: simple_users
# Recipe:: users
#
# Greg Konradt. Dec. 2016

node["simple_users"]["users"].each do |groupname|  
  case groupname['myAction']
  when 'create'  
    doThis = 'create'
  when 'remove'
    doThis = 'nothing'
  end
  group "#{groupname['name']}" do
    action doThis    
  end  
end


node["simple_users"]["users"].each do |myUser|  
  user "#{myUser['fullName']}" do
    username myUser['name']    
    gid myUser['name']
  	password myUser['passHash']
  	shell '/bin/bash'  	
  	home "/home/#{myUser['name']}"
  	manage_home true
    action myUser['myAction']
  end
end

node["simple_users"]["users"].each do |myUser|
  case myUser['myAction']
  when 'create'  
    doThis = 'create'
  when 'remove'
    doThis = 'delete'
  end
  
  directory "/home/#{myUser['name']}/.ssh/" do
    recursive true
    action doThis
  end
end

node["simple_users"]["users"].each do |myUser|
  case myUser['myAction']
  when 'create'  
    doThis = 'create'
  when 'remove'
    doThis = 'nothing'
  end
  
  file "/home/#{myUser['name']}/.ssh/authorized_keys" do
    mode '600'
    owner myUser['name']
    group myUser['name']
    content myUser['sshPubKey']
    action doThis
  end
end



node["simple_users"]["users"].each do |myUser|  
  case node['platform']
  when 'ubuntu'
    sudoersGroup = 'sudo'
  when 'centos', 'redhat'
    sudoersGroup = 'wheel'
  end
  group "#{sudoersGroup}" do
    action :modify
    append true
    case myUser['sudo']
    when 'yes'
      members myUser['name']  
    when 'no'
      excluded_members myUser['name']  
    end    
  end
end

