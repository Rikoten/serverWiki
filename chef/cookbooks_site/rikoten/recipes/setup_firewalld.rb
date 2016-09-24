#
# firewalldインストール
#

yum_package "firewalld" do
	action :install
end

service "firewalld" do
	action [:enable, :start]
end

