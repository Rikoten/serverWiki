define :setup_subdomain, :path => "/var/www/html" do
	# エラー抑制のため存在しない場合は空のディレクトリを作成
	directory params[:path] do
		owner 'apache'
		group 'apache'
		mode '0755'
		recursive true
		action :create
	end

	# 設定ファイル生成
	template "/etc/httpd/conf.d/#{params[:name]}.conf" do
		source "subdomain.conf.erb"
		mode "644"
		owner "root"
		group "root"
		action :create
		variables({
			:path => params[:path],
			:domain => params[:name]
		})
	end

end
