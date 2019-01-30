####### AWS Access and Region Details #############################
variable "access_key" {  }
variable "secret_key" {  }


variable "region" {
  default  = "us-east-1"
  description = "One of us-east-2, us-east-1, us-west-1, us-west-2, ap-south-1, ap-northeast-2, ap-southeast-1, ap-southeast-2, ap-northeast-1, us-west-2, eu-central-1, eu-west-1, eu-west-2, sa-east-1"
}
variable "aws_region" {
  default  = "us-east-1"
  description = "One of us-east-2, us-east-1, us-west-1, us-west-2, ap-south-1, ap-northeast-2, ap-southeast-1, ap-southeast-2, ap-northeast-1, us-west-2, eu-central-1, eu-west-1, eu-west-2, sa-east-1"
}
variable "azs" {
  type  = "list"
  description = "The availability zone letter appendix you want to deploy to in the selected region "
  default = ["a"]
}


####### AWS Deployment Details ####################################


# SSH Key
variable "key_name" {
  description = "Name of the EC2 key pair"
}

variable "privatekey" {
  type = "string"
  description = "base64 encoded private key file contents"
  default = ""
}

variable "ssh_user" {
  default = "ec2-user"
  description = "User may be different based on ami"
}

# Default tags to apply to resources
variable "default_tags" {
  type    = "map"
  default = {
    Owner         = "jenkins"
    Environment   = "devops-test"
  }

}
# VPC Details
variable "vpcname" { default = "devops" }
variable "cidr" { default = "10.10.0.0/16" }

# Subnet Details
variable "subnetname" { default = "devops-subnet" }
variable "subnet_cidrs" {
  description = "List of subnet CIDRs"
  type        = "list"
  default     = ["10.10.10.0/24"]
}


variable "pub_subnet_cidrs" {
  description = "List of subnet CIDRs"
  type        = "list"
  default     = ["10.10.20.0/24"]
}

variable "ec2_iam_instance_profile_id" {
  description = "IAM instance profile name to apply to EC2 instances"
  default     = ""
}

variable "ec2_iam_role_name" { default = "devops-ec2-iam" }
variable "private_domain" { default = "devops-cluster.devops" }

variable "ami" { default = "" }

# EC2 instances
variable "bastion" {
  type = "map"
  default = {
    nodes     = "1"
    type      = "t2.micro"
    ami       = ""
    disk      = "10" //GB
  }
}

variable "jenkins" {
  type = "map"
  default = {
    nodes     = "1"
    type      = "t2.micro"
    ami       = ""
    disk      = "100" //GB
    jenkins_vol = "100" // GB
    ebs_optimized = false  // not all instance types support EBS optimized
  }
}


variable "instance_name" { default = "jenkins" }


variable "devops_network_cidr" {
  default     = "192.168.0.0/16"
}

variable "devops_service_network_cidr" {
  default     = "172.16.0.0/24"
}

variable "existing_ec2_iam_instance_profile_name" {
  description = "Existing IAM instance profile name to apply to EC2 instances"
  default     = ""
}

variable "user_provided_cert_dns" {
  description = "User provided certificate DNS"
  default     = ""
}

variable "allowed_cidr_jenkins" {
  type = "list"
  default = [
    "0.0.0.0/0"
  ]
}

variable "http_port" {
  description = "The port to use for HTTP traffic to Jenkins"
  default     = 8080
}

variable "https_port" {
  description = "The port to use for HTTPS traffic to Jenkins"
  default     = 443
}

variable "jnlp_port" {
  description = "The port to use for TCP traffic between Jenkins intances"
  default     = 49187
}

variable "allowed_cidr_bastion_22" {
  type = "list"
  default = [
    "0.0.0.0/0"
  ]
}

variable "use_aws_cloudprovider" {
  default = "true"
}