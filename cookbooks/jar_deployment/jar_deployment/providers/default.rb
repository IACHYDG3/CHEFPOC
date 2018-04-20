=begin
#<
 Implements jar_deployment resource.
#>
=end 

# Support whyrun
def whyrun_supported?
  true
end

def jar_name
  @new_resource.name
end

def jar_location
  @new_resource.jar_location
end

def deploy_directory
  @new_resource.deploy_directory
end

def log_directory
  @new_resource.log_directory
end

def jar_checksum
  @new_resource.jar_checksum
end

def java_version
  @new_resource.java_version
end

def jar_user
  @new_resource.jar_user
end

def jar_args
  @new_resource.jar_args
end 

# Deploy jar
action :deploy do
  resources = [] 

  # Create deploy directory
  resources << (directory deploy_directory do
    owner jar_user
    group jar_user
    mode '0755'
    recursive true
    action :create
  end)

  # Create deploy directory
  resources << (directory log_directory do
    owner jar_user
    group jar_user
    mode '0755'
    recursive true
    action :create
  end)

  resources << (remote_file "#{deploy_directory}/#{jar_name}.jar" do
    source jar_location
    owner jar_user
    group jar_user
    mode '0755'
    action :create
  end)

  template_variables = {
    name: jar_name,
    user: jar_user,
    deploy_directory: deploy_directory,
    log_directory: log_directory
  }

  unless jar_args.empty?
    args = ""

    jar_args.each do |key, value|
      args +="#{key}=#{value} "
    end

    template_variables['jar_args'] = args
  end

  # Template service script
  resources << (template "/etc/init.d/#{jar_name}" do
    source 'service.init.d.erb.rb'
    owner user
    group user
    variables template_variables
    mode '0755'
    notifies :restart, "service[#{jar_name}]", :delayed
  end)

  # Start service
  resources << (service jar_name do
    action [:enable, :start]
  end)

  res = false

  resources.each do |r|
    res ||= r.updated?
  end
  
  new_resource.updated_by_last_action(res)
end

# Delete deployed jar
action :delete do

  resources = []

  # Stop service first
  resources << (service jar_name do
    action :stop
  end)

  [
    "#{deploy_directory}/#{jar_name}.jar",
    "/etc/init.d/#{jar_name}"
  ].each do |res|
    resources << (file res do
      action :delete
    end)
  end

  res = false

  resources.each do |r|
    res ||= r.updated?
  end
  
  new_resource.updated_by_last_action(res)
end
