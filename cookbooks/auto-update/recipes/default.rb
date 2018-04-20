#
# Cookbook Name:: auto-update
# Authors:: Sandor Acs <acs.sandor@mta.sztaki.hu>, Mark Gergely <gergely.mark@mta.sztaki.hu>
# Copyright 2014, MTA SZTAKI
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

if node['auto-update']['enabled'] then
  case node['platform_family']
  when 'debian'
    update_command = 'apt-get upgrade --force-yes --yes'
    #APT reciepe handles the "apt-get update" procedure
    include_recipe 'apt'
    # Unattended-upgrades package may cause conflicts
    package 'unattended-upgrades' do
      action :purge
    end
  when 'rhel'
    update_command = 'yum update -q -y'
  end

  execute 'periodic-update' do
    command update_command
    ignore_failure true  
    only_if do
      !File.exists?("#{node['auto-update']['stamp_file']}") ||   
      File.mtime("#{node['auto-update']['stamp_file']}") < Time.now - node['auto-update']['interval']  
    end
    notifies :touch, "file[#{node['auto-update']['stamp_file']}]" , :immediately
  end

  file "#{node['auto-update']['stamp_file']}" do
      action :nothing
  end

end