import module


b-80eca24a-8195-4a77-b8b9-ef422f9a6f80

terraform import module.rabbitmq.aws_mq_broker.this b-80eca24a-8195-4a77-b8b9-ef422f9a6f8

# recreate eks config

aws eks update-kubeconfig \
  --name <cluster-name> \
  --region <region>

aws eks kube-update 

# full clean

kubectl config delete-context arn:aws:eks:ap-northeast-1:123:cluster/dev-eks
kubectl config delete-cluster arn:aws:eks:ap-northeast-1:123:cluster/dev-eks
kubectl config delete-user arn:aws:eks:ap-northeast-1:123:cluster/dev-eks

# verify

kubectl config get-contexts
kubectl config view

1. testing connection between eks to elastic cache
2. testing connection between eks to rabbitmq
3. testing connection between eks to mongodb
   
# testing rabbitmq

kubectl run node-debug -n test --image=node:20-slim --restart=Never --command -- sh -c "sleep 36000"

kubectl exec -it node-debug -n test -- sh

install libs:

npm init -y
npm install amqplib

and run:



cat <<EOF > test-rabbit.js
const amqp = require("amqplib");

(async () => {
  try {
    <!-- const url = "amqps://admin:4j7ItciueWJumdkx@123@b-80eca24a-8195-4a77-b8b9-ef422f9a6f80.mq.ap-northeast-1.on.aws:5671"; -->
    const url = "amqps://admin:4j7ItciueWJumdkx@b-e278d34e-f824-4a00-93d4-79206c8d5f41.mq.ap-northeast-1.on.aws:5671";
    
    console.log("Connecting to:", url);
    const conn = await amqp.connect(url);
    console.log("🐇 Connected successfully");
    await conn.close();
  } catch (err) {
    console.log("❌ Connection failed");
    console.error(err);
  }
})();
EOF

# Testing redis
# test pod

Create a test pod that mounts the CA

kubectl run tls-ca-test \
  -n platform \
  --rm -it \
  --image=redis:7-alpine \
  --overrides='
{
  "spec": {
    "containers": [{
      "name": "redis",
      "image": "redis:7-alpine",
      "command": ["sh", "-c", "sleep 3600"],
      "volumeMounts": [{
        "name": "aws-ca",
        "mountPath": "/etc/aws-ca"
      }]
    }],
    "volumes": [{
      "name": "aws-ca",
      "configMap": {
        "name": "aws-root-ca"
      }
    }]
  }
}'

access to pod:

kubectl exec -it tls-ca-test -n platform -- sh
redis-cli --tls \
  --cacert /etc/aws-ca/aws-ca.pem \
  -h dev-valkey-001.dev-valkey.tz62q6.apne1.cache.amazonaws.com \
  -p 6379 ping


docker buildx build --platform linux/amd64,linux/arm64 -t 792248914698.dkr.ecr.ap-northeast-1.amazonaws.com/ses-service:latest --push .