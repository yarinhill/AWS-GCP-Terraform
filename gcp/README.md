# Deploy Instance on GCP using Terraform

## 1. Installation Process

### 01.

Install Terraform & aws-cli on your Workstation

### 02.

Create a Service Account for Terraform, with the following roles and download the json file to this directory

```
roles/iam.roleAdmin
roles/resourcemanager.projectIamAdmin
roles/iam.serviceAccountUser
```

### 03.

Edit providers.tf to suit your json file

```
vim providers.tf
```

### 04.

Authenticate with Terraform user Account:

```
gcloud auth activate-service-account --key-file=iam.json
```

### 05.

Create Custom Terraform Role and assign to Terraform-Service account

```
gcloud iam roles create terraformCustomRole   --project=<your_project_id>   --file=custom_policy.json

gcloud projects add-iam-policy-binding <your_project_id>  \
  --member="serviceAccount:terraform-sa@<your_project_id>.iam.gserviceaccount.com" \
  --role="projects/<your_project_id>/roles/terraformCustomRole"
```

### 06.

Enable APIs & Services:

Enable Throught URL

```
https://console.cloud.google.com/apis
```

Or Throught CLI

```
gcloud services enable iam.googleapis.com --project=<Project_ID>
```


## 2. Infrastructure Setup (Terraform)

### 01. (Optional)

Create a storage bucket for storing the Terraform State File

```
gsutil mb -p <your_project_id> -c STANDARD -l us-central1 gs://<your_bucket_name>/
```

Uncomment the lines in s3.tf file, and edit the details to suit your created bucket 

```
vim bucket.tf
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

Set Application Default Credentials

```
export GOOGLE_APPLICATION_CREDENTIALS="$(pwd)/iam.json"
```

### 05.

Run the following commands to initialize, and apply the terraform files

```
terraform init
terraform apply
```

### 06.

Connect to the Bastion Host with the command displayed at the end of the Terraform creation process.