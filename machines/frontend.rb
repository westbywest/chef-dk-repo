require 'chef/provisioning/ssh_driver'
with_driver 'ssh'

# Recipe for frontend.hostname.com, a CentOS 6 machine.
# Note this assumes machine already provisioned and accessible via SSH.

##
# Machine frontend
machine "frontend" do
  converge true
  machine_options :transport_options => {
    'host' => 'frontend.hostname.com',
    'username' => 'chef',
    'ssh_options' => {
      'keys' => ["#{ENV['HOME']}/Documents/chef-repo/.chef/chef_user.pem"],
    }
  }
  #This machine's environment
  chef_environment 'production'

  # Roles and recipes
  role 'webserver'

  #notifies :create, 'machine[dbserver]'
  #notifies :converge, 'machine[appserver]'  
end

