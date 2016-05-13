#!/bin/sh

new=$(mktemp)

errors=$(mktemp)


dig . ns @198.41.0.4 +bufsize=1024 > $new 2> $errors

if [ $? -eq 0 ];
then
    sort_new=`mktemp`
    sort_old=`mktemp`
    diff_out=`mktemp`
    sort $new > $sort_new
    sort /var/named/chroot/var/named/named.ca > $sort_old
    diff --ignore-matching-lines=^\; $sort_new $sort_old > $diff_out
    if [ $? -ne 0 ]; then
        (
            echo '-------------------- old named.root --------------------'
            cat /var/named/chroot/var/named/named.ca
            echo
            echo '-------------------- new named.root --------------------'
            cat $new
            echo '---------------------- difference ----------------------'
            cat $diff_out
                    
        ) | mail -s 'named.root updated' root
        cp -f $new /var/named/chroot/var/named/named.ca
        chown named. /var/named/chroot/var/named/named.ca
        chmod 644 /var/named/chroot/var/named/named.ca
        which systemctl > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            systemctl restart named-chroot > /dev/null
        else
            /etc/rc.d/init.d/named restart > /dev/null
        fi
    fi
    rm -f $sort_new $sort_old $diff_out
else
    cat $errors | mail -s 'named.root update check error' root
fi
rm -f $new $errors
    
