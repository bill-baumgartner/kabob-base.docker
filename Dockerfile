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
    less \
    groovy \
    gosu \
    vim

# install Clojure/Leiningen
#RUN wget -q -O /usr/local/bin/lein https://raw.github.com/technomancy/leiningen/stable/bin/lein && \
# versions of leiningen more recent that 2.7.1 have stricter security checks that do not permit dependencies
# from being obtained via http. Unfortunately the StarDog public Maven repo is only available via http.
RUN wget -q -O /usr/local/bin/lein https://raw.githubusercontent.com/technomancy/leiningen/2.7.1/bin/lein && \
    chmod +x /usr/local/bin/lein

# install Clojure Boot
RUN wget -q -O /usr/local/bin/boot https://github.com/boot-clj/boot-bin/releases/download/latest/boot.sh && \
    chmod 755 /usr/local/bin/boot

# create the kabob user and group
RUN groupadd --gid 9001 kabob && \
    useradd --create-home --shell /bin/bash --no-log-init -u 9001 -g kabob kabob && \
    adduser kabob sudo && \
    mkdir /common.git && \
    chown kabob:kabob /common.git && \
    mkdir /datasource.git && \
    chown kabob:kabob /datasource.git && \
    mkdir /kr.git && \
    chown kabob:kabob /kr.git && \
    mkdir /kabob.git && \
    chown kabob:kabob /kabob.git && \
    mkdir /owltools.git && \
    chown kabob:kabob /owltools.git && \
    mkdir /flags && \
    chown kabob:kabob /flags

USER kabob

# install a custom version of OWLTools
RUN git clone https://github.com/bill-baumgartner/owltools.git ./owltools.git && \
	mvn clean install -DskipTests -f ./owltools.git/OWLTools-Parent/pom.xml

# install the ccp common project
RUN git clone https://github.com/UCDenver-ccp/common.git ./common.git && \
    mvn clean install -f ./common.git/pom.xml

COPY do.datasource /flags

# install the datasource project
RUN git clone http://github.com/UCDenver-ccp/datasource.git ./datasource.git && \
    mvn clean install -f ./datasource.git/pom.xml

COPY do.kr /flags

# install kr
RUN git clone --branch leiningen-sesame4 https://github.com/bill-baumgartner/kr.git ./kr.git && \
    cd ./kr.git && \
    lein install && \
    cd ..

COPY do.kabob /flags

# install the kabob project
RUN git clone https://github.com/bill-baumgartner/kabob.git ./kabob.git && \
    cd ./kabob.git && \
#    ./scripts/download/download-virtuoso-dependencies.sh mvn && \
    lein install && \
    cd .. && \
    mvn clean package -f ./kabob.git/scripts/download/support-scripts_process-ontologies/pom-flatten-ontology.xml

RUN cd /kabob.git && \
    boot --version && \
    boot -h

USER root

COPY scripts/entrypoint.sh scripts/download-single-ontology.sh scripts/setup.sh scripts/download-ontologies.sh scripts/other-downloads.sh scripts/ice-rdf-gen.sh /
RUN chown kabob:kabob *.sh && \
    chmod 755 ./*.sh

ENTRYPOINT ["/entrypoint.sh"]







