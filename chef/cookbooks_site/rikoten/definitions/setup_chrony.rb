define :setup_chrony do
	# インストール
	yum_package "chrony" do
		action :install
	end

	# サービス有効化
	service "chronyd" do
		action [:enable]
	end

	# 設定ファイル生成
	template "/etc/chrony.conf" do
		source "chrony.conf.erb"
		mode "644"
		owner "root"
		group "root"
		notifies :restart, "service[chronyd]"
		action :create
	end

end
