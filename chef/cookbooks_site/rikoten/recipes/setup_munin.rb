#
# munin(サーバー状態監視)導入・設定
#

yum_package "munin" do
	action :install
	options "--enablerepo=epel"
end
yum_package "munin-node" do
	action :install
	options "--enablerepo=epel"
end
directory '/var/www/html/munin' do
	action :delete
	recursive true
end
directory '/var/www/admin/munin' do
	owner 'munin'
	group 'munin'
	mode '0755'
	action :create
end
template "/etc/httpd/conf.d/munin.conf" do
	source "httpd/munin.conf.erb"
	mode "644"
	owner "apache"
	group "apache"
	notifies :restart, "service[httpd]"
	action :create
end
template "/etc/munin/munin.conf" do
	source "munin.conf.erb"
	mode "644"
	owner "root"
	group "root"
	action :create
end
service "munin-node" do
	action [:enable, :start]
end

