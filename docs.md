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
   
