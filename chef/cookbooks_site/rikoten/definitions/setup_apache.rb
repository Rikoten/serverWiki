define :setup_apache do
	# インストール
	yum_package "httpd" do
		action :install
	end

	# 設定ファイル生成
	template "/etc/httpd/conf/httpd.conf" do
		source "httpd.conf.erb"
		mode "644"
		owner "root"
		group "root"
		notifies :restart, "service[httpd]"
		action :create
	end

	# index.html仮設置
	template "/var/www/html/index.php" do
		source "index.php.erb"
		mode "644"
		owner "apache"
		group "apache"
		action :create
	end

	# 自動起動
	service "httpd" do
		action [:enable]
	end
end
