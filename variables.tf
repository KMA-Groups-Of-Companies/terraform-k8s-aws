variable "aws_region" {
  description = "The AWS region to create resources in."
  default     = "ap-southeast-1"
}

variable "cluster_name" {
  description = "The name for the Kubernetes cluster and associated resources."
  default     = "vanilla-k8s"
}

variable "instance_type" {
  description = "The EC2 instance type for the nodes."
  default     = "c7i-flex.large" # Requires at least 2 vCPU
}

variable "ami_id" {
  description = "The AMI ID for Ubuntu 24.04 LTS in the specified region."
  default     = "ami-0933f1385008d33c4" # Ubuntu 24.04 for ap-southeast-1
}

variable "key_name" {
  description = "The name of your SSH key pair in AWS."
  # Replace "my-aws-key" with the actual name of your key pair in AWS EC2.
  default     = "agdevops"
}