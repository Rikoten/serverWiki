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
