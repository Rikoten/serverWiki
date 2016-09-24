define :setup_user, :name => "", :userdata => {} do
	log params[:userdata]['locked'].to_s do
	end
	if params[:userdata]['locked'] then	
		user params[:name] do
			password params[:userdata]['password']
			supports :manage_home => true
			action [:create, :lock]
		end
	else
		user params[:name] do
			password params[:userdata]['password']
			supports :manage_home => true
			action [:create, :unlock]
		end
	end
	directory "/home/#{params[:name]}/.ssh" do
			owner params[:name]
			group params[:name]
			mode '0755'
			action :create
	end
	if params[:userdata]['locked'] then	
		file "/home/#{params[:name]}/.ssh/authorized_keys" do
			content ""
			mode '0644'
			owner params[:name]
			group params[:name]
		end
	else
		file "/home/#{params[:name]}/.ssh/authorized_keys" do
			content params[:userdata]['rsakey']
			mode '0644'
			owner params[:name]
			group params[:name]
		end
	end
end
