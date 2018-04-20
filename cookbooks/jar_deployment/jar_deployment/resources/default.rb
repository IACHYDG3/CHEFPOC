=begin
#<
This resource facilitates jar deployment.

@action deploy  Deploys jar.
@action delete Deletes deployed jar.

@section Examples

    # An example of deploying a service
    jar_deployment 'service_name' do
      deploy_directory '/opt/application'
      jar_location 'http://example.com/repo/jar/application.jar'
      jar_checksum '45hj35jk34h53j4h5k'
      jar_args {
		    '--server-port': 8080
      }
      jar_user 'root'
      action :deploy
    end

    # An example of deleting a deployed service
    jar_deployment 'service_name' do
      action :delete
    end
#>
=end

actions :deploy, :delete

default_action :deploy

#<> @attribute deploy_directory directory to deploy the jar
attribute :deploy_directory, kind_of: String, default: '/opt/application'

#<> @attribute log_directory directory to deploy the jar
attribute :log_directory, kind_of: String, default: '/var/log'

#<> @attribute jar_location location of the jar to deploy
attribute :jar_location, kind_of: String, required: false

#<> @attribute jar_checksum checksum of jar to deploy
attribute :jar_checksum, kind_of: String, required: false

#<> @attribute args runtime arguments e.g. port, application properties.
attribute :jar_args, kind_of: Hash, default: Hash.new

#<> @attribute jar_user user to deploy and run jar with
attribute :jar_user, kind_of: String
