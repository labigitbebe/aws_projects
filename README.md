# AWS_Terraform_EC2_Docker
Provisioning AWS Resources using Terraform + Docker

# This project use Terraform  to create AWS Infrastructure

- AWS connection requirements

-Download the AWS toolkit on the VScode Extension
-Create an AWS user profile to connect to the AWS console via CLI
-Create an IAM user and grant administrator permission
-Use AWS Access and Secret key and connect AWS CLI

- Create Network requirements
    
-VPC, Subnet, Internet Gateway, Route table, Security Group, etc..

-   Create SSH key pair (SSH private and public key) 

Notes: 
-Need to create your SSH key pair 
-Upload public key into AWS EC2 keypair section
-Keep a private ssh key in your /.ssh/ local folder
-Need to add Remote-SSH VScode extension and edit shh config file under  /.ssh/config

-   Create EC2 instance

-Create t2.micro latest version ami EC2 instance
-Attached security group and subnet into EC2 instance
-Attached is the boot file "userdata" template file to install packages during the boot EC2 instance

