define :setup_user, :name => "", :password => "", :rsakey => "" do
	user params[:name] do
		password params[:password]
		supports :manage_home => true
		action :create
	end
	directory "/home/#{params[:name]}/.ssh" do
			owner params[:name]
			group params[:name]
			mode '0755'
			action :create
	end
	file "/home/#{params[:name]}/.ssh/authorized_keys" do
		content params[:rsakey]
		mode '0644'
		owner params[:name]
		group params[:name]
	end
end
