define :setup_mysql do
	# インストール
	yum_package "mysql-community-server" do
		action :install
		options "--enablerepo=mysql57-community"
	end

	# 自動起動を設定
	service "mysqld" do
		action [:stop, :enable]
	end

	# 設定ファイルを配置
	template "/etc/my.cnf" do
		source "my.cnf.erb"
		mode "644"
		owner "root"
		group "root"
		notifies :start, "service[mysqld]"
		action :create
		variables({
			:c_opt => "skip-grant-tables\nskip-networking",
		})
	end

	# 一度起動
	service "mysqld" do
		action [:start]
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
		notifies :start, "service[mysqld]"
		action :create
		variables({
			:c_opt => "",
		})
	end

	# 通常起動する
	service "mysqld" do
		action [:start]
	end

end
