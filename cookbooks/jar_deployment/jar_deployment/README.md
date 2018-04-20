# Description

Installs/Configures jar_deployment

# Requirements

## Platform:

* Centos (>= 6.6)

## Cookbooks:

* java (~> 1.29)

# Attributes

* `node['java']['install_flavor']` - Java family to install. Defaults to `openjdk`.
* `node['java']['jdk_version']` - Java version to install. Defaults to `8`.
* `node['java']['openjdk']['accept_oracle_download_terms']` - Accept oracle download terms/conditions. Defaults to `true`.

# Recipes

* jar_deployment::default

# Resources

* [jar_deployment](#jar_deployment) - This resource facilitates jar deployment.

## jar_deployment

This resource facilitates jar deployment.

### Actions

- deploy: Deploys jar. Default action.
- delete: Deletes deployed jar.

### Attribute Parameters

- deploy_directory: directory to deploy the jar Defaults to <code>"/opt/application"</code>.
- log_directory: directory to deploy the jar Defaults to <code>"/var/log"</code>.
- jar_location: location of the jar to deploy
- jar_checksum: checksum of jar to deploy
- jar_args:  Defaults to <code>{"--server-port"=>8080}</code>.
- jar_user: user to deploy and run jar with Defaults to <code>"root"</code>.

### Examples

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

# License and Maintainer

Maintainer:: robertnorthard (<robertnorthard@googlemail.com>)

License:: All rights reserved
