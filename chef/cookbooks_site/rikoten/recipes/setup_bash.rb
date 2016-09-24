#
# bashrc生成
#
template "/etc/bashrc" do
	source "bashrc.erb"
	mode "644"
	owner "root"
	group "root"
	action :create
end

