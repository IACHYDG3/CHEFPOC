resource_name :deployer
property :file_loc, String, default: '/tmp'
property :owner, String, default: 'root'
property :group, String, default: 'root'
property :mode, String, default: '644'
property :package_url, String
property :checksum, String
property :module_name, String
property :host, String, default: '127.0.0.1'
property :offset, Integer, default: 0
property :jboss_mode, String, default: 'standalone'
property :jboss_home, String, default: '/opt/jboss/'
property :mgmtport, Integer, default: 9999
property :sub_deploy, String, default: lazy {
    jboss_mode == 'domain' ? '--server-groups=main-server-group' : ''
  }
property :sub_undeploy, String, default: lazy {
    jboss_mode == 'domain' ? '--all-relevant-server-groups' : ''
  }

action :deploy do
  
   remote_file file_loc+'/'+module_name do
     source package_url
     owner owner
     group group
     mode mode
     action :create
   end
  
   execute 'jboss-cli-deploy' do
 	user owner
 	command jboss_home+
	    '/bin/jboss-cli.sh --connect controller='+
	    host+':'+
	    "#{mgmtport+offset}"+
	    ' --commands="deploy '+
	    file_loc+'//'+
	    module_name+' '+
	    sub_deploy+'"'

        not_if jboss_home+
            '/bin/jboss-cli.sh --connect controller='+
            host+':'+
            "#{mgmtport+offset}"+
            ' --commands="deploy -l"'+
            '|grep '+module_name, :user=> owner
   end
   
end

action :undeploy do
  
   execute 'jboss-cli-undeploy' do
 	user owner
 	command jboss_home+
	    '/bin/jboss-cli.sh --connect controller='+
	    host+':'+
	    "#{mgmtport+offset}"+
	    ' --commands="undeploy '+
	    module_name+' '+
	    sub_undeploy+'"'

        only_if jboss_home+
            '/bin/jboss-cli.sh --connect controller='+
            host+':'+
            "#{mgmtport+offset}"+
            ' --commands="deploy -l"'+
            '|grep '+module_name, :user=> owner
   end
   
end
