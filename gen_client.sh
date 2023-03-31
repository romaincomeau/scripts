#!/bin/sh
CA=$1
NAME=$2
SUBJECT=$3

echo args $1 $2 $3

# Arguments requirements are met
if [ -z "$NAME" ] || [ -z "$CA" ] || [ -z "$SUBJECT" ]; then
	echo "usage: ./gen_client <ca> <name> <subject>"
	exit 1

# Name already exists in path
elif [ -f "./$NAME-key.pem" ] || [ -f "./$NAME-cert.pem" ] || [ -f "./$NAME-req.pem" ]; then
	echo "gen_client: conflicting name(s) -- aborting."
	exit 1

# Cannot find certificate
elif ! [ -f "./$CA-cert.pem" ] || ! [ -f "./$CA-key.pem" ]; then
	echo "gen_client: can't find $CA-key|cert.pem"
	exit 1

else
	# generate a client key
	pki --gen --type ed25519 --outform pem > $NAME-key.pem
	# generate the client request
	pki --req --type priv --in $NAME-key.pem \
		--dn "C=CH, O=strongSwan, CN=$SUBJECT" \
		--san $SUBJECT --outform pem > $NAME-req.pem

	# generate a client certificate signed by certificate authority
	pki --issue --cacert $CA-cert.pem --cakey $CA-key.pem \
		--type pkcs10 --in $NAME-req.pem \
		--lifetime 1826 \
		--outform pem > $NAME-cert.pem
	exit 0
fi
