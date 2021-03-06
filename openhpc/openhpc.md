Enable root:
<pre>sudo -i</pre>
Check if SELinux is enabled, if enabled disable it(find out how online):
<pre>
getenforce
</pre>
Decide what node to make the master node. For example 'node0'. Then copy the ip address of this node from hosts file. Open the file:
<pre>cat /etc/hosts</pre>
Then save the ipaddress and the name of the master node e.g 'master' to the host files by entering:
<pre>echo {master_node_ip} {name_of_master_node} >> /etc/hosts</pre>
Disable firewall:
<pre>
systemctl disable firewalld 
systemctl stop firewalld
</pre>
Then:
<pre>
yum install http://build.openhpc.community/OpenHPC:/1.3/CentOS_7/x86_64/ohpc-release-1.3-1.el7.x86_64.rpm
yum -y install ohpc-base
yum -y install ohpc-warewulf
systemctl enable ntpd.service
systemctl restart ntpd
yum -y install ohpc-slurm-server
perl -pi -e "s/ControlMachine=\S+/ControlMachine={name_of_master_node}/" /etc/slurm/slurm.conf
</pre>
Replace {sms_eth_internal} with what you get from entering:
<pre>ip a</pre>
<pre>
perl -pi -e "s/device = eth1/device = {sms_eth_internal}/" /etc/warewulf/provision.conf
perl -pi -e "s/^\s+disable\s+= yes/ disable = no/" /etc/xinetd.d/tftp
ifconfig {sms_eth_internal} {sms_ip} netmask {internal_netmask} up
systemctl restart xinetd
systemctl enable mariadb.service
systemctl restart mariadb
systemctl enable httpd.service
systemctl restart httpd

export CHROOT=/opt/ohpc/admin/images/centos7.7
wwmkchroot centos-7 $CHROOT
yum -y --installroot=$CHROOT install ohpc-base-compute
cp -p /etc/resolv.conf $CHROOT/etc/resolv.conf
yum -y --installroot=$CHROOT install ohpc-slurm-client
yum -y --installroot=$CHROOT install ntp
yum -y --installroot=$CHROOT install kernel
yum -y --installroot=$CHROOT install lmod-ohpc

wwinit database
wwinit ssh_keys
echo "${sms_ip}:/home /home nfs nfsvers=3,nodev,nosuid 0 0" >> $CHROOT/etc/fstab
echo "${sms_ip}:/opt/ohpc/pub /opt/ohpc/pub nfs nfsvers=3,nodev 0 0" >> $CHROOT/etc/fstab
echo "/home *(rw,no_subtree_check,fsid=10,no_root_squash)" >> /etc/exports
echo "/opt/ohpc/pub *(ro,no_subtree_check,fsid=11)" >> /etc/exports
exportfs -a
systemctl restart nfs-server
systemctl enable nfs-server
chroot $CHROOT systemctl enable ntpd
echo "server ${sms_ip}" >> $CHROOT/etc/ntp.conf

wwsh file import /etc/passwd
wwsh file import /etc/group
wwsh file import /etc/shadow
wwsh file import /etc/slurm/slurm.conf
wwsh file import /etc/munge/munge.key
export WW_CONF=/etc/warewulf/bootstrap.conf
echo "drivers += updates/kernel/" >> $WW_CONF
echo "drivers += overlay" >> $WW_CONF
wwbootstrap `uname -r`

wwvnfs --chroot $CHROOT
echo "GATEWAYDEV=${eth_provision}" > /tmp/network.$$
wwsh -y file import /tmp/network.$$ --name network
wwsh -y file set network --path /etc/sysconfig/network --mode=0644 --uid=0
wwsh -y node new ${c_name[i]} --ipaddr=${c_ip[i]} --hwaddr=${c_mac[i]} -D ${eth_provision}
wwsh -y provision set "${compute_regex}" --vnfs=centos7.7 --bootstrap=`uname -r` \
--files=dynamic_hosts,passwd,group,shadow,slurm.conf,munge.key,network
systemctl restart dhcpd
wwsh pxe update
</pre>
