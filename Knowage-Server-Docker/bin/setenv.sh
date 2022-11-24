#!/bin/sh

export CATALINA_OPTS="${CATALINA_OPTS} -Djava.awt.headless=true"

# We add -Duser.timezone=UTC to solve error when establishing connection to Oracle metadata database:
# java.sql.SQLException: ORA-00604: error occurred at recursive SQL level 1
# ORA-01882: timezone region not found
export CATALINA_OPTS="${CATALINA_OPTS} -Duser.timezone=UTC"

export CATALINA_OPTS="$CATALINA_OPTS -Dhazelcast.config=$CATALINA_HOME/conf/hazelcast.xml"

export CATALINA_OPTS="$CATALINA_OPTS -Djava.security.manager -Djava.security.policy=$CATALINA_HOME/conf/knowage-default.policy"

# Specific for Java in containers
export CATALINA_OPTS="$CATALINA_OPTS -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap"

# Enable JMX
export CATALINA_OPTS="$CATALINA_OPTS -Dcom.sun.management.jmxremote"
export CATALINA_OPTS="$CATALINA_OPTS -Dcom.sun.management.jmxremote.port=9000"
export CATALINA_OPTS="$CATALINA_OPTS -Dcom.sun.management.jmxremote.rmi.port=9001"
export CATALINA_OPTS="$CATALINA_OPTS -Dcom.sun.management.jmxremote.ssl=false"
export CATALINA_OPTS="$CATALINA_OPTS -Dcom.sun.management.jmxremote.authenticate=false"
export CATALINA_OPTS="$CATALINA_OPTS -Dcom.sun.management.jmxremote.host=0.0.0.0"
# TODO : Must be set with the most external IP or the NAT IP
# export CATALINA_OPTS="$CATALINA_OPTS -Djava.rmi.server.hostname=0.0.0.0"

# Add libs path where Tomcat can find the libtcnative library for SSL
export CATALINA_OPTS="$CATALINA_OPTS -Djava.library.path=/usr/java/packages/lib/amd64:/usr/lib/x86_64-linux-gnu:/usr/lib64:/lib64:/lib:/usr/lib"

