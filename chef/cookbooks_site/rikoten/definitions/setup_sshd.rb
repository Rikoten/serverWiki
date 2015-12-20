define :setup_sshd do

	service "sshd" do
		supports :status => true, :restart => true, :reload => true
		action [:enable, :start]
	end

	# 設定ファイル生成
	template "/etc/ssh/sshd_config" do
		source "sshd_config.erb"
		mode "600"
		owner "root"
		group "root"
		notifies :reload, "service[sshd]"
		action :create
	end

end
