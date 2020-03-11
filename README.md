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
сборка пройдёт успешно
 
