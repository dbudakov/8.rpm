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
	 tar -xf $op2 -C $op3
	}

	INS_DEP(){
	 src4=/root/rpmbuild/SPECS/nginx.spec
	 yum-builddep $src4 -y 
	}
	
	CP_SPEC(){
	src5=/vagrant/SPECfile
	op5=/root/rpmbuild/SPECS/nginx.spec
	cp -f $src5 $op5
	i=$(ls -l /root/|awk '/openssl/{print $9}')
	sed -i 's/openssl-1.1.1a/'$i'/' /root/rpmbuild/SPECS/nginx.spec
	}

	BUILD(){
	 src5=/root/rpmbuild/SPECS/nginx.spec
	 rpmbuild -bb $src5
	}

	install_custom_nginx(){
	src6=/root/rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm
	op6=/etc/nginx/conf.d/default.conf
	yum localinstall -y $src6
	N=11; sed -e $N"s/^/autoindex on;\n/" -i $op6
	nginx -s reload
	systemctl start nginx
	}

	create_repo(){
	src8=/root/rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm 	
	src9="http://www.percona.com/downloads/percona-release/redhat/0.1-6/percona-release-0.1-6.noarch.rpm"
	op8=/usr/share/nginx/html/repo/
	op9=/usr/share/nginx/html/repo/percona-release-0.1-6.noarch.rpm
		repo(){	
		 mkdir $op8
		 cp $src8 $op8 -f
		}
		percn(){
		 wget $src9 -O $op9
		 createrepo $op8
		}
	repo
	percn		
	}
	
attach_repo(){
op10=/etc/yum.repos.d/custom.repo
cat > $op10 << EOF
[custom]
name=custom
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF
}

	chek_list(){
	yum-config-manager --disable base >/dev/null
	yum list | grep custom > /vagrant/result_repo.list
	yum provides nginx >>/vagrant/result_repo.list
	}
MAIN(){
	INSTALL
	NGX
	OPENSSL
	INS_DEP
	CP_SPEC
	BUILD
	install_custom_nginx
	create_repo
	attach_repo
	chek_list
}
MAIN
