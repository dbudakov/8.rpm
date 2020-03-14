#!/bin/bash
yum install -y redhat-lsb-core gcc wget rpmdevtools rpm-build createrepo yum-utils
wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.14.1-1.el7_4.ngx.src.rpm -O /root/nginx-1.14.1-1.el7_4.ngx.src.rpm
rpm -i /root/nginx-1.14.1-1.el7_4.ngx.src.rpm
wget https://www.openssl.org/source/latest.tar.gz -O /root/latest.tar.gz
tar -xvf latest.tar.gz -C /root/
yum-builddep rpmbuild/SPECS/nginx.spec

cp -f /vagrant/nginx_conf.spec /root/rpmbuild/SPECS/nginx.spec
 - - -
вставить файл https://github.com/dbudakov/8.rpm/blob/master/homework/SPECfile
 - - -
rpmbuild -bb rpmbuild/SPECS/nginx.spec
yum localinstall -y rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm


mkdir /usr/share/nginx/html/repo
cp rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm /usr/share/nginx/html/repo/
wget http://www.percona.com/downloads/percona-release/redhat/0.1-6/percona-release-0.1-6.noa rch.rpm -O /usr/share/nginx/html/repo/percona-release-0.1-6.noarch.rpm
createrepo /usr/share/nginx/html/repo/

cp /vagrant/default_nginx.conf /etc/nginx/conf.d/default.conf
- - -
вставить файл https://github.com/dbudakov/8.rpm/blob/master/default_nginx.conf
 - - -
nginx -s reload
cp /vagrant/custom.repo /etc/yum.repos.d/custom_rpm.repo
----
вставить файл /vagrant/custom.repo, ещё не создан
----
yum-config-manager --disable base --disable [elrepo]
https://github.com/dbudakov/8.rpm/blob/master/homework/custom.repo
 - - -
#yum list  --disablerepo=[epel]| grep custom_rpm >/vagrant/result_repo.list
#yum provides nginx percona --disablerepo=[epel]>>/vagrant/result_repo.list
