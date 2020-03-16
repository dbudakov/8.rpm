### Домашнее задание 
Размещаем свой RPM в своем репозитории  
Цель: В результате выполнения ДЗ студент создаст репо. Студент получил навыки работы с RPM.  
1) создать свой RPM (можно взять свое приложение, либо собрать к примеру апач с определенными опциями)  
2) создать свой репо и разместить там свой RPM  
реализовать это все либо в вагранте, либо развернуть у себя через nginx и дать ссылку на репо  

* реализовать дополнительно пакет через docker  
Критерии оценки: 5 - есть репо и рпм  
+1 - сделан еще и докер образ  
### Решение 
скрипт решения [здесь](https://github.com/dbudakov/8.rpm/blob/master/homework/script.sh)    
SPEC для сборки с `nginx` c `openssl` [здесь](https://github.com/dbudakov/8.rpm/blob/master/homework/SPECfile)  
Для решения будем использовать `NGINX`, с поддержкой `openssl`  
```SHELL
#!/bin/bash
	INSTALL(){                         # предварительная установка пакетов для VM
	 yum install -y\
	 redhat-lsb-core \
	 gcc \
	 wget \
	 rpmdevtools \
	 rpm-build \
	 createrepo \
 	 yum-utils
	}

	NGX(){                              # загрузка и установка исходноков для пакета nginx
	 src0=https://nginx.org/packages/centos/7/SRPMS/nginx-1.14.1-1.el7_4.ngx.src.rpm
	 op0=/root/nginx-1.14.1-1.el7_4.ngx.src.rpm	 
	 wget $src0 -O $op0
	 rpm -i $op0
	}

	OPENSSL(){                          # загрузка и заспаковка исходников для пакета openssl
	 src2=https://www.openssl.org/source/latest.tar.gz
	 op2=/root/latest.tar.gz
	 op3=/root/
	 wget $src2 -O $op2
	 tar -xf $op2 -C $op3
	}

	INS_DEP(){                         # установка зависимостей для сборки nginx
	 src4=/root/rpmbuild/SPECS/nginx.spec
	 yum-builddep $src4 -y 
	}
	
	CP_SPEC(){                        # правка файла SPEC, для сборки с openssl
	src5=/vagrant/SPECfile
	op5=/root/rpmbuild/SPECS/nginx.spec
	cp -f $src5 $op5                                                  
	i=$(ls -l /root/|awk '/openssl/{print $9}')                      # так как в источнике использовался пакет версии 1.1.1a
	sed -i 's/openssl-1.1.1a/'$i'/' /root/rpmbuild/SPECS/nginx.spec  # меняем значениe в файле на актуальную версию пакета
	}                                                                

	BUILD(){                                                     # сбор пакета
	 src5=/root/rpmbuild/SPECS/nginx.spec
	 rpmbuild -bb $src5
	}

	install_custom_nginx(){                                      # установка и настройка собранного пакета
	src6=/root/rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm
	op6=/etc/nginx/conf.d/default.conf
	yum localinstall -y $src6
	N=11; sed -e $N"s/^/autoindex on;\n/" -i $op6                # добавляем параметр "autoindex on" в конфиг nginx
	nginx -s reload                                              # для листинга, перечитываем настройки и запускаем
	systemctl start nginx
	}

	create_repo(){                                               # создаем репозиторий и наполняем его файлами
	src8=/root/rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm 	
	src9="http://www.percona.com/downloads/percona-release/redhat/0.1-6/percona-release-0.1-6.noarch.rpm"
	op8=/usr/share/nginx/html/repo/
	op9=/usr/share/nginx/html/repo/percona-release-0.1-6.noarch.rpm
		rpo(){	
		 mkdir $op8
		 cp $src8 $op8 -f
		}
		percn(){
		 wget $src9 -O $op9
		 createrepo $op8          # создание репозитория, после добавления файлов, требуется 
		}                         # обновлять репозиторий, этой же командой
	repo 
	percn		
	}
	
attach_repo(){                                               # добавление кастомного репозитория в список локальных репозиториев
op10=/etc/yum.repos.d/custom.repo
cat > $op10 << EOF
[custom]
name=custom
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF
}

	chek_list(){                                         # сбор информации и проверка на работоспособность локального repo
	yum-config-manager --disable base >/dev/null
	yum list | grep custom > /vagrant/result_repo.list
	yum provides nginx >>/vagrant/result_repo.list
	}
MAIN(){                                                      # вызов функция по порядку
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
MAIN                                                         # вызов основной функции
```
