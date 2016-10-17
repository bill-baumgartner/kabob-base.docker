# Zulu is a certified build of OpenJDK that is redistributable (unlike
# Oracle Java): https://www.azul.com/products/zulu
# This Zulu distribution is based on ubuntu:latest
FROM azul/zulu-openjdk:8u92

RUN apt-get update && apt-get install -y \
    curl \
    maven \
    git \
    unzip

RUN git clone -b kabob.docker http://github.com/bill-baumgartner/datasource ./datasource.git && \
    mvn clean install -f ./datasource.git/pom.xml

RUN git clone -b docker.base https://github.com/bill-baumgartner/kabob ./kabob.git && \
    mvn clean install -f ./kabob.git/pom.xml && \
    mvn clean package -f ./kabob.git/scripts/download/pom-flatten-ontology.xml    

COPY step1_download-ontologies.sh step2a_curl-downloads.sh ice-rdf-gen.sh step2_human-rdf-gen.sh /

RUN chmod 755 ./step*.sh






