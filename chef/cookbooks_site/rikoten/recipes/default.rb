
#
# firewalldインストール
#
yum_package "firewalld" do
	action :install
end
service "firewalld" do
	action [:enable, :start]
end

#
# サーバー基本設定
#
template "/etc/hostname" do
	# ホスト名設定
	source "hostname.erb"
	mode "644"
	owner "root"
	group "root"
	action :create
end
script "set_host_name" do
	# ホスト名設定コマンド実行
	interpreter "bash"
	user "root"
	cwd "/tmp"
	code "hostname #{node[:fqdn]}"
end

#
# ツールパッケージの導入
#
yum_package "wget" do
	action :install
end
yum_package "mailx" do
	action :install
end
yum_package "git" do
	action :install
end

#
# bashrc生成
#
template "/etc/bashrc" do
	source "bashrc.erb"
	mode "644"
	owner "root"
	group "root"
	action :create
end

#
# vimの設定
#
yum_package "vim-enhanced" do
	action :install
end
template "/etc/vimrc" do
	source "vimrc.erb"
	mode "644"
	owner "root"
	group "root"
	action :create
end

#
# UNIXユーザー追加
#
user "hikalium" do
	password "$1$E5n1H2ql$2WTJjgxTLuTMb1AflY9O1/"
	supports :manage_home => true
	action :create
end
directory '/home/hikalium/.ssh' do
        owner 'hikalium'
        group 'hikalium'
        mode '0755'
        action :create
end
file '/home/hikalium/.ssh/authorized_keys' do
	content 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/VWeaWtwrPRCDeJRYbL909iVzOPjspwWTdKk6W/Kqv7i/dxDXiTkNLlwsjwpi+Qw0M1TOSc1TGyaj2cS8w2X0LmMHJ15pqxlwn3qz9NlPH6CusX3yAWAO9V9iftU1o3ZfZzAwGAPTU0XqqQjROkYlydPDw3LdfoEGxNrjwH1rw148dSlsy4lAjiH3BfXijBEHrHvFqFB67Ws7lQca9dbp1I6We/W4JHazI2FytDSqMqnmMuZD2rm5Jp3mN5Z+KpKm6BBQpwIBWYmD5Fa1o/V5Ch7V27FwSUSxnZY8lyBPDen6LM35ZKTBuxU6wUsxXc2SbIXFwibljKvas8y6euuT hikalium@test.rikoten.com'
	mode '0644'
	owner 'hikalium'
	group 'hikalium'
end
group "wheel" do
	action [:modify]
	members ["hikalium"]
end

#
# sshd設定
#
service "sshd" do
	supports :status => true, :restart => true, :reload => true
	action [:enable, :start]
end
template "/etc/ssh/sshd_config" do
	source "sshd_config.erb"
	mode "600"
	owner "root"
	group "root"
	notifies :reload, "service[sshd]"
	action :create
end

#
# yumの設定と各種リポジトリ追加
#
bash 'add_repo_mysql' do
	user 'root'
	code <<-EOC
		rpm -ivh http://dev.mysql.com/get/mysql57-community-release-el7-7.noarch.rpm
		sed -i -e "s/enabled *= *1/enabled=0/g" /etc/yum.repos.d/mysql-community.repo
	EOC
	creates "/etc/yum.repos.d/mysql-community.repo"
end
yum_package "epel-release" do
	action :install
end
bash 'config_repo_epel' do
	user 'root'
	code <<-EOC
		sed -i -e "s/enabled *= *1/enabled=0/g" /etc/yum.repos.d/epel.repo
	EOC
end
bash 'add_repo_remi' do
	user 'root'
	cwd '/root'
	code <<-EOC
		wget http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
		rpm -Uvh remi-release-7.rpm
		sed -i -e "s/enabled *= *1/enabled=0/g" /etc/yum.repos.d/remi.repo
		sed -i -e "s/enabled *= *1/enabled=0/g" /etc/yum.repos.d/remi-safe.repo
	EOC
	creates "/etc/yum.repos.d/remi.repo"
end

#
# chrony(時刻同期)導入・設定
#
yum_package "chrony" do
	action :install
end
service "chronyd" do
	action [:enable]
end
template "/etc/chrony.conf" do
	source "chrony.conf.erb"
	mode "644"
	owner "root"
	group "root"
	notifies :restart, "service[chronyd]"
	action :create
end

#
# letsencrypt導入
#
yum_package "letsencrypt" do
	action :install
	options '--enablerepo=epel'
end

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
	source "httpd.conf.erb"
	mode "644"
	owner "root"
	group "root"
	notifies :restart, "service[httpd]"
	action :create
end
template "/var/www/html/index.php" do
	source "index.php.erb"
	mode "644"
	owner "apache"
	group "apache"
	action :create
end
service "httpd" do
	action [:enable]
end

#
# php導入・設定
#
pkgs = [
	"php70-php",
	"php70-php-devel",
	"php70-php-mbstring",
]
pkgs.each do |pkg|
	yum_package pkg do
		action :install
		options '--enablerepo=remi,remi-php70'
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

#
# mysql導入・設定
#
yum_package "mysql-community-server" do
	action :install
	options "--enablerepo=mysql57-community"
end
service "mysqld" do
	action [:enable]
end
template "/etc/my.cnf" do
	source "my.cnf.erb"
	mode "644"
	owner "root"
	group "root"
	notifies :restart, "service[mysqld]", :immediately
	action :create
	variables({
		:c_opt => "skip-grant-tables\nskip-networking",
	})
end
# rootパスワードを変更
bash 'set_mysql_root_pass' do
	user 'mysql'
	code <<-EOC
		mysql -u root <<< "UPDATE mysql.user SET authentication_string=PASSWORD('rikotenMySQL') WHERE User='root';\nFLUSH PRIVILEGES;\n"
	EOC
	returns [0]
	retries 3
end
# 設定ファイルを通常モードに書き換え
template "/etc/my.cnf" do
	source "my.cnf.erb"
	mode "644"
	owner "root"
	group "root"
	notifies :restart, "service[mysqld]", :immediately
	action :create
	variables({
		:c_opt => "",
	})
end

#
# サブドメインのVirtualHost設定
#
setup_subdomain "www.local.rikoten.com" do
	path "/vagrant/repo/2015/site"
end
setup_subdomain "circle.local.rikoten.com" do
	path "/vagrant/repo/site2016welcome"
end

#
# Postfix（メールサーバー）
#
yum_package "postfix" do
	action :install
end
service "postfix" do
	action [:enable]
end
template "/etc/postfix/main.cf" do
	source "postfix_main.cf.erb"
	mode "644"
	owner "root"
	group "root"
	notifies :restart, "service[postfix]"
	action :create
end

#
# Dovecot(POP/IMAPサーバー)導入・設定
#
yum_package "dovecot" do
	action :install
end
service "dovecot" do
	action [:enable, :restart]
end
yum_package "cyrus-sasl" do
	action :install
end
yum_package "cyrus-sasl-plain" do
	action :install
end
template "/etc/dovecot/conf.d/10-mail.conf" do
	source "dovecot_10-mail.conf.erb"
	mode "644"
	owner "root"
	group "root"
	notifies :restart, "service[dovecot]"
	action :create
end
template "/etc/dovecot/conf.d/10-auth.conf" do
	source "dovecot_10-auth.conf.erb"
	mode "644"
	owner "root"
	group "root"
	notifies :restart, "service[dovecot]"
	action :create
end
template "/etc/dovecot/conf.d/10-ssl.conf" do
	source "dovecot_10-ssl.conf.erb"
	mode "644"
	owner "root"
	group "root"
	notifies :restart, "service[dovecot]"
	action :create
end
template "/etc/dovecot/conf.d/15-mailboxes.conf" do
	source "dovecot_15-mailboxes.conf.erb"
	mode "644"
	owner "root"
	group "root"
	notifies :restart, "service[dovecot]"
	action :create
end
template "/etc/dovecot.conf" do
	source "dovecot.conf.erb"
	mode "644"
	owner "root"
	group "root"
	notifies :restart, "service[dovecot]"
	action :create
end

#
# SquirrelMail（Webメール）導入・設定
#
bash 'extract_sqmail' do
	cwd "/var/www/html"
	user "root"
	group "root"
	code <<-EOH
		tar xzf /vagrant/chef/cookbooks_site/rikoten/files/default/squirrelmail-webmail-1.4.22.tar.gz
		mv squirrelmail-webmail-1.4.22 webmail
		chown -R apache:apache webmail
	EOH
	not_if { ::File.exists?("/var/www/html/webmail") }
end
template "/var/www/html/webmail/config/config.php" do
	source "squirrel_config.php.erb"
	mode "755"
	owner "apache"
	group "apache"
	#notifies :restart, "service[dovecot]"
	action :create
end
directory '/var/local/squirrelmail' do
	owner 'root'
	group 'root'
	mode '0755'
	action :create
end
directory '/var/local/squirrelmail/data' do
	owner 'apache'
	group 'apache'
	mode '0755'
	action :create
end
cookbook_file '/var/www/html/webmail/images/logo01.png' do
	source 'logo01.png'
	owner 'apache'
	group 'apache'
	mode '0600'
	action :create
end

#
# firewalld設定
#
firewalld_service 'http' do
	action :add
	zone   'public'
end
firewalld_service 'https' do
	action :add
	zone   'public'
end
#firewalld_port '143/tcp' do
#	# IMAP
#	action :add
#	zone   'public'
#end
firewalld_service 'smtp' do
	action :add
	zone   'public'
end

#
# 各種サービスに設定を反映
#
service "httpd" do
	action [:restart]
end
