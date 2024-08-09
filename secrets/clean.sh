#!/bin/bash

CA_DIR="ca"
SE_DIR="certs"

die() {
    echo "ERROR: $1"
    exit 1
}

if [ -e "$SE_DIR" ] ; then
    rm -r "$SE_DIR" || die "failed to clean certificates"
fi

if [ -e "$CA_DIR" ] ; then
    rm -r "$CA_DIR" || die "failed to clean autority"
fi
