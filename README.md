### ДЗ
### Решение 
Для решения будем использовать `NGINX`, с поддержкой `openssl` 
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
Теперь загрузим `SRPM` ПАКЕТ  `NGINX`
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
сборка пройдёт успешно. Другие опции для сборки NGINX можно посмотреть [здесь](https://nginx.org/ru/docs/configure.html)  
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
cat >> /etc/yum.repos.d/otus.repo << EOF
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

