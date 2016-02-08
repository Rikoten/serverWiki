define :setup_webmail do

	yum_package "postfix" do
		action :install
	end

	yum_package "cyrus-sasl" do
		action :install
	end

	yum_package "dovecot" do
		action :install
	end


	# 設定ファイル生成
	template "/etc/postfix/main.cf" do
		source "postfix_main.cf.erb"
		mode "644"
		owner "root"
		group "root"
		notifies :restart, "service[postfix]"
		action :create
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
	# SquirrelMail
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

	# 自動起動
	service "postfix" do
		action [:enable]
	end

	service "dovecot" do
		action [:enable, :restart]
	end

	# インストール
	#yum_package "roundcubemail" do
	#	action :install
	#	options '--enablerepo=epel'
	#end
	# index.html仮設置
	#template "/var/www/html/index.php" do
	#	source "index.php.erb"
	#	mode "644"
	#	owner "apache"
	#	group "apache"
	#	action :create
	#end

	# 自動起動
	#service "httpd" do
	#	action [:enable]
	#end
end
