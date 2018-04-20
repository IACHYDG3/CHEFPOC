resource_name :datasource
property :owner, String, default: 'root'
property :host, String, default: '127.0.0.1'
property :offset, Integer, default: 0
property :jboss_mode, String, default: 'standalone'
property :jboss_home, String, default: '/opt/jboss/'
property :mgmtport, Integer, default: 9999
property :jdbc_driver_name, String
property :username, String
property :password, String
property :dt_name, String
property :connection_url, String
property :jndi_name, String

action :create do
  
  execute 'data-source' do
    user owner
    command jboss_home+
      '/bin/jboss-cli.sh --connect controller='+
      host+':'+
      "#{mgmtport+offset}"+
      ' --commands="data-source add --jndi-name=java:/'+
      jndi_name+' --name='+dt_name+' --connection-url='+
      connection_url+' --driver-name='+jdbc_driver_name+
      ' --user-name='+username+' --password='+password+' --enabled=true"'
    
    not_if jboss_home+
      '/bin/jboss-cli.sh --connect controller='+
      host+':'+
      "#{mgmtport+offset}"+
      ' --commands="/subsystem=datasources:read-resource(recursive=true)"'+
      '|grep "jndi-name" |grep "'+jndi_name+'"', :user=> owner
  end
  
end

