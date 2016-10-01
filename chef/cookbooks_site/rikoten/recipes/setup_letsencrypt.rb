#
# letsencrypt導入
#
yum_package "certbot" do
	action :install
	options '--enablerepo=epel'
end

