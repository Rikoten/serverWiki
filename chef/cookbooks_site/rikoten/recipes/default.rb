include_recipe	"selinux::disabled"
include_recipe	"rikoten::setup_firewalld"
include_recipe	"rikoten::setup_hostname"
include_recipe	"rikoten::setup_tools"
include_recipe	"rikoten::setup_bash"
include_recipe	"rikoten::setup_vim"
include_recipe	"rikoten::setup_users"
include_recipe	"rikoten::setup_sshd"
include_recipe	"rikoten::setup_yum"
include_recipe	"rikoten::setup_chrony"
include_recipe	"rikoten::setup_letsencrypt"
include_recipe	"rikoten::setup_httpd"
include_recipe	"rikoten::setup_php"
include_recipe	"rikoten::setup_mysql"
include_recipe	"rikoten::setup_virtualhosts"
include_recipe	"rikoten::setup_munin"
