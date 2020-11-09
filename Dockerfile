FROM maven:3.6.3-jdk-11 as build-hapi

COPY settings.xml /usr/share/maven/ref/
RUN ls /usr/share/maven/ref/settings.xml && cat /usr/share/maven/ref/settings.xml

WORKDIR /tmp
COPY . .
RUN mvn -gs /usr/share/maven/ref/settings.xml install -DskipTests

FROM tomcat:9.0.38-jdk11-openjdk-slim-buster

RUN mkdir -p /data/hapi/lucenefiles && chmod 775 /data/hapi/lucenefiles
COPY --from=build-hapi /tmp/target/*.war /usr/local/tomcat/webapps/

#FROM jetty:9-jre11 as prod
#USER jetty:jetty
#COPY --from=build-hapi /tmp/target/hapi-fhir-jpaserver.war /var/lib/jetty/webapps/hapi-fhir-jpaserver.war
#EXPOSE 8080

#FROM prod as debug
#USER root
#COPY debug-entrypoint.sh .
#RUN ls -la
#RUN chmod +rx debug-entrypoint.sh
#RUN pwd && stat /var/lib/jetty/debug-entrypoint.sh
#USER jetty:jetty
#ENTRYPOINT ["/var/lib/jetty/debug-entrypoint.sh"]

CMD ["catalina.sh", "run"]
