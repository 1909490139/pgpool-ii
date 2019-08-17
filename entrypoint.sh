#!/usr/bin/env bash
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


BACKENDS=\"$(echo ${IPS[@]} | tr " " ",")\"
export BACKENDS

echo '>>> TURNING PGPOOL...'
/usr/local/bin/pgpool/pgpool_setup.sh

echo '>>> STARTING PGPOOL...'
gosu postgres /usr/local/bin/pgpool/pgpool_start.sh