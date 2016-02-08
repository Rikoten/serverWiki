define :setup_user do
	user "hikalium" do
		password "$1$E5n1H2ql$2WTJjgxTLuTMb1AflY9O1/"
		supports :manage_home => true
		action :create
	end
	group "wheel" do
		action [:modify]
		members ["hikalium"]
	end
end
