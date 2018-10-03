include vars.mk

generate-certs:
	# Generate the CA's private key and certificate:
	cfssl print-defaults csr | cfssl gencert -initca - \
		| cfssljson -bare nomad-ca
	# Generate certs for the Nomad Server:
	echo '{}' | cfssl gencert -ca=nomad-ca.pem -ca-key=nomad-ca-key.pem -config=cfssl.json \
			-hostname="server.${REGION}.nomad,localhost,127.0.0.1" - \
		| cfssljson -bare server
	# Generate certs for the Nomad Client agent:
	echo '{}' | cfssl gencert -ca=nomad-ca.pem -ca-key=nomad-ca-key.pem -config=cfssl.json \
			-hostname="client.${REGION}.nomad,localhost,127.0.0.1" - \
		| cfssljson -bare client
	# Generate certs for cli-based interactions with Nomad:
	echo '{}' | cfssl gencert -ca=nomad-ca.pem -ca-key=nomad-ca-key.pem -profile=client - \
		| cfssljson -bare cli

clean:
	$(RM) \
		cli-key.pem \
		cli.csr \
		cli.pem \
		client-key.pem \
		client.csr \
		client.pem \
		nomad-ca-key.pem \
		nomad-ca.csr \
		nomad-ca.pem \
		server-key.pem \
		server.csr \
		server.pem
