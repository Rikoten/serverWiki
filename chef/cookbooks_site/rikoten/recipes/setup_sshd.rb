#
# sshd設定
#
service "sshd" do
	supports :status => true, :restart => true, :reload => true
	action [:enable, :start]
end
template "/etc/ssh/sshd_config" do
	source "sshd_config.erb"
	mode "600"
	owner "root"
	group "root"
	notifies :reload, "service[sshd]"
	action :create
end

