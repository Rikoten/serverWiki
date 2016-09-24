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
	cwd "/var/www"
	user "root"
	group "root"
	code <<-EOH
		tar xzf /vagrant/chef/cookbooks_site/rikoten/files/default/squirrelmail-webmail-1.4.22-ja.tar.gz
		mv squirrelmail-webmail-1.4.22-ja webmail
		chown -R apache:apache webmail
	EOH
	not_if { ::File.exists?("/var/www/webmail") }
end
template "/var/www/webmail/config/config.php" do
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
cookbook_file '/var/www/webmail/images/logo01.png' do
	source 'logo01.png'
	owner 'apache'
	group 'apache'
	mode '0600'
	action :create
end

setup_subdomain "webmail" do
	path "/var/www/webmail"
	requireSSL true
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
template "/var/www/ml/.htaccess" do
	source "httpd/digest_auth_htaccess.erb"
	mode "644"
	owner "root"
	group "root"
	action :create
	variables({
		:authName => "ml.rikoten.com",
		:authUserFile => "/etc/httpd/digestfile/ml"
	})
end
template "/usr/lib/mailman/cgi-bin/.htaccess" do
	source "httpd/digest_auth_htaccess.erb"
	mode "644"
	owner "root"
	group "root"
	action :create
	variables({
		:authName => "ml.rikoten.com",
		:authUserFile => "/etc/httpd/digestfile/ml"
	})
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
# ポート開放
#

firewalld_port '465/tcp' do
	# SMTPS
	action :add
	zone   'public'
end

firewalld_service 'smtp' do
	action :add
	zone   'public'
end
