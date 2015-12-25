#
# Cookbook Name:: rikoten
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

setup_centos
setup_bash
setup_sshd
setup_yum
setup_chrony
setup_git
setup_apache
setup_php
setup_mysql
setup_subdomain "www.local.rikoten.com" do
	path "/vagrant/repo/2015/site"
end

setup_firewalld

