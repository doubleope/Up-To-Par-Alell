#!/bin/sh

export MUNGEUSER=991
groupadd -g $MUNGEUSER munge
useradd  -m -c "MUNGE Uid 'N' Gid Emporium" -d /var/lib/munge -u $MUNGEUSER -g munge  -s /sbin/nologin munge
export SLURMUSER=992
groupadd -g $SLURMUSER slurm
useradd  -m -c "SLURM workload manager" -d /var/lib/slurm -u $SLURMUSER -g slurm  -s /bin/bash slurm

yum install epel-release
yum install munge munge-libs munge-devel -y

chown -R munge: /etc/munge/ /var/log/munge/
chmod 0700 /etc/munge/ /var/log/munge/

systemctl enable munge
systemctl start munge

yum install openssl openssl-devel pam-devel numactl numactl-devel hwloc hwloc-devel lua lua-devel readline-devel rrdtool-devel ncurses-devel man2html libibmad libibumad -y
mkdir /nfs
cd /nfs
wget https://download.schedmd.com/slurm/slurm-20.02.1.tar.bz2
yum install perl-devel perl-CPAN
yum install rpm-build
rpmbuild -ta slurm-20.02.1.tar.bz2
cd /root/rpmbuild/RPMS/x86_64  
mkdir /nfs/slurm-rpms   
cp -a . /nfs/slurm-rpms  

yum --nogpgcheck localinstall slurm-20.02.1-1.el7.x86_64.rpm slurm-libpmi-20.02.1-1.el7.x86_64.rpm slurm-slurmctld-20.02.1-1.el7.x86_64.rpm slurm-contribs-20.02.1-1.el7.x86_64.rpm slurm-openlava-20.02.1-1.el7.x86_64.rpm slurm-slurmd-20.02.1-1.el7.x86_64.rpm slurm-devel-20.02.1-1.el7.x86_64.rpm slurm-pam_slurm-20.02.1-1.el7.x86_64.rpm slurm-slurmdbd-20.02.1-1.el7.x86_64.rpm slurm-example-configs-20.02.1-1.el7.x86_64.rpm slurm-perlapi-20.02.1-1.el7.x86_64.rpm slurm-torque-20.02.1-1.el7.x86_64.rpm
cd /etc/slurm
wget https://raw.githubusercontent.com/doubleope/Up-To-Par-Alell/master/slurm/slurm.conf 
mkdir /var/spool/slurmd
chown slurm: /var/spool/slurmd
chmod 755 /var/spool/slurmd
touch /var/log/slurmd.log
chown slurm: /var/log/slurmd.log

slurmd -C

systemctl stop firewalld
systemctl disable firewalld

yum install ntp -y
chkconfig ntpd on
ntpdate pool.ntp.org
systemctl start ntpd

systemctl enable slurmd.service
systemctl start slurmd.service
systemctl status slurmd.service
