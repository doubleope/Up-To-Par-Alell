#!/bin/sh
yum install openssl openssl-devel pam-devel numactl numactl-devel hwloc hwloc-devel lua lua-devel readline-devel rrdtool-devel ncurses-devel man2html libibmad libibumad -y
mkdir /nfs
cd /nfs
wget https://download.schedmd.com/slurm/slurm-20.02.1.tar.bz2
yum install perl-devel perl-CPAN
rpmbuild -ta slurm-20.02.1.tar.bz2
cd /root/rpmbuild/RPMS/x86_64  
mkdir /nfs/slurm-rpms   
cp -a . /nfs/slurm-rpms  

yum --nogpgcheck localinstall slurm-20.02.1-1.el7.x86_64.rpm slurm-libpmi-20.02.1-1.el7.x86_64.rpm slurm-slurmctld-20.02.1-1.el7.x86_64.rpm slurm-contribs-20.02.1-1.el7.x86_64.rpm slurm-openlava-20.02.1-1.el7.x86_64.rpm slurm-slurmd-20.02.1-1.el7.x86_64.rpm slurm-devel-20.02.1-1.el7.x86_64.rpm slurm-pam_slurm-20.02.1-1.el7.x86_64.rpm slurm-slurmdbd-20.02.1-1.el7.x86_64.rpm slurm-example-configs-20.02.1-1.el7.x86_64.rpm slurm-perlapi-20.02.1-1.el7.x86_64.rpm slurm-torque-20.02.1-1.el7.x86_64.rpm

cd /etc/slurm
wget https://raw.githubusercontent.com/doubleope/Up-To-Par-Alell/master/slurm/slurm.conf 
mkdir /var/spool/slurmctld
chown slurm: /var/spool/slurmctld
chmod 755 /var/spool/slurmctld
touch /var/log/slurmctld.log
chown slurm: /var/log/slurmctld.log
touch /var/log/slurm_jobacct.log /var/log/slurm_jobcomp.log
chown slurm: /var/log/slurm_jobacct.log /var/log/slurm_jobcomp.log
