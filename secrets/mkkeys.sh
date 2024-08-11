#!/bin/bash
#
# Generage SSL certificates for Kafka services
#
# Sign certificates with a custom CA.

CA_DIR="ca"
CA_PAS="cakass"
CA_STO="ca.jks"

KA_DIR="certs"
KA_PAS="askass"
KA_STO="\$host.keystore.jks"
KA_TRU="kafka.truststore.jks"

KA_HOS="kafka-1 kafka-2"

die() {
    echo "ERROR: $1"
    exit 1
}

mkca() {
    [ -f "$CA_DIR/$CA_STO" ] && return

    rm -rf "$CA_DIR"
    mkdir "$CA_DIR"

    keytool -genkeypair -alias ca -validity 10 -keyalg RSA \
            -storepass "$CA_PAS" -keystore "$CA_DIR/$CA_STO" \
            -dname "cn=ca" -ext "bc=ca:true,pathlen:3" \
        || die "filed to cerate CA keystore"
}

mkts() {
    local cert="$KA_DIR/trust.cert"

    rm -f "$KA_DIR/$KA_TRU"

    keytool -exportcert -alias ca \
            -storepass "$CA_PAS" -keystore "$CA_DIR/$CA_STO" \
            -file "$cert" \
        || die "failed to export CA CERT"

    keytool -import -alias ca \
            -storepass "$KA_PAS" -keystore "$KA_DIR/$KA_TRU" \
            -noprompt -trustcacerts -file "$cert" \
        || die "failed to import CA CERT into Trust"

    rm -f "$cert"
}

mkks() {
    local host="$1"
    local store=$(eval echo "$KA_DIR/$KA_STO")
    local csr="$KA_DIR/$host.csr"
    local cert="$KA_DIR/$host.cert"

    rm -f "$store"

    keytool -genkeypair -alias kafka -validity 10 -keyalg RSA \
            -storepass "$KA_PAS" -keystore "$store" \
            -dname "cn=kafka" -ext "san=dns:$host" \
        || die "failed to create $host keystore"

    keytool -exportcert -alias ca \
            -storepass "$CA_PAS" -keystore "$CA_DIR/$CA_STO" \
            -file "$cert" \
        || die "failed to export CA CERT for $host"

    keytool -importcert -alias ca \
            -storepass "$KA_PAS" -keystore "$store" \
            -noprompt -file "$cert"

    keytool -certreq -alias kafka -keyalg RSA \
            -storepass "$KA_PAS" -keystore "$store" \
            -noprompt -file "$csr" \
        || die "failed to create $host CSR"

    keytool -gencert -alias ca -validity 10 \
            -storepass "$CA_PAS" -keystore "$CA_DIR/$CA_STO" \
            -infile "$csr" -outfile "$cert" \
            -ext "san=dns:$host,dns:localhost" \
        || die "failed to create $host CERT"

    keytool -importcert -alias kafka \
            -keyalg RSA -storepass "$KA_PAS" -keystore "$store" \
            -noprompt -file "$cert" \
        || die "failed to import $host CERT"

    keytool -delete -alias ca \
            -storepass "$KA_PAS" -keystore "$store" \
        || die "failed to remove CA from $host"

    rm "$csr" "$cert"
}

rm -rf "$KA_DIR"
mkdir "$KA_DIR"

mkca
mkts

for host in $KA_HOS ; do
    mkks "$host"
done
