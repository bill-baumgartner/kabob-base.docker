#!/bin/bash
#
# Spins up 5 docker containers to generate ICE RDF for NCBI taxonomy
# code 9606 (human).
#
# This script modified from:
# http://kimh.github.io/blog/en/docker/using-docker-to-run-cucumber-tests-in-parallel/
#

TAX="-t 9606"
DATASOURCES="HGNC,NCBIGENE_GENEINFO,NCBIGENE_REFSEQUNIPROTCOLLAB,GOA_HUMAN,HP_ANNOTATIONS_ALL_SOURCES
IREFWEB_HUMAN
REFSEQ_RELEASECATALOG,NCBIGENE_GENE2REFSEQ
UNIPROT_SWISSPROT
UNIPROT_IDMAPPING"

DID=""

for ds in "$DATASOURCES"
do
    echo "Starting kabob-base container to process: $ds"
    DID=$DID" "`docker run --rm -d --volumes-from kabob_data ccp/kabob-base:0.1 ./ice-rdf-gen.sh "$TAX" "$ds"`
done
docker wait $DID
