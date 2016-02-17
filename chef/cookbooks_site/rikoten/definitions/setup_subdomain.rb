define :setup_subdomain, :path => "/var/www/html", :requireSSL => false do
	# エラー抑制のため存在しない場合は空のディレクトリを作成
	directory params[:path] do
		owner 'apache'
		group 'apache'
		mode '0755'
		recursive true
		action :create
	end
	fqdnStr = params[:name] + '.' + node[:core][:fqdn] 
	# 設定ファイル生成
	srcName = "subdomain.conf.erb"
	if params[:requireSSL] then
		srcName = "subdomain_sslonly.conf.erb"
	end
	template "/etc/httpd/conf.d/#{fqdnStr}.conf" do
		source srcName
		mode "644"
		owner "root"
		group "root"
		action :create
		variables({
			:path => params[:path],
			:domain => fqdnStr,
			:requireSSL => params[:requireSSL]
		})
	end

end
