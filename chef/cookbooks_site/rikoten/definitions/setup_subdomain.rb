define :setup_subdomain, :path => "/var/www/html", :requireSSL => false do
	# エラー抑制のため存在しない場合は空のディレクトリを作成
	directory params[:path] do
		owner 'apache'
		group 'apache'
		mode '0755'
		recursive true
		action :create
		ignore_failure true
		not_if { File.exists?(params[:path]) }
	end
	#fqdnStr = params[:name] + '.' + node[:core][:fqdn] 
	fqdnStr = node[:vhost_fqdn][params[:name]]
	# 設定ファイル生成
	srcName = "httpd/subdomain.conf.erb"
	if params[:requireSSL] then
		srcName = "httpd/subdomain_sslonly.conf.erb"
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
		notifies :restart, "service[httpd]"
	end

end
