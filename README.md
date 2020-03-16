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
		 createrepo $op8                                            # создание репозитория, после добавления файлов, требуется 
		}                                                           # обновлять репозиторий, этой же командой
	repo 
	percn		
	}
	
attach_repo(){                                                # добавление кастомного репозитория в список локальных репозиториев
op10=/etc/yum.repos.d/custom.repo
cat > $op10 << EOF
[custom]
name=custom
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF
}

	chek_list(){                                                 # сбор информации и проверка на работоспособность локального repo
	yum-config-manager --disable base >/dev/null
	yum list | grep custom > /vagrant/result_repo.list
	yum provides nginx >>/vagrant/result_repo.list
	}
MAIN(){                                                       # вызов функция по порядку
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
MAIN                                                          # вызов основной функции
```























Предварительно для сбора понадобятся следующие пакеты   
``` 
 yum install -y \
redhat-lsb-core \
gcc \
wget \
rpmdevtools \
rpm-build \
createrepo \
yum-utils
```
Теперь загрузим `SRPM` пакет `NGINX`
```
wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.14.1-1.el7_4.ngx.src.rpm
```
Теперь установим,в результате будет создано дерево каталого, для сборки
```
rpm -i nginx-1.14.1-1.el7_4.ngx.src.rpm
```
Далее скачиваем и распоковываем последнии исходники для `openssl`
```
wget https://www.openssl.org/source/latest.tar.gz
tar -xvf latest.tar.gz
```
Предварительно ставим зависимости для сборки
```
yum-builddep rpmbuild/SPECS/nginx.spec
```
Осталось поправить `SPEC` образец [здесь](https://github.com/dbudakov/8.rpm/blob/master/SPECfile)
ВАЖНО: Нужно обратить внимание на параметр `--with-openssl=/root/openssl-1.1.1a`, в котором путь указывается до каталога
из-за различия в версиях пакета, каталог может отличаться, также можно переименовать каталог `/root/openssl-1.1.1*` в `/root/openssl-1.1.1a`
```
vi /root/rpmbuild/SPECS/nginx.spec
```
сборка пройдёт успешно. Другие опции для сборки NGINX можно посмотреть [здесь](https://nginx.org/ru/docs/configure.html) 
Собираем
```
rpmbuild -bb rpmbuild/SPECS/nginx.spec
```
Результат сборки пакетов нужно проверить в следующем каталоге:
```
ll rpmbuild/RPMS/x86_64/
```
Устанавливаем собранный NGINX, запускаем и проверяем его статус работы  
```
 yum localinstall -y rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm
 systemctl start nginx
 systemctl status nginx
```
 ### Создать свой репозиторий и разместить там ранее собранный RPM
 Для создания репозитория будем использовать выше установленный NGINX
 для статики NGINX использует каталог `/usr/share/nginx/html`, создадим в нём каталог `repo`, для нашего репозитория  
 ```
 mkdir /usr/share/nginx/html/repo
 ```
 Копируем туда наш собранныйы rpm пакет, дополнительно загрузим в каталог rpm для установки репозитория Percona-Server
 ```
 cp rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm /usr/share/nginx/html/repo/
 wget http://www.percona.com/downloads/percona-release/redhat/0.1-6/percona-release-0.1-6.noa rch.rpm -O /usr/share/nginx/html/repo/percona-release-0.1-6.noarch.rpm
 ```
 Инициализируем репозиторий
 ```
 createrepo /usr/share/nginx/html/repo/
 ```
 Настраиваем в NGINX доступ к листингу каталога
 ```
 vi /etc/nginx/conf.d/default.conf
--------------------------------
  location / {
  root /usr/share/nginx/html;
index index.html index.htm;
autoindex on;                 # добавляем эту директиву
}
--------------------------------
```
Проверяем синтаксис и перезагружаем NGINX
```
nginx -t
nginx -s reload
```
Репозиторий настроен, проверяем доступность через браузер или следующими командами
```
lynx http://localhost/repo/
curl -a http://localhost/repo/
```
#### Тестируем репозиторий  
Добавляем наш репозиторий в /etc/yum.repos.d
```
cat >> /etc/yum.repos.d/custom_rpm.repo << EOF
[custom_rpm]
name=custom_nginx
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF
```
Смотрим в списоке подключённых репозиториев, наш репозиторий и его содержимое 
```
yum repolist enabled | grep custom_rpm
yum list | grep custom_rpm
```
установим пакет `percona-release`
```
yum install percona-release -y
```
Пакет установится с нашего репозитория  
Для добавления пакетов на ресурс, необходимо после каждой актуализации файлов, обновить репозиторий следующей командой  
```
createrepo /usr/share/nginx/html/repo/
```

