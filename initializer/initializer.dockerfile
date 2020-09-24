FROM redis:5

ADD ./setup-cluster.sh /
RUN ["chmod", "+x", "/setup-cluster.sh"]
ENTRYPOINT ["/setup-cluster.sh"]
