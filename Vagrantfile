# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.

  # Vagrantのboxを指定します。自作した理工展用のboxです。
  config.vm.box = "marmot1123/centos71-minimal"

  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  
  # IPを設定します。他のVagrant仮想マシンと衝突しないようにデフォルトから変更しました。
  # デフォルトは192.168.33.10です。
  config.vm.network "private_network", ip: "192.168.56.21"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Chefを仮想マシンにインストールします。
  # あらかじめvagrant-omnibusというプラグインを導入することが必要です。
  # $ vagrant plugin vagrant-omnibus
  # で入ります。
  config.omnibus.chef_version=:latest
  
  # Chef Zeroで./chef以下の内容を仮想マシンに適用させます。
  # あらかじめvagrant-chef-zeroというプラグインを導入する必要があります。
  # $ vagrant plugin vagrant-chef-zero
  # で入れることができます。
  # また、仮想マシンが立ち上がった状態で
  # $ vagrant provision
  # を打つことでchefリポジトリの内容をを適用させることができます。
  config.vm.provision "chef_zero" do |chef|
    chef.cookbooks_path = "./chef/cookbooks"
    chef.run_list = JSON.parse(File.read("./chef/nodes/server.json"))["run_list"]
  end
end
