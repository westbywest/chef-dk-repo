#
# Cookbook Name:: demo-cookbook
# Recipe:: default
#

# Add users and auth keys, add to wheel group for sudo privileges
include_recipe 'users'
users_manage "wheel" do
  data_bag "users"
  group_name "wheel"
  group_id 10
end

# ntp will enable time sync with default setings
include_recipe 'ntp'
include_recipe 'vim'
# simple_iptables will set firewall to all ACCEPT unless otherwise specified

# Also load simple_iptables::redhat on RHEL/CentOS nodes
# ref: https://github.com/rtkwlf/cookbook-simple-iptables#redhatrb-recipe
case node['platform_family']
when 'rhel'
  include_recipe 'simple_iptables::redhat'

  # Allow incoming port 22
  simple_iptables_rule "http" do
    rule [ "--proto tcp --dport 22"]
    jump "ACCEPT"
  end
end


