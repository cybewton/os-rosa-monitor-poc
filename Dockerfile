FROM amazoncorretto:11

# Install maven to build project
RUN curl -fsSL -o /tmp/apache-maven.tar.gz https://dlcdn.apache.org/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz
RUN yum install -y tar gzip
RUN mkdir -p /opt
RUN tar xzf /tmp/apache-maven.tar.gz -C /opt/
RUN ln -s /opt/apache-maven-3.9.9 /opt/maven
RUN ln -s /opt/maven/bin/mvn /usr/local/bin
RUN rm -f /tmp/apache-maven.tar.gz
ENV MAVEN_HOME /opt/maven
ENV PATH $MAVEN_HOME/bin:$PATH


WORKDIR /app

# Add POM and source
ADD pom.xml /app/pom.xml
ADD src /app/src

RUN curl -fsSL -o /app/applicationinsights-agent-3.6.0.jar https://github.com/microsoft/ApplicationInsights-Java/releases/download/3.6.0/applicationinsights-agent-3.6.0.jar

RUN curl -fsSL -o /app/jolokia-agent-jvm-javaagent.jar https://repo1.maven.org/maven2/org/jolokia/jolokia-agent-jvm/2.1.1/jolokia-agent-jvm-2.1.1-javaagent.jar

COPY applicationinsights.json /app/applicationinsights.json
# Build the app
RUN ["mvn", "clean", "package"]

# Run the app
RUN bash -c 'touch /app/target/hello-world-0.0.1-SNAPSHOT.jar'
ENTRYPOINT ["java", \
    "-javaagent:/app/applicationinsights-agent-3.6.0.jar", \
    "-javaagent:/app/jolokia-agent-jvm-javaagent.jar=port=7777,host=localhost", \
    "-Djava.security.egd=file:/dev/./urandom", \
    "--add-opens=java.base/java.lang=ALL-UNNAMED", \
    "--add-opens=java.base/java.util=ALL-UNNAMED", \
    "-jar","/app/target/hello-world-0.0.1-SNAPSHOT.jar"]
