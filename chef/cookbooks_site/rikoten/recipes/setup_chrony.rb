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

