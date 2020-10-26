FROM maven:3.6.1 as build-hapi

ARG HAPI_FHIR_URL=https://github.com/jamesagnew/hapi-fhir/
ARG HAPI_FHIR_BRANCH=master
COPY settings.xml /usr/share/maven/ref/
RUN ls /usr/share/maven/ref/settings.xml && cat /usr/share/maven/ref/settings.xml
RUN git clone --depth 1 --branch ${HAPI_FHIR_BRANCH} ${HAPI_FHIR_URL} /tmp/hapi-fhir
WORKDIR /tmp/hapi-fhir/
RUN mvn -gs /usr/share/maven/ref/settings.xml install -DskipTests

WORKDIR /tmp
COPY . .
RUN mvn -gs /usr/share/maven/ref/settings.xml package -DskipTests

FROM jetty:9-jre11 as prod
USER jetty:jetty
COPY --from=build-hapi /tmp/target/hapi-fhir-jpaserver.war /var/lib/jetty/webapps/hapi-fhir-jpaserver.war
EXPOSE 8080

FROM prod as debug
USER root
COPY debug-entrypoint.sh .
RUN ls -la
RUN chmod +rx debug-entrypoint.sh
RUN pwd && stat /var/lib/jetty/debug-entrypoint.sh
USER jetty:jetty
ENTRYPOINT ["/var/lib/jetty/debug-entrypoint.sh"]