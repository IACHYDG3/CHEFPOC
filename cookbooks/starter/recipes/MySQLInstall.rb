yum_repository 'mysql55-community' do
  mirrorlist 'https://repo.mysql.com/yum/mysql-5.5-community/el/$releasever/$basearch/'
  description ''
  enabled true
  gpgcheck true
end
yum_package 'mysql-community-server' do
  action :install
end
