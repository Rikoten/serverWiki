#
# Digest認証ファイルを配置
#
directory '/etc/httpd/digestfile' do
	owner 'root'
	group 'root'
	mode '0755'
	action :create
end
cookbook_file '/etc/httpd/digestfile/admin' do
	source 'admin_htdigest'
	owner 'root'
	group 'root'
	mode '0644'
	action :create
end
cookbook_file '/etc/httpd/digestfile/ml' do
	source 'ml_htdigest'
	owner 'root'
	group 'root'
	mode '0644'
	action :create
end

#
# サブドメインのVirtualHost設定
#
setup_subdomain "www" do
	path "/vagrant/repo/current/www"
end
setup_subdomain "circle" do
	path "/vagrant/repo/current/circle"
end
# admin
setup_subdomain "admin" do
	path "/var/www/admin"
	requireSSL true
end
template "/var/www/admin/.htaccess" do
	source "httpd/digest_auth_htaccess.erb"
	mode "644"
	owner "root"
	group "root"
	action :create
	variables({
		:authName => "admin.rikoten.com",
		:authUserFile => "/etc/httpd/digestfile/admin"
	})
end
cookbook_file '/var/www/admin/index.php' do
	source 'www/admin/index.php'
	owner 'apache'
	group 'apache'
	mode '0644'
	action :create
end
cookbook_file '/var/www/admin/phpinfo.php' do
	source 'www/admin/phpinfo.php'
	owner 'apache'
	group 'apache'
	mode '0644'
	action :create
end
