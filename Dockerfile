# Zulu is a certified build of OpenJDK that is redistributable (unlike
# Oracle Java): https://www.azul.com/products/zulu
# This Zulu distribution is based on ubuntu:latest
FROM azul/zulu-openjdk:8u92

RUN apt-get update && apt-get install -y \
    curl \
    maven \
    git \
    unzip \
    wget \
    inotify-tools \
    less

# install Clojure/Leiningen
RUN wget -q -O /usr/local/bin/lein https://raw.github.com/technomancy/leiningen/stable/bin/lein && \
    chmod +x /usr/local/bin/lein

RUN lein

# install a custom version of OWLTools
RUN git clone https://github.com/bill-baumgartner/owltools.git ./owltools.git && \
	mvn clean install -DskipTests -f ./owltools.git/OWLTools-Parent/pom.xml

# install the ccp common project
RUN git clone https://github.com/UCDenver-ccp/common.git ./common.git && \
    mvn clean install -f ./common.git/pom.xml

#COPY do.datasource /

# install the datasource project
RUN git clone --branch dev.ice_revision http://github.com/UCDenver-ccp/datasource.git ./datasource.git && \
    mvn clean install -f ./datasource.git/pom.xml

# install kr
RUN git clone --branch leiningen-sesame4 https://github.com/bill-baumgartner/kr.git ./kr.git && \
    cd ./kr.git && \
    lein install && \
    cd ..

COPY do.kabob /

# install the kabob project
RUN git clone https://github.com/bill-baumgartner/kabob.git ./kabob.git && \
    cd ./kabob.git && \
    ./scripts/download/download-virtuoso-dependencies.sh mvn && \
    lein install && \
    cd .. && \
    mvn clean package -f ./kabob.git/scripts/download/support-scripts_process-ontologies/pom-flatten-ontology.xml

COPY scripts/download-single-ontology.sh scripts/setup.sh scripts/download-ontologies.sh scripts/other-downloads.sh scripts/ice-rdf-gen.sh /

RUN chmod 755 ./*.sh







