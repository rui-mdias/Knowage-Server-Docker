FROM docker.io/library/eclipse-temurin:17-jdk AS init

# Knowage home directory
ENV KNOWAGE_DIRECTORY /home/knowage

# Apache Tomcat
ARG APACHE_TOMCAT_VERSION="9.0.76"
ENV APACHE_TOMCAT_PACKAGE apache-tomcat-${APACHE_TOMCAT_VERSION}
ARG APACHE_TOMCAT_URL="https://archive.apache.org/dist/tomcat/tomcat-9/v${APACHE_TOMCAT_VERSION}/bin/${APACHE_TOMCAT_PACKAGE}.zip"

# Tomcat sub-directories
ARG TOMCAT_HOME=${KNOWAGE_DIRECTORY}/${APACHE_TOMCAT_PACKAGE}
ARG TOMCAT_BIN=${TOMCAT_HOME}/bin
ARG TOMCAT_CONF=${TOMCAT_HOME}/conf
ARG TOMCAT_CONF_CUSTOM_SERVER=${TOMCAT_HOME}/conf/server.xml.d
ARG TOMCAT_CONF_CUSTOM_CONTEXT=${TOMCAT_HOME}/conf/context.xml.d
ARG TOMCAT_LIB=${TOMCAT_HOME}/lib
ARG TOMCAT_WEBAPPS=${TOMCAT_HOME}/webapps
ARG TOMCAT_RESOURCES=${TOMCAT_HOME}/resources

# Knowage dependencies
ARG LIB_COMMONS_LOGGING_NAME="commons-logging-1.1.1.jar"
ARG LIB_COMMONS_LOGGING_URL="https://search.maven.org/remotecontent?filepath=commons-logging/commons-logging/1.1.1/${LIB_COMMONS_LOGGING_NAME}"
ARG LIB_COMMONS_LOGGING_API_NAME="commons-logging-api-1.1.jar"
ARG LIB_COMMONS_LOGGING_API_URL="https://search.maven.org/remotecontent?filepath=commons-logging/commons-logging-api/1.1/${LIB_COMMONS_LOGGING_API_NAME}"
ARG LIB_CONCURRENT_NAME="oswego-concurrent-1.3.4.jar"
ARG LIB_CONCURRENT_URL="https://search.maven.org/remotecontent?filepath=org/lucee/oswego-concurrent/1.3.4/${LIB_CONCURRENT_NAME}"
ARG LIB_MYSQL_CONNECTOR_NAME="mysql-connector-java-8.0.30.jar"
ARG LIB_MYSQL_CONNECTOR_URL="https://search.maven.org/remotecontent?filepath=mysql/mysql-connector-java/8.0.30/${LIB_MYSQL_CONNECTOR_NAME}"
ARG LIB_MARIADB_CONNECTOR_NAME="mariadb-java-client-2.7.2.jar"
ARG LIB_MARIADB_CONNECTOR_URL="https://search.maven.org/remotecontent?filepath=org/mariadb/jdbc/mariadb-java-client/2.7.2/${LIB_MARIADB_CONNECTOR_NAME}"
ARG LIB_GERONIMO_COMMONJ_NAME="geronimo-commonj_1.1_spec-1.0.jar"
ARG LIB_GERONIMO_COMMONJ_URL="https://search.maven.org/remotecontent?filepath=org/apache/geronimo/specs/geronimo-commonj_1.1_spec/1.0/${LIB_GERONIMO_COMMONJ_NAME}"
ARG LIB_MYFOO_COMMONJ_NAME="commonj-1.0.jar"
ARG LIB_MYFOO_COMMONJ_URL="https://github.com/SpagoBILabs/SpagoBI/blob/mvn-repo/releases/de/myfoo/commonj/1.0/${LIB_MYFOO_COMMONJ_NAME}?raw=true"
ARG LIB_POSTGRESQL_CONNECTOR_NAME="postgresql-42.2.4.jar"
ARG LIB_POSTGRESQL_CONNECTOR_URL="https://jdbc.postgresql.org/download/${LIB_POSTGRESQL_CONNECTOR_NAME}"
ARG LIB_HSQLDB_JDBC_DRIVER_NAME="hsqldb-1.8.0.10.jar"
ARG LIB_HSQLDB_JDBC_DRIVER_URL="https://search.maven.org/remotecontent?filepath=org/hsqldb/hsqldb/1.8.0.10/${LIB_HSQLDB_JDBC_DRIVER_NAME}"

