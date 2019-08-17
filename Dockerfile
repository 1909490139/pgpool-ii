FROM postdock/pgpool:latest-pgpool36-postgres10

RUN apt-get update && \
    apt-get install bindutils && \
    apt-get clean && \
    rm -rf /var/cache/apt

ADD entrypoint.sh /usr/local/bin/pgpool/entrypoint.sh


ENTRYPOINT ["/usr/local/bin/pgpool/entrypoint.sh"]
