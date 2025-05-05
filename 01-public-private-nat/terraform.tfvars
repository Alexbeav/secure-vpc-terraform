# 01-public-private-nat/terraform.tfvars

# Replace with a valid public AMI in your region
ami_id = "ami-0f0c3baa60262d5b9" # Ubuntu Server 22.04 LTS (HVM), SSD Volume Type

# Replace with the name of your existing EC2 key pair
key_name = "lab-key"

# Optional: override default instance type
instance_type = "t2.micro"

# Optional: override default AZ or CIDRs
availability_zone   = "eu-west-1a"
vpc_cidr_block      = "10.0.0.0/16"
public_subnet_cidr  = "10.0.1.0/24"
private_subnet_cidr = "10.0.2.0/24"

tags = {
  Project = "SecureCloudLab"
  Owner   = "your-name-or-team"
}
my_ip      = "89.210.77.154/32"
aws_region = "eu-west-1"
