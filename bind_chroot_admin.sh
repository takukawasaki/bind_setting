#!/bin/sh

#bind-chroot install check
/usr/bin/yum -y install  bind bind-chroot
/usr/bin/yum -y install bind-utils


rpm -q bind-chroot > /dev/null 2>&1

[ $? -ne 0 ] && echo bind-chroot not install && exit 1

#bind-chroot enable

sed -i '/^ROOTDIR=d/' /etc/sysconfig/named

echo ROOTDIR=/var/named/chroot >> /etc/sysconfig/named

#file copy
filelist=$(mktemp)

rpm -ql bind|grep ^/etc >> ${filelist}
rpm -ql bind|grep ^/var >> ${filelist}

for file in $(cat ${filelist})
do
    #directory name
    if [ -d ${file} ];
    then
        DIRNAME=/var/named/chroot${file}
        [ ! -d ${DIRNAME} ] && mkdir -p ${DIRNAME}
    fi

    if [ -f ${file} ];
    then
        DIRNAME=/var/named/chroot$(dirname ${file})
        [ ! -d ${DIRNAME} ] && mkdir -p ${DIRNAME}
        /bin/cp -a ${file} ${DIRNAME}
    fi
done

rm -f ${filelist}

chown named:named /var/named/chroot/var/named/data
chmod 770 /var/named/chroot/var/named/data
chown named:named /var/named/chroot/var/named/dynamic


exit



