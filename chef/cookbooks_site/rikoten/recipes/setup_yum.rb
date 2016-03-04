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

