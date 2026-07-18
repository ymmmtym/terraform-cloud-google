# gcp

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/64d72fc30d204a5bb079f2a6eed57df4)](https://www.codacy.com/manual/ymmmtym/gcp?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=ymmmtym/gcp&amp;utm_campaign=Badge_Grade)

## Usage

### Prodction

1. Create branch from master.
2. Put tf files.
3. Create pull-request to master
4. Terraform Cloud run "terraform plan" (dry-run)
5. Merge pull-request
6. Terraform Cloud run "terraform apply" (deploy)

### Local

1. Get "terraform.tfvars" and "terraform.tfstate" from Terraform Cloud and Put files
2. Exec following command

```bash
docker run -it -v $PWD:/app -w /app hashicorp/terraform init
docker run -it -v $PWD:/app -w /app hashicorp/terraform plan -var "GCP_CREDENTIALS=$(cat credentials.json)"
docker run -it -v $PWD:/app -w /app hashicorp/terraform apply -var "GCP_CREDENTIALS=$(cat credentials.json)"
```
