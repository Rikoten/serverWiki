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
setup_user "hikalium" do
	password "$1$E5n1H2ql$2WTJjgxTLuTMb1AflY9O1/"
	rsakey "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/VWeaWtwrPRCDeJRYbL909iVzOPjspwWTdKk6W/Kqv7i/dxDXiTkNLlwsjwpi+Qw0M1TOSc1TGyaj2cS8w2X0LmMHJ15pqxlwn3qz9NlPH6CusX3yAWAO9V9iftU1o3ZfZzAwGAPTU0XqqQjROkYlydPDw3LdfoEGxNrjwH1rw148dSlsy4lAjiH3BfXijBEHrHvFqFB67Ws7lQca9dbp1I6We/W4JHazI2FytDSqMqnmMuZD2rm5Jp3mN5Z+KpKm6BBQpwIBWYmD5Fa1o/V5Ch7V27FwSUSxnZY8lyBPDen6LM35ZKTBuxU6wUsxXc2SbIXFwibljKvas8y6euuT hikalium@test.rikoten.com"
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
yum_package "yum-plugin-fastestmirror" do
	action :install
end

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

# rootパスワード設定
passForMySQL="RikotenMySQL"
result = shell_out('MYSQL_PWD="'+passForMySQL+'" mysql -u root -N -e ""')
unless result.exitstatus == 0 then
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
			mysql -u root <<< "UPDATE mysql.user SET authentication_string=PASSWORD('#{passForMySQL}') WHERE User='root';\nFLUSH PRIVILEGES;\n"
		EOC
		returns [0]
		retries 3
	end
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
# 期限切れになっている場合はそれを解消する
bash 'apply_mysql_root_pass' do
	user 'mysql'
	code <<-EOC
		MYSQL_PWD=#{passForMySQL} mysql -u root -N -e "SET PASSWORD='#{passForMySQL}';" --connect-expired-password
	EOC
	returns [0]
	retries 3
end
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
	source "postfix/main.cf.erb"
	mode "644"
	owner "root"
	group "root"
	notifies :restart, "service[postfix]"
	action :create
end
template "/etc/postfix/master.cf" do
	source "postfix/master.cf.erb"
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
	source "dovecot/10-mail.conf.erb"
	mode "644"
	owner "root"
	group "root"
	notifies :restart, "service[dovecot]"
	action :create
end
template "/etc/dovecot/conf.d/10-auth.conf" do
	source "dovecot/10-auth.conf.erb"
	mode "644"
	owner "root"
	group "root"
	notifies :restart, "service[dovecot]"
	action :create
end
template "/etc/dovecot/conf.d/10-ssl.conf" do
	source "dovecot/10-ssl.conf.erb"
	mode "644"
	owner "root"
	group "root"
	notifies :restart, "service[dovecot]"
	action :create
end
template "/etc/dovecot/conf.d/15-mailboxes.conf" do
	source "dovecot/15-mailboxes.conf.erb"
	mode "644"
	owner "root"
	group "root"
	notifies :restart, "service[dovecot]"
	action :create
end
template "/etc/dovecot.conf" do
	source "dovecot/dovecot.conf.erb"
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
		tar xzf /vagrant/chef/cookbooks_site/rikoten/files/default/squirrelmail-webmail-1.4.22-ja.tar.gz
		mv squirrelmail-webmail-1.4.22-ja webmail
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
# mailman 導入・設定
#
yum_package "mailman" do
	action :install
end
directory '/var/www/ml' do
	owner 'apache'
	group 'apache'
	mode '0755'
	action :create
end
cookbook_file '/var/www/ml/index.php' do
	source 'www/ml/index.php'
	owner 'apache'
	group 'apache'
	mode '0644'
	action :create
end
template "/etc/httpd/conf.d/mailman.conf" do
	source "httpd/mailman.conf.erb"
	mode "644"
	owner "root"
	group "root"
	notifies :restart, "service[httpd]"
	action :create
end
template "/etc/mailman/mm_cfg.py" do
	source "mm_cfg.py.erb"
	mode "644"
	owner "root"
	group "mailman"
	#notifies :restart, "service[httpd]"
	action :create
end
#service "mailman" do
#	action [:enable, :start]
#end

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
firewalld_port '465/tcp' do
	# SMTPS
	action :add
	zone   'public'
end
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
