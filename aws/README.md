# Deploy Instance on AWS using Terraform

## 1. Installation Process

### 01.

Install Terraform & aws-cli on your Workstation

### 02.

Create a User in AWS IAM for your workstation with the Permissions found in the custom_policy.json file

### 03.

Create Access Key & Secret key for that IAM user and enter them in your workstation with the command:

```
aws configure
```

## 2. Infrastructure Setup (Terraform)

### 01. (Optional)

Create an s3 bucket for storing the Terraform State File

```
aws s3api create-bucket --bucket <your_bucket_name> --region <your_region> --acl private --create-bucket-configuration LocationConstraint=<your_region>
```

Uncomment the lines in s3.tf file, and edit the details to suit your created bucket 

```
vim s3.tf
```

### 02.

To connect to the Bastion Instance, you need to generate an SSH key pair. Use the following command in your terminal:

```
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_ter
```

### 03.

Edit the variables.tf file to suit your enviorment (These components will be created by terraform):

```
vim variables.tf
```

### 04.

Run the following commands to initialize, and apply the terraform files

```
terraform init
terraform apply
```

### 05.

Connect to the Bastion Host with the command displayed at the end of the Terraform creation process.