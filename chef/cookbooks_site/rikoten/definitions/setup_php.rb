define :setup_php do
	# yumパッケージ名を指定
	pkgs = [
		"php",
		"php-devel",
		"php-mbstring",
	]

	# インストール
	pkgs.each do |pkg|
		yum_package pkg do
			action :install
			options '--enablerepo=remi,remi-php70'
			version '7.0.2-1.el7.remi'
		end
	end

	# 設定ファイル生成
	template "/etc/php.ini" do
		source "php.ini.erb"
		mode "644"
		owner "root"
		group "root"
		notifies :restart, "service[httpd]"
		action :create
	end

end
