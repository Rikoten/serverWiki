#
# apache(Webサーバー)導入・設定
#
yum_package "httpd" do
	action :install
end

yum_package "openssl" do
	action :install
end

yum_package "mod_ssl" do
	action :install
end

template "/etc/httpd/conf/httpd.conf" do
	source "httpd/httpd.conf.erb"
	mode "644"
	owner "root"
	group "root"
	notifies :restart, "service[httpd]"
	action :create
end

cookbook_file "/var/www/html/index.php" do
	source "www/html/index.php"
	mode "644"
	owner "apache"
	group "apache"
	action :create
end

service "httpd" do
	action [:enable]
end

#
# ポート開放
#
firewalld_service 'http' do
	action :add
	zone   'public'
end

firewalld_service 'https' do
	action :add
	zone   'public'
end

