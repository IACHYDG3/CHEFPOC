resource_name :jmodule
property :owner, String, default: 'root'
property :module_name, String
property :host, String, default: '127.0.0.1'
property :offset, Integer, default: 0
property :jboss_mode, String, default: 'standalone'
property :jboss_home, String, default: '/opt/jboss/'
property :mgmtport, Integer, default: 9999
property :jdbc_loc, String
property :dep_list, String
property :jdbc_driver_name, String
property :class_name, String

action :create do 

  execute 'module-add' do
    user owner
    command jboss_home+
      '/bin/jboss-cli.sh --connect controller='+
      host+':'+
      "#{mgmtport+offset}"+
      ' --commands="module add --name='+module_name+' --resources='+jdbc_loc+' --dependencies='+dep_list+'"'
    
    not_if jboss_home+
      '/bin/jboss-cli.sh --connect controller='+
      host+':'+
      "#{mgmtport+offset}"+
      ' --commands="/subsystem=datasources:installed-drivers-list"'+
      '|grep "driver-name" |grep "\"'+jdbc_driver_name+'\""', :user=> owner
  end
  
  execute 'install-jdbc' do
    user owner
    command jboss_home+
      '/bin/jboss-cli.sh --connect controller='+
      host+':'+
      "#{mgmtport+offset}"+
      ' --commands="/subsystem=datasources/jdbc-driver='+
      jdbc_driver_name+':add(driver-name='+
      jdbc_driver_name+',driver-module-name='+
      module_name+',driver-class-name='+class_name+')"'

    not_if jboss_home+
      '/bin/jboss-cli.sh --connect controller='+
      host+':'+
      "#{mgmtport+offset}"+
      ' --commands="/subsystem=datasources:installed-drivers-list"'+
      '|grep "driver-name" |grep "\"'+jdbc_driver_name+'\""', :user=> owner
  end

end
