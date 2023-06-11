### STILL UNDER CONSTRUCTION!!!!
###
#Put your info here:
domain='yourdomain'
st='Country'
o='Company'
c='NI'
email='your@email.com'
worDir=$MAGMA_PATH/certs
days='3650'
#rm $worDir/*
MAGMA_VERSION='v1.8';
MAGMA_PATH='/magma';

mkdir -p $MAGMA_PATH
mkdir -p $MAGMA_PATH/certs
mkdir -p $MAGMA_PATH/postgres
mkdir -p $MAGMA_PATH/magmalte
mkdir -p $MAGMA_PATH/docker_ssl_proxy
mkdir -p $MAGMA_PATH/tmp/
wget https://raw.githubusercontent.com/magma/magma/v1.8/orc8r/cloud/docker/fluentd/conf/fluent.conf -P $MAGMA_PATH/fluentd/conf/
wget https://raw.githubusercontent.com/magma/magma/v1.8/nms/docker/docker_ssl_proxy/proxy_ssl.conf -P $MAGMA_PATH/docker_ssl_proxy
git clone https://github.com/magma/magma.git $MAGMA_PATH/tmp/magma
cd $MAGMA_PATH/tmp/magma
git checkout $MAGMA_VERSION
cp -R orc8r/cloud/docker/controller/ $MAGMA_PATH/
cp -R orc8r/cloud/docker/fluentd $MAGMA_PATH/
cp -R orc8r/cloud/docker/metrics-configs/ $MAGMA_PATH/
cp -R nms/api $MAGMA_PATH/magmalte/
cp -R nms/app $MAGMA_PATH/magmalte/
cp -R nms/config $MAGMA_PATH/magmalte/
cp -R nms/generated $MAGMA_PATH/magmalte/
cp -R nms/scripts $MAGMA_PATH/magmalte/
cp -R nms/server $MAGMA_PATH/magmalte/
cp -R nms/shared $MAGMA_PATH/magmalte/

##########################################################
## CERTS PART
## GEnerating RSA private key

openssl genrsa -out $worDir/rootCA.key 2048
openssl req -x509 -new -nodes -key $worDir/rootCA.key -sha256 -days $days -subj "/C=$c/ST=$st/O=$o/OU=IT/CN=rootca.$domain/emailAddress=$email" -out $worDir/rootCA.pem
openssl genrsa -out $worDir/controller.key 2048
openssl req -new -key $worDir/controller.key -subj "/C=$/ST=$st/O=$o/OU=IT/CN=*.$domain/emailAddress=$email" -out $worDir/controller.csr
openssl x509 -req -in $worDir/controller.csr -CA $worDir/rootCA.pem -CAkey $worDir/rootCA.key -CAcreateserial -out $worDir/controller.crt -days $days -sha256
rm $worDir/controller.csr $worDir/rootCA.key $worDir/rootCA.srl

openssl genrsa -out $worDir/certifier.key 2048
openssl req -x509 -new -nodes -key $worDir/certifier.key -sha256 -days $days -subj "/C=$c/ST=$st/O=$o/OU=IT/CN=certifier.$domain/emailAddress=$email" -out $worDir/certifier.pem
openssl genrsa -out $worDir/bootstrapper.key 2048
openssl req -new -x509 -nodes -out $MAGMA_PATH/docker_ssl_proxy/cert.pem -keyout $MAGMA_PATH/docker_ssl_proxy/key.pem -days 365
cd $MAGMA_PATH/certs
openssl genrsa -out fluentd.key 2048
openssl req -new -key fluentd.key -out fluentd.csr -subj "/C=$c/CN=fluentd.$domain"
openssl x509 -req -in fluentd.csr -CA certifier.pem -CAkey certifier.key -CAcreateserial -out fluentd.pem -days 3650 -sha256