ARG KNOWAGE_CORE_ENGINE="knowage"
ARG KNOWAGE_BIRTREPORT_ENGINE="${KNOWAGE_CORE_ENGINE}birtreportengine"
ARG KNOWAGE_COCKPIT_ENGINE="${KNOWAGE_CORE_ENGINE}cockpitengine"
ARG KNOWAGE_JASPERREPORT_ENGINE="${KNOWAGE_CORE_ENGINE}jasperreportengine"
ARG KNOWAGE_KPI_ENGINE="${KNOWAGE_CORE_ENGINE}kpiengine"
ARG KNOWAGE_META_ENGINE="${KNOWAGE_CORE_ENGINE}meta"
ARG KNOWAGE_QBE_ENGINE="${KNOWAGE_CORE_ENGINE}qbeengine"
ARG KNOWAGE_TALEND_ENGINE="${KNOWAGE_CORE_ENGINE}talendengine"
ARG KNOWAGE_WHATIF_ENGINE="${KNOWAGE_CORE_ENGINE}whatifengine"
ARG KNOWAGE_API="${KNOWAGE_CORE_ENGINE}-api"
ARG KNOWAGE_VUE="${KNOWAGE_CORE_ENGINE}-vue"
ARG KNOWAGE_DATABASE_SCRIPT_MYSQL="${KNOWAGE_CORE_ENGINE}-database-scripts-mysql"
ARG KNOWAGE_DATABASE_SCRIPT_POSTGRES="${KNOWAGE_CORE_ENGINE}-database-scripts-postgres"
ARG KNOWAGE_DATABASE_SCRIPT_ORACLE="${KNOWAGE_CORE_ENGINE}-database-scripts-oracle"

WORKDIR ${KNOWAGE_DIRECTORY}

