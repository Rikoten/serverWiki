#
# UNIXユーザー追加
#
adminList = []
udList = data_bag('users')
udList.each do |i|
	u = data_bag_item('users', i)
	setup_user u['id'] do
		userdata u
	end
	if u['admin'] then
		adminList << u['id']
	end
end

group "wheel" do
	action [:modify]
	members adminList
end

