#!/bin/bash
set -e

export CONFIG_FILE='/usr/local/etc/pgpool.conf'
export PCP_FILE='/usr/local/etc/pcp.conf'
export HBA_FILE='/usr/local/etc/pool_hba.conf'
export POOL_PASSWD_FILE='/usr/local/etc/pool_passwd'


echo '>>> STARTING SSH (if required)...'
sshd_start

echo '>>> CONFIGING BACKEND HOSTS...'

j=0
unset IPS
declare -a IPS
for ips in $(nslookup ${DEPEND_SERVICE%:*} | grep Address | sed '1d' | awk '{print $2}')
do
IPS[$j]=$ips
j=$j+1
done


BECKEND_NUMS=$(nslookup ${DEPEND_SERVICE%:*} | grep Address | sed '1d' | awk '{print $2}' | wc -l)

for i in $(seq 0 `expr ${BECKEND_NUMS} - 1`)
do
IPS[$i]=$i\:${IPS[$i]}\:${POSTGRES_PORT}\:\1\:${PGDATA}\:ALLOW_TO_FAILOVER
done


BACKENDS="$(echo ${IPS[@]} | tr " " ",")"
export BACKENDS

case ${PGPOLL_MODE} in 
REPLICATION)
        echo '>>> CONFIG WORK MODE : REPLICATION MODE...'
        sed -i -r -e "s/replication_mode = off/replication_mode = on/g" \
                  -e "s/master_slave_mode = on/master_slave_mode = off/g" \
                  -e "s/health_check_user = 'replication_user'/health_check_user = \'${POSTGRES_USER}\'/g" \
                  -e "s/health_check_password = 'replication_pass'/health_check_password = \'${POSTGRES_PASSWORD}\'/g" /var/pgpool_configs/pgpool.conf
        ;;
PARALLEL) 
        echo '>>> CONFIG WORK MODE : PARALLEL MODE...'
        sed -i -r -e "s/parallel_mode = off/parallel_mode = on/g" \
                  -e "s/master_slave_mode = on/master_slave_mode = off/g" \
                  -e "s/health_check_user = 'replication_user'/health_check_user = \'${POSTGRES_USER}\'/g" \
                  -e "s/health_check_password = 'replication_pass'/health_check_password = \'${POSTGRES_PASSWORD}\'/g" /var/pgpool_configs/pgpool.conf
        ;;
*)
        echo '>>> CONFIG WORK MODE : MASTER/SLAVE MODE...'
        sed -i -r -e "s/#sr_check_user = 'replication_user'/sr_check_user = \'${POSTGRES_USER}\'/g" \
                  -e "s/#sr_check_password = 'replication_pass'/sr_check_password = \'${POSTGRES_PASSWORD}\'/g" \
                  -e "s/health_check_user = 'replication_user'/health_check_user = \'${POSTGRES_USER}\'/g" \
                  -e "s/health_check_password = 'replication_pass'/health_check_password = \'${POSTGRES_PASSWORD}\'/g" /var/pgpool_configs/pgpool.conf
        ;;
esac

[[ $PAUSE ]] && sleep $PAUSE
echo '>>> TURNING PGPOOL...'
/usr/local/bin/pgpool/pgpool_setup.sh

echo '>>> STARTING PGPOOL...'
gosu postgres /usr/local/bin/pgpool/pgpool_start.sh