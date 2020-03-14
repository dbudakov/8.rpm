#!/bin/bash
	INSTALL(){
	 yum install -y\
	 redhat-lsb-core \
	 gcc \
	 wget \
	 rpmdevtools \
	 rpm-build \
	 createrepo \
 	 yum-utils
	}

	NGX(){
	 src0=https://nginx.org/packages/centos/7/SRPMS/nginx-1.14.1-1.el7_4.ngx.src.rpm
	 op0=/root/nginx-1.14.1-1.el7_4.ngx.src.rpm	 
	 wget $src0 -O $op0
	 rpm -i $op0
	}

	OPENSSL(){
	 src2=https://www.openssl.org/source/latest.tar.gz
	 op2=/root/latest.tar.gz
	 op3=/root/
	 wget $src2 -O $op2
	 tar -xvf $op2 -C $op3
	}

	INS_DEP(){
	 src4=/root/rpmbuild/SPECS/nginx.spec
	 yum-builddep $src4 
	}
	
	CP_SPEC(){
	 #вставить файл https://github.com/dbudakov/8.rpm/blob/master/homework/SPECfile
	 src5=/vagrant/nginx_conf.spec
	 op5=/root/rpmbuild/SPECS/nginx.spec
	 cp -f $src5 $op5
	}

	BUILD(){
	 src5=/root/rpmbuild/SPECS/nginx.spec
	 rpmbuild -bb $src5
	}

	install_custom_nginx(){
	 #вставить файл https://github.com/dbudakov/8.rpm/blob/master/default_nginx.conf	 
	 src6=/root/rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm
	 src7=/vagrant/default_nginx.conf
	 op7=/etc/nginx/conf.d/default.conf
	 yum localinstall -y $src6
	 cp  -f $src7 $op7
	 nginx -s reload
	}

	create_repo(){
	src8=/root/rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm 	
	src9=http://www.percona.com/downloads/percona-release/redhat/0.1-6/percona-release-0.1-6.noa rch.rpm 	
	op8=/usr/share/nginx/html/repo/
	op9=/usr/share/nginx/html/repo/percona-release-0.1-6.noarch.rpm
		(){	
		 mkdir $op8
		 cp $src8 $op8
		}
		(){
		 wget $src9 -O $op9
		 createrepo $op8
		}		
	}
	
	create_repo(){
	#вставить файл /vagrant/custom.repo, ещё не создан 
	#https://github.com/dbudakov/8.rpm/blob/master/homework/custom.repo	 
	 src10=/vagrant/custom.repo 
	 op=10=/etc/yum.repos.d/custom_rpm.repo	
	 cp $src10 $op10 
	}

	chek_list(){
	yum-config-manager --disable base --disable [elrepo]
	#yum list  --disablerepo=[epel]| grep custom_rpm >/vagrant/result_repo.list
	#yum provides nginx percona --disablerepo=[epel]>>/vagrant/result_repo.list
	}
