#
# vimの設定
#
yum_package "vim-enhanced" do
	action :install
end
template "/etc/vimrc" do
	source "vimrc.erb"
	mode "644"
	owner "root"
	group "root"
	action :create
end
