define :setup_apache do
  # インストール
  yum_package "httpd" do
    action :install
  end
  # 初期セットアップ
  #template "/etc/httpd/conf/httpd.conf" do
  #  source "httpd.conf.erb"
  #end
  # 自動起動
  service "httpd" do
    action [:enable]
  end
end
