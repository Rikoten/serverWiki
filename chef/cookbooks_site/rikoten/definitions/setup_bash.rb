define :setup_bash do

	# 設定ファイル生成
	template "/etc/bashrc" do
		source "bashrc.erb"
		mode "644"
		owner "root"
		group "root"
		action :create
	end

end
