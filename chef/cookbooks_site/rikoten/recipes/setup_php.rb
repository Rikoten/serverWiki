#
# php導入・設定
#

yum_package "gd-last" do
	action :install
	options '--enablerepo=remi'
end

pkgs = [
	"php",
	"php-cli",
	"php-devel",
	"php-mbstring",
	"php-pdo",
	"php-mysqlnd",
	"php-xml",
	"php-imap",
	"php-mcrypt",
	"php-gd"
]
pkgs.each do |pkg|
	yum_package pkg do
		action :install
		options '--enablerepo=remi-php70,atomic'
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

cookbook_file "/root/composer-setup.php" do
	source "composer-setup.php"
	mode "644"
	owner "root"
	group "root"
	action :create
end

script "install-composer" do
	# ホスト名設定コマンド実行
	interpreter "bash"
	user "root"
	cwd "/root"
	code "php composer-setup.php --install-dir=/bin --filename=composer"
end

