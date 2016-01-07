define :setup_centos do

	# ホスト名設定
	template "/etc/hostname" do
		source "hostname.erb"
		mode "644"
		owner "root"
		group "root"
		action :create
	end

	# ホスト名設定コマンド実行
	script "set_host_name" do
		interpreter "bash"
		user "root"
		cwd "/tmp"
		code "hostname #{node[:fqdn]}"
	end

	# wget
	yum_package "wget" do
		action :install
	end

end
