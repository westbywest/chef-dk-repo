log_level                :info
current_dir = File.dirname(__FILE__)
node_name                "provisioner"
client_key               "#{current_dir}/client_key.pem"
validation_client_name   "validator"

# Also pick up cookbooks vendored by Berkshelf
cookbook_path	["#{ENV['HOME']}/Documents/chef-dk-repo/cookbooks",
	"#{ENV['HOME']}/Documents/chef-dk-repo/berks-cookbooks"]

# Don't bootstrap upon VM creation
knife[:skip_bootstrap]  = false

# knife-xenserver settings
knife[:xenserver_password] = "blahblahblah"
knife[:xenserver_username] = "root"
knife[:xenserver_host]     = "xenserver.hostname"
