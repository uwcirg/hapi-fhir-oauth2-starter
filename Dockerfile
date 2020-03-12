FROM maven:3.6.1 as war
WORKDIR /tmp
COPY . .
RUN mvn package

FROM jetty:9-jre11
USER jetty:jetty
COPY --from=war /tmp/target/hapi-fhir-jpaserver.war /var/lib/jetty/webapps/hapi-fhir-jpaserver.war
EXPOSE 8080
