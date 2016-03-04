#
# ホスト名設定
#

template "/etc/hostname" do
	# ホスト名設定
	source "hostname.erb"
	mode "644"
	owner "root"
	group "root"
	action :create
end
script "set_host_name" do
	# ホスト名設定コマンド実行
	interpreter "bash"
	user "root"
	cwd "/tmp"
	code "hostname #{node[:core][:fqdn]}"
end

