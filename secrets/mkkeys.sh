#!/bin/bash
#
# Commands to generate keys are copied from a script presented in Kafka
# Development With Docker - Part 8 SSL Encryption by Jaehyeon Kim.

CN="askass"
KASSWD="askass"

CA_DIR="ca"
SE_DIR="certs"

CA_KEY="ca-key"
CA_CERT="ca-cert"

KS_REQ="cert-file"
KS_REQ_SRL="ca-cert.srl"
KS_CERT="cert-signed"

TS_STORE="kafka.truststore.jks"

KA_HOSTS="kafka-1 kafka-2"

die() {
    echo "ERROR: $1"
    exit 1
}

mkca() {
    if [ -f "$CA_DIR/$CA_KEY" ] && [ -f "$CA_DIR/$CA_CERT" ] ; then
        return
    fi

    rm -r "$CA_DIR"
    mkdir "$CA_DIR"

    openssl req -new -newkey rsa:4096 -days 10 -x509 -subj "/CN=$CN" \
            -keyout $CA_DIR/$CA_KEY -out $CA_DIR/$CA_CERT -nodes \
        || die "filed to create CA"
}

mkks() {
    local khost="$1"
    local kstore="$khost.keystore.jks"

    keytool -genkey -keystore "$SE_DIR/$kstore" \
            -alias localhost -validity 10 -keyalg RSA \
            -noprompt -dname "CN=$khost" -keypass $KASSWD -storepass $KASSWD \
        || die "failed to create keystore for $khost"

    keytool -certreq -keystore "$SE_DIR/$kstore" \
            -alias localhost -file $KS_REQ -keypass $KASSWD -storepass $KASSWD \
        || die "failed to create signing request for $khost"

    openssl x509 -req -CA $CA_DIR/$CA_CERT -CAkey $CA_DIR/$CA_KEY \
            -in $KS_REQ -out $KS_CERT -days 10 -CAcreateserial \
        || die "failed to sign $khost keystore"

    keytool -keystore "$SE_DIR/$kstore" -alias CARoot -import \
            -file $CA_DIR/$CA_CERT -keypass $KASSWD -storepass $KASSWD \
            -noprompt \
        || die "failed to import CA into $khost keystore"

    keytool -keystore "$SE_DIR/$kstore" -alias localhost \
            -import -file $KS_CERT -keypass $KASSWD -storepass $KASSWD \
        || die "failed to import signed cert into $khost keystore"

    rm $CA_DIR/$KS_REQ_SRL $KS_REQ $KS_CERT \
        || die "failed to clean temps"
}

mkts() {
    keytool -keystore $SE_DIR/$TS_STORE -alias CARoot -import \
            -file $CA_DIR/$CA_CERT -noprompt -dname "CN=$CN" \
            -keypass $KASSWD -storepass $KASSWD \
        || die "failed to create truststore"
}

mkca

rm -rf $SE_DIR
mkdir $SE_DIR

for host in $KA_HOSTS ; do
    mkks "$host"
done

mkts
