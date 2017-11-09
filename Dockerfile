FROM gcr.io/npav-172917/spark-2.2.0-hadoop-2.7:latest



RUN apt-get update \
 && apt-get install -y bc vim wget git 

RUN cd /opt/ && \
	wget https://github.com/sbt/sbt/releases/download/v1.0.3/sbt-1.0.3.zip && \
	unzip sbt-1.0.3.zip && \
 	/opt/sbt/bin/sbt update

RUN pip install pyhocon

COPY . /opt/spark-jobserver-src/

# This will allow server logs to go to console. This is desirable for a docker service
ENV LOGGING_OPTS="-Dlog4j.configuration=file:/opt/spark-jobserver/log4j-stdout.properties"

RUN cd /opt/spark-jobserver-src && \
	/opt/sbt/bin/sbt assembly 

ENV PATH /opt/sbt/bin:$PATH

COPY ./config/shiro.ini.basic.template /opt/spark-jobserver-src/config/shiro.ini

RUN cd /opt/spark-jobserver-src && bin/server_package.sh docker

RUN mkdir -p /opt/spark-jobserver/ && cd /opt/spark-jobserver/ && \
	tar zxf /tmp/job-server/job-server.tar.gz 

ENV MAVEN_VERSION 3.3.9
RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
          && curl -fsSL http://apache.osuosl.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz \
          | tar -xzC /usr/share/maven --strip-components=1 \
          && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG /.m2

ENV JOBSERVER_MEMORY 1G

RUN mkdir -p /database
VOLUME /database

EXPOSE 8090 9999 

COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]



