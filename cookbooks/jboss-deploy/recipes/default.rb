#
# Cookbook Name:: jboss-deploy
# Recipe:: default
#


deployer 'example.war' do
	jboss_home '/opt/jboss-6.2.0'
	owner 'jboss'
	group 'jboss'
	package_url 'file:///root/example.war'
	module_name 'example.war'
	mgmtport 9999
	offset 0
	action :deploy
end