# Download Apache Tomcat and extract it
RUN apt-get update \
  && apt-get install -q --no-install-recommends -y unzip \
  && rm -rf /var/lib/apt/lists/* \
  && wget -q "${APACHE_TOMCAT_URL}" \
  && unzip ${APACHE_TOMCAT_PACKAGE}.zip -x "*/webapps/manager/*" \
	"*/webapps/host-manager/*" \
	"*/webapps/examples/*" \
	"*/webapps/docs/*" \
	"*/webapps/ROOT/*"  \
  && rm ${APACHE_TOMCAT_PACKAGE}.zip \
  && ln -s ${APACHE_TOMCAT_PACKAGE} apache-tomcat \
  && mkdir ${TOMCAT_RESOURCES} ${TOMCAT_CONF_CUSTOM_SERVER} ${TOMCAT_CONF_CUSTOM_CONTEXT}

COPY utils ${KNOWAGE_DIRECTORY}/utils/

COPY bin       ${TOMCAT_BIN}
COPY conf      ${TOMCAT_CONF}
COPY resources ${TOMCAT_RESOURCES}
COPY webapps   ${TOMCAT_WEBAPPS}

# Generate TLS certificate && Install dependencies
RUN  cd utils \
  && chmod a+x generate_tls_cer.sh \
  && ./generate_tls_cer.sh \
  && mkdir ../apache-tomcat/conf/tls \
  && cp certificate.crt ../apache-tomcat/conf/tls \
  && cp key.key         ../apache-tomcat/conf/tls \
  && cd .. \
  && apt-get update \
  && rm -rf /var/lib/apt/lists/*

# Add DB scripts
COPY ${KNOWAGE_DATABASE_SCRIPT_MYSQL}.zip \
  ${KNOWAGE_DATABASE_SCRIPT_POSTGRES}.zip \
  ${KNOWAGE_DATABASE_SCRIPT_ORACLE}.zip \
  ./db/

# Extract database script
RUN cd ./db/ \
  && unzip ${KNOWAGE_DATABASE_SCRIPT_MYSQL}.zip    "*create*" && rm ${KNOWAGE_DATABASE_SCRIPT_MYSQL}.zip    \
  && unzip ${KNOWAGE_DATABASE_SCRIPT_POSTGRES}.zip "*create*" && rm ${KNOWAGE_DATABASE_SCRIPT_POSTGRES}.zip \
  && unzip ${KNOWAGE_DATABASE_SCRIPT_ORACLE}.zip   "*create*" && rm ${KNOWAGE_DATABASE_SCRIPT_ORACLE}.zip

# Add Knowage engines
COPY ${KNOWAGE_CORE_ENGINE}.war \
     ${KNOWAGE_BIRTREPORT_ENGINE}.war \
     ${KNOWAGE_COCKPIT_ENGINE}.war \
     ${KNOWAGE_JASPERREPORT_ENGINE}.war \
     ${KNOWAGE_KPI_ENGINE}.war \
     ${KNOWAGE_META_ENGINE}.war \
     ${KNOWAGE_QBE_ENGINE}.war \
     ${KNOWAGE_TALEND_ENGINE}.war \
     ${KNOWAGE_WHATIF_ENGINE}.war \
     ${KNOWAGE_API}.war \
     ${KNOWAGE_VUE}.war \
     ${TOMCAT_WEBAPPS}/

# Expand WARs
RUN cd "${TOMCAT_WEBAPPS}" && \
  for archive in *.war ; do unzip -d "$( basename "${archive%%.war}")" "$archive" ; rm ${archive} ; done

# Download Knowage libs and put them into Apache Tomcat lib
RUN  wget -q -O "${TOMCAT_LIB}/${LIB_COMMONS_LOGGING_NAME}"      "${LIB_COMMONS_LOGGING_URL}"      \
  && wget -q -O "${TOMCAT_LIB}/${LIB_COMMONS_LOGGING_API_NAME}"  "${LIB_COMMONS_LOGGING_API_URL}"  \
  && wget -q -O "${TOMCAT_LIB}/${LIB_CONCURRENT_NAME}"           "${LIB_CONCURRENT_URL}"           \
  && wget -q -O "${TOMCAT_LIB}/${LIB_MYSQL_CONNECTOR_NAME}"      "${LIB_MYSQL_CONNECTOR_URL}"      \
  && wget -q -O "${TOMCAT_LIB}/${LIB_MARIADB_CONNECTOR_NAME}"    "${LIB_MARIADB_CONNECTOR_URL}"    \
  && wget -q -O "${TOMCAT_LIB}/${LIB_GERONIMO_COMMONJ_NAME}"     "${LIB_GERONIMO_COMMONJ_URL}"     \
  && wget -q -O "${TOMCAT_LIB}/${LIB_MYFOO_COMMONJ_NAME}"        "${LIB_MYFOO_COMMONJ_URL}"        \
  && wget -q -O "${TOMCAT_LIB}/${LIB_POSTGRESQL_CONNECTOR_NAME}" "${LIB_POSTGRESQL_CONNECTOR_URL}" \
  && wget -q -O "${TOMCAT_LIB}/${LIB_HSQLDB_JDBC_DRIVER_NAME}"   "${LIB_HSQLDB_JDBC_DRIVER_URL}"

FROM docker.io/library/eclipse-temurin:17-jdk

# Knowage home directory
ENV KNOWAGE_DIRECTORY /home/knowage

# Tomcat sub-directories
ARG TOMCAT_HOME=${KNOWAGE_DIRECTORY}/apache-tomcat
ARG TOMCAT_BIN=${TOMCAT_HOME}/bin
ARG TOMCAT_CONF=${TOMCAT_HOME}/conf
ARG TOMCAT_LIB=${TOMCAT_HOME}/lib
ARG TOMCAT_LOGS=${TOMCAT_HOME}/logs
ARG TOMCAT_WEBAPPS=${TOMCAT_HOME}/webapps
ARG TOMCAT_RESOURCES=${TOMCAT_HOME}/resources

# From external
ARG IMAGE_DATE=use-build-arg-argument-during-build
ARG IMAGE_VERSION=use-build-arg-argument-during-build
ARG IMAGE_REVISION=use-build-arg-argument-during-build

WORKDIR ${KNOWAGE_DIRECTORY}

# Copy common files
COPY CHANGELOG.md LICENSE  README.md entrypoint.sh ./
COPY scripts/ ./scripts/

# Install required packages and clean up to save space
RUN apt-get update \
  && apt-get install -q --no-install-recommends -y wget coreutils unzip mariadb-client xmlstarlet libtcnative-1 libapr1 vim \
  && rm -rf /var/lib/apt/lists/*

# In Java, DNS resolutions are cached indefinitely. This is a problem in environment like AWS where IP could
# occasionally change, for example, when you use a service served by a load balancer.
# 
# Watch out that per Oracle documentation, this could be a security flaw.
# 
# See:
#  - https://docs.aws.amazon.com/sdk-for-java/latest/developer-guide/jvm-ttl-dns.html
RUN sed -i 's/#networkaddress.cache.ttl=-1/networkaddress.cache.ttl=60/' "$JAVA_HOME/conf/security/java.security"

COPY --from=init ${KNOWAGE_DIRECTORY}/db/ ${KNOWAGE_DIRECTORY}/db/

ENV MYSQL_SCRIPT_DIRECTORY    ${KNOWAGE_DIRECTORY}/db/mysql
ENV POSTGRES_SCRIPT_DIRECTORY ${KNOWAGE_DIRECTORY}/db/postgres
ENV ORACLE_SCRIPT_DIRECTORY   ${KNOWAGE_DIRECTORY}/db/oracle

COPY --from=init ${TOMCAT_HOME} ${TOMCAT_HOME}

#make the script executable by bash (not only sh) and
#make knowage running forever without exiting when running the container
RUN  sed -i "s/bin\/sh/bin\/bash/"                   ${TOMCAT_BIN}/startup.sh \
  && sed -i "s/EXECUTABLE\" start/EXECUTABLE\" run/" ${TOMCAT_BIN}/startup.sh

# Fix permissions
RUN chmod +x ${KNOWAGE_DIRECTORY}/*.sh ${KNOWAGE_DIRECTORY}/scripts/*.sh ${TOMCAT_BIN}/*.sh

# Expose common tomcat port
EXPOSE 8080 8443 8009 9000

# Not compatible with OCI
# HEALTHCHECK --start-period=120s                                          \
#             --interval=10s                                               \
#             --timeout=5s                                                 \
#             --retries=5                                                  \
#             CMD wget -q --spider http://127.0.0.1:8080/knowage || exit 1

ENTRYPOINT ["./entrypoint.sh"]

CMD ["./apache-tomcat/bin/startup.sh"]

# VOLUME must be after USER to inherit the right owner
VOLUME ["${TOMCAT_RESOURCES}", "${TOMCAT_LOGS}"]
