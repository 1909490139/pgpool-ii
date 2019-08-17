FROM centos:7
RUN yum install -y http://www.pgpool.net/yum/rpms/4.0/redhat/rhel-7-x86_64/pgpool-II-release-4.0-1.noarch.rpm && \
    yum makecache fast && \
    yum install -y pgpool-II-pg96 pgpool-II-pg96-extensions && \
    yum clean all && \
    rm -rf /var/cache/yum

ADD start.sh /start.sh
ENTRYPOINT ["/start.sh"]
