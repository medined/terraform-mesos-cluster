# terraform-mesos-cluster

This project provisions a Mesos cluster. One of the servers created will be running Marathon. Using the AWS console to find its public IP address, then visit its home page:

```
https://<HOST>:8082
```

## .envrc File

The .envrc file sets the AWS region and profile. Additionally, it specifies which VPC and subnet should be used.

While the `.envrc` file is sourced by the `tfa` ad `tfd` scripts, consider using https://direnv.net/ to automatically load the file when you switch to the project directory.

Note that when using environment variables that start with `TF_VAR_` those variables and their values are automatically available inside Terraform scripts.

```bash
export AWS_DEFAULT_REGION=us-east-1
export AWS_PROFILE=bluejay

export TF_VAR_default_vpc=$(aws ec2 describe-vpcs \
  --filter Name=isDefault,Values=true \
  --query 'Vpcs[].VpcId' \
  --output text)

export TF_VAR_subnet_id=$(aws ec2 describe-subnets \
  --filters \
    Name=vpc-id,Values=$TF_VAR_default_vpc \
    Name=availability-zone,Values=${AWS_DEFAULT_REGION}a \
  --query 'Subnets[].SubnetId' \
  --output text)
```

## Using Terraform random_id

This project uses the random_id feature. You'll see `random_id.cluster_id.b64_std` in the `.tf` files. Generated values can have non-alphanumeric characters. For example, it could contain an equals sign. This is important because some AWS names can't contain those characters. For example, load balancer names.

Consideration will be given to swith to the first four characters of a UUID field. Or some other technique.

## Provision

```bash
./tfa
```

## Destroy

```bash
./tfd
```

## Show Outputs

```bash
terraform show
```

## List Terraform Files

```bash
terraform fmt
```
