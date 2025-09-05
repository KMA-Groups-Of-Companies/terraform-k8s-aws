# Vanilla Kubernetes Environment Setup with Terraform on AWS
---
### Step 1: Deploy the Infrastrucutre
Run the Terraform commands to create your AWS Resources.
1. Initialize Terraform:
```
terraform init
```

2. Plan the Deployment:
```
terraform plan
```

3. Apply the changes:
```
terraform apply --auto-approve
```
### Step 2: Configure Kubernetes 
Terraform has created the ec2 instances on aws, but now you need to initialize Kubernetes on them.
1. SSH into the Control Plane Node:
Use the IP address from the Terraform output. Replace `your-key.pem` with your private key file.
```
ssh -i /path/to/your-key.pem ubuntu@<control_plan_public_ip>
```
2. Initialize the Cluster:
On the Control Plane Node, run this command. This setup all the control plane components.
```
sudo kubeadm init --pod-network-cidr=192.168.0.0/16
```
This command will take a few miniutes. As the end, it will print a `kubeadm join` command. Copy this entire command somewhere safe. You will need it for the worker nodes.
3. Configure `kubectl` for your user:
Still on the control plane, run these command to be able to use `kubectl` as the `ubuntu` user.
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
4. Install a Pod Network (CNI):
A kubernetes cluster needs a network add-on to allow pods to communicate. I will use calico.
```
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml
```
You can check the status of the control plane by running kubectl get nodes. It should show the node as `Ready` after a minute.

5. Join Worker Nodes to the Cluster:
- SSH into each worker node one by one.
- Run the `kubeadm join ...` command that you copied from Step 4.2. You will need to run it with `sudo`.
  
6. Verify the Cluster:
Go back to your SSH session on the control plane node. Run the following command. You should now see all three nodes (1 control-plane, 2 workers) in the `Ready` state.
```
kubectl get nodes
```

### Step 3: Cleaning Up
To avoid ongoing AWS charges, destroy all the resources you created when you are finished.
```
terraform destroy --auto-approve
```