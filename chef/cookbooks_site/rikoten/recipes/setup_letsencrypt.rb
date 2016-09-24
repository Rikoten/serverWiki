#
# letsencrypt導入
#
yum_package "letsencrypt" do
	action :install
	options '--enablerepo=epel'
end

