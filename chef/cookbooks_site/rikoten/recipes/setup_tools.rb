#
# ツールパッケージの導入
#

yum_package "wget" do
	action :install
end

yum_package "mailx" do
	action :install
end

yum_package "git" do
	action :install
end

yum_package "unzip" do
	action :install
end

include_recipe "nodejs"

