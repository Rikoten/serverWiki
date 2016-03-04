#
# php導入・設定
#
pkgs = [
	"php70-php",
	"php70-php-devel",
	"php70-php-mbstring",
	"php70-php-pdo",
	"php70-php-mysqlnd"
]
pkgs.each do |pkg|
	yum_package pkg do
		action :install
		options '--enablerepo=remi'
	end
end
template "/etc/php.ini" do
	source "php.ini.erb"
	mode "644"
	owner "root"
	group "root"
	notifies :restart, "service[httpd]"
	action :create
end

