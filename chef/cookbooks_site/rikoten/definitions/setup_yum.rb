define :setup_yum do

	bash 'add_repo_mysql' do
		user 'root'
		code <<-EOC
			rpm -ivh http://dev.mysql.com/get/mysql57-community-release-el7-7.noarch.rpm
			sed -i -e "s/enabled *= *1/enabled=0/g" /etc/yum.repos.d/mysql-community.repo
		EOC
		creates "/etc/yum.repos.d/mysql-community.repo"
	end


end
