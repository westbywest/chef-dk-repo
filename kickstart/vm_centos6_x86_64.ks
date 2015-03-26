###############################################################
# Kickstart for CentOS v6 64bit
###############################################################

# Note that manual installations have automatically generated kickstart file
# saved to /root/anaconda-ks.cfg

###############################################################
# installation location & options
###############################################################
bootloader --location=mbr --driveorder=xvda --append="crashkernel=auto console=hvc0 rhgb quiet"
text
url --url=http://mirror.centos.org/centos/6/os/x86_64/
repo --name="CentOS"  --baseurl=http://mirror.centos.org/centos/6/os/x86_64/ --cost=100

###############################################################
# partitioning
###############################################################

# This seems to be need to so that kickstart doesn't stall on partitioning
zerombr
clearpart --initlabel
autopart

###############################################################
# network configuration
###############################################################

# Enable eth0 (public interface)
network --onboot yes --device eth0 --bootproto dhcp --noipv6
network --onboot no --device eth1 --bootproto dhcp --noipv6
network --onboot no --device eth2 --bootproto dhcp --noipv6
network --onboot no --device eth3 --bootproto dhcp --noipv6

firewall --service=ssh
#firewall --enabled --http --ftp --port=https:tcp --port=ipp:tcp
#firewall --disabled

###############################################################
# environment 
###############################################################
lang en_US.UTF-8
keyboard us
timezone --utc America/Chicago

###############################################################
# misc
###############################################################
reboot					# reboot automatically when done
install					# instead of "upgrade"

###############################################################
# Security
###############################################################
authconfig --enableshadow --passalgo=sha512
# sha512 crypted password for root
rootpw  --iscrypted $6$123456789ABCDEF0$/Alh5ix0tx1ErOPGlJ1NU8VCSr29Dlj2q.180NdLf5m/myQIo4HRByvjwSZFVDg7.z3l.PBvF/15qqRhMl49X1

# TODO: Note that disabling SELinux here doesn't appear to propagate to /etc/selinux/config.
# Revisit if SELinux poses a problem.
#selinux --enforcing
#selinux --permissive
selinux --disabled

###############################################################
# Users
###############################################################
# Add chef user with sha512 crypted password
user --name=chef --iscrypted --password=$6$123456789ABCDEF0$/Alh5ix0tx1ErOPGlJ1NU8VCSr29Dlj2q.180NdLf5m/myQIo4HRByvjwSZFVDg7.z3l.PBvF/15qqRhMl49X1

# Generate sha512 salts with python (replacing 16_CHARACTER_SALT_HERE with 16 chars of random data):
# echo 'import crypt,getpass; print crypt.crypt(getpass.getpass(), "$6$16_CHARACTER_SALT_HERE")' | python -

###############################################################
# Software
###############################################################
%packages --nobase
@core

wget
bind-utils
sysstat
ntp
ntpdate
nscd
openssh-clients
bc
tmpwatch
sysstat
nano

%end

%post
###############################################################
#
# Post Script - the following script runs on the newly
# installed machine, immediately after installation
#
###############################################################

# turn on required services
chkconfig ntpd on

# install EPEL 6 repo
wget http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm -ivh epel-release-6-8.noarch.rpm

# Populate authorized_keys for chef user, set permissions
mkdir /home/chef/.ssh
cat > /home/chef/.ssh/authorized_keys <<AUTHKEYS
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAvTdzLIoEjDa8Z39BTe3m+IpPTOrXapXHMjiO0ipmJq6RjnZ1NEulndG/kKP95WkZVBLJA27dXd7kbRxRA756FqAE8I0WNTdQvBrrSj8utOFQ/KyrkuHlSRGZVoQUth/pQDhWDjYWppLNqRTwNuvOpeqKe5jbS5TiuYVQpXIByouDT7xOtl/QL8wWCbRNboMYgkUV0chdb1xJQ8BqAld1qrKk3O8LTevyy+gIGup8wew5BTtFdCZ4jaowshB2nBE8dZtb55a3a7hiW8/6SIEFilEoMAXUMCXCRIRU6Vyona8tRCq2VbJy9oqIBwPOaDjVttCuVtsSN866twsS3MWJoQ== chef@localhost
AUTHKEYS
chown -R chef.chef /home/chef/.ssh
chmod 700 /home/chef/.ssh
chmod 600 /home/chef/.ssh/authorized_keys

# Add chef to wheel group
/usr/sbin/usermod -a -G wheel chef

# Disable root SSH login
sed -i "s/#PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config

# Disable GSSAPI authentication, slows down SSH connections w/ DNS lookup timeouts
sed -i "s/^GSSAPIAuthentication yes/GSSAPIAuthentication no/g" /etc/ssh/sshd_config

# Disable tty requirement for sudo
sed -i -e 's/\s*Defaults\s*requiretty$/#Defaults requiretty/' /etc/sudoers

# Enable nopasswd sudo for wheel group
sed -i 's/^#\s*\(%wheel\s*ALL=(ALL)\s*NOPASSWD:\s*ALL\)/\1/' /etc/sudoers

# Update all packages
yum -y update

# Install chef client via omnibus installer
curl -L https://www.chef.io/chef/install.sh | bash

%end
