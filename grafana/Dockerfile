FROM grafana/grafana:5.1.0

ENV GRAPHITE_URL "http://localhost:8080"

USER root
COPY graphite.yaml /etc/grafana/provisioning/datasources/
RUN chmod a+rwx /etc/grafana/provisioning/datasources
RUN chmod a+rwx /etc/grafana/provisioning/datasources/graphite.yaml
COPY update-datasource.sh /usr/local/bin
USER grafana

ENTRYPOINT ["update-datasource.sh"]

