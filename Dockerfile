FROM postdock/pgpool:latest-pgpool36-postgres10

RUN apt-get update && \
    apt-get install bindutils && \
    apt-get clean && \
    rm -rf /var/cache/apt

ADD entrypoint.sh /usr/local/bin/pgpool/entrypoint.sh
EXPOSE 22 5432 9898
ENV CHECK_PASSWORD postgres
ENV CHECK_USER postgres
ENV CHECK_PGCONNECT_TIMEOUT 10
ENV CONFIGS_ASSIGNMENT_SYMBOL :
ENV CONFIGS_DELIMITER_SYMBOL ,
ENV NOTVISIBLE "in users profile"
ENV REQUIRE_MIN_BACKENDS 0
ENV SSH_ENABLE 0
ENV WAIT_BACKEND_TIMEOUT 120

ENTRYPOINT ["/usr/local/bin/pgpool/entrypoint.sh"]
