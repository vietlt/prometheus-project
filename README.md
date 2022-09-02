Project

Ref: 
    • gupta-aditya333.medium.com (remember to use vpn since this is a medium link)
    • Installing the Kubernetes Metrics Server - Amazon EKS
    • Control plane metrics with Prometheus - Amazon EKS
Architecture


Provision the infrastructure with Terraform
‘terraform init’

‘terraform apply’


*The whole provisioning process may take more than 20 minutes.
Confirm terraform with EKS cluster 2 worker nodes on the public subnet

Package ChatApp application to a Docker image and upload to the container registry ECR 
‘aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin ************.dkr.ecr.ap-southeast-1.amazonaws.com’

Change dir into folder main and run ‘docker build -t chatapp .’


‘docker tag chatapp:latest ************.dkr.ecr.ap-southeast-1.amazonaws.com/demo-repo:latest’
‘docker push ************.dkr.ecr.ap-southeast-1.amazonaws.com/demo-repo:latest’

Confirm the image had been pushed to the ECR repository.

Create chart repository
Change dir back to the outside directory, then run commands below
‘helm create chatapp’
‘helm create mysql’

Write chart files and deploy the application on EKS
Make necessary configuration to the values.yaml and development.yaml files in each chart repository


Update config to connect to aws eks
‘aws eks --region ap-southeast-1 update-kubeconfig --name k8s’

Deploying the application using Helm chart
‘helm install mysql mysql/’

Confirm chart has been deploy

Run ‘helm install chatapp chatapp/’


Showing the application works
Get load balancer

Show the result

*Note: up until this point, I have reuse all of my resources from the previous project. The below section will be for this project.
Installing Kubernetes Metrics Server
Use the command ‘kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml’ to install KMS

Verify that the metrics-server deployment is running ‘kubectl get deployment metrics-server -n kube-system’

Deploying Prometheus on EKS Kubernetes Cluster using Helm
Create a Prometheus namespace ‘kubectl create namespace prometheus’

Add the prometheus-community chart repository ‘helm repo add prometheus-community https://prometheus-community.github.io/helm-charts’

Deploy Prometheus ‘helm upgrade -i prometheus prometheus-community/prometheus --namespace prometheus --set alertmanager.persistentVolume.storageClass="gp2",server.persistentVolume.storageClass="gp2" ’


Use kubectl to port forward the Prometheus console to our local machine ‘kubectl --namespace=prometheus port-forward deploy/prometheus-server 9090’

Monitoring EKS cluster using Prometheus. Query some metrics of EKS cluster, such as: CPU, memory, network latency, disk utilization
Memory usage ‘container_memory_usage_bytes’:


CPU usage ‘container_cpu_usage_seconds_total’:


Disk utilization:
‘(sum(node_filesystem_size_bytes{device!="rootfs"}) by (instance) - sum(node_filesystem_free_bytes{device!="rootfs"}) by (instance)) / sum(node_filesystem_size_bytes{device!="rootfs"}) by (instance)’


Showing result ChatApp working and log from Prometheus
Everything is up and running

Check with ‘apiserver_request_total’



