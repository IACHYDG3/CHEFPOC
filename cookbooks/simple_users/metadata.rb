name 'simple_users'
maintainer 'Greg Konradt'
maintainer_email 'grifkon+github@gmail.com'
license 'Apache v2.0'
description 'Manages Linux (Ubuntu/CentOS) local users'
long_description 'Manages local user accounts including adding and removing them from sudoers. Usernames and other details are defined in attributes.'
version '0.1.7'

%w( ubuntu centos redhat ).each do |os|
  supports os
end

issues_url 'https://github.com/grifonas/simple_users/issues' if respond_to?(:issues_url)
source_url 'https://github.com/grifonas/simple_users' if respond_to?(:source_url)


