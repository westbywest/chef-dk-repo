#
# Cookbook Name:: demo-cookbook
# Recipe:: webserver
#

# Include default recipe (if not pulled in automatically)
include_recipe 'demo-cookbook::default'

# Apache may want the EPEL repo
include_recipe 'yum-epel'

# Allow incoming port 80
case node['platform_family']
when 'rhel'
  simple_iptables_rule "http" do
    rule [ "--proto tcp --dport 80"]
    jump "ACCEPT"
  end
end

# Now include apache cookbooks
include_recipe 'apache2'

# Default vhost
web_app "default_vhost" do
  server_name 'webserver.hostname.com'
  server_aliases [node['fqdn']]
  docroot "/var/www/html"
  cookbook 'apache2'
end

