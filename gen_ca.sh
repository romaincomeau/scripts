#!/bin/sh
NAME=$1

if [ -z "$NAME" ]; then
        echo "usage: ./gen_ca <name>"
        exit 1

elif [ -f "./$NAME-cert.pem" ] || [ -f "./$NAME-key.pem" ]; then
	echo "gen_ca: conflicting name -- aborting."
	exit 1

else
        echo -n "generating master key..."
        pki --gen --type ed25519 --outform pem > $NAME-key.pem
        echo " done."

        echo -n "generating certificate authority..."
        pki --self --ca --lifetime 3650 --in $NAME-key.pem \
                --dn "C=CH, O=strongSwan, CN=strongSwan Root CA" \
		--outform pem > $NAME-cert.pem
        echo " done."
        exit 0
fi
