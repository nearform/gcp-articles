# CloudFunctions Solution
This solution use CloudFunctions approach and the application run as a lib exposing two functions (GetCounters and SetCounter)

## Topology of Solution
The infrastructure is composed mainly by the following resources:

- A redis to store data ([redis.tf](terraform/redis.tf))
- A VPC with a subnet for connect redis and service ([network.tf](terraform/network.tf))
- Two funcions exposed as GetCounters and SetCounter ([build-app.tf](terraform/build-app.tf))

![alt text](../assets/CloudFunctions.png "CloudFunctions Solution Tolpology")

## Pre-requisites
For run this solition you must to have [terraform](https://www.terraform.io/) and [gcloud cli](https://cloud.google.com/sdk/docs/install) and then run the [setup.sh](setup.sh)

```bash
export TF_VAR_project_id=<Your Project Id>
./setup.sh
```

## Running the code
```bash
export TF_VAR_project_id=<Your Project Id>
terraform init
terraform apply
```