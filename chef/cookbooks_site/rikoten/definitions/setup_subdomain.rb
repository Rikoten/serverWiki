define :setup_subdomain, :path => "/var/www/html" do

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
