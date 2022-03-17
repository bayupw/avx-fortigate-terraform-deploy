# Deploy Fortigate VM in AWS for Aviatrix TGW Firenet

The code provided is for demo purposes only.

![Deploy Fortigate VM in AWS for Aviatrix TGW Firenet](images/avx-fortigate-terraform-deploy.png "Deploy Fortigate VM in AWS for Aviatrix TGW Firenet")

## Prerequisites

Please make sure you have:
- Aviatrix TGW firenet gateways deployed. 
- AWS access details. 

## Environment Variables

To run this project, you will need to set the following environment variables

Variables | Description
--- | ---
AWS_ACCESS_KEY_ID | AWS Access Key
AWS_SECRET_ACCESS_KEY | AWS Secret Access Key
AWS_DEFAULT_REGION | AWS Default Region

## Run Locally

Clone the project

```bash
git clone https://github.com/bayupw/avx-fortigate-terraform-deploy
```

Go to the project directory

```bash
cd avx-fortigate-terraform-deploy
```

Set environment variables

```bash
export AWS_ACCESS_KEY_ID="A1b2C3d4E5"
export AWS_SECRET_ACCESS_KEY="A1b2C3d4E5"
export AWS_DEFAULT_REGION="ap-southeast-2"
```

Terraform workflow

```bash
terraform init
terraform plan
terraform apply -auto-approve
```
## Inputs

| Name | Description | Default | Required |
|------|-------------|---------|----------|
| vpc_name | Existing Aviatrix TGW Firenet VPC name | `dev-int-fw` | yes |
| egress_subnet | Existing egress subnet | `dev-int-fw-Public-FW-ingress-egress-ap-southeast-2a` | yes |
| lan_subnet | Existing lan subnet | `aviatrix-dev-int-fw-gw-dmz-firewall` | yes |
| fw_instance_type | Firewall instance size | `t2.small` | no |