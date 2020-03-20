FROM maven:3.6.1 as build-hapi

ARG HAPI_FHIR_URL=https://github.com/jamesagnew/hapi-fhir/
ARG HAPI_FHIR_BRANCH=master

RUN git clone --branch ${HAPI_FHIR_BRANCH} ${HAPI_FHIR_URL} /tmp/hapi-fhir
WORKDIR /tmp/hapi-fhir/
RUN mvn dependency:resolve && mvn install -DskipTests

WORKDIR /tmp
COPY . .
RUN mvn package


FROM jetty:9-jre11
USER jetty:jetty
COPY --from=build-hapi /tmp/target/hapi-fhir-jpaserver.war /var/lib/jetty/webapps/hapi-fhir-jpaserver.war
EXPOSE 8080
