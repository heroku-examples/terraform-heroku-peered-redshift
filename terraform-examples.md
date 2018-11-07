# Terraform example

```
terraform init

terraform plan \
  -var name=$deployment_name \
  -var aws_region=us-west-2

terraform apply \
  -var name=$deployment_name \
  -var aws_region=us-west-2
```


# Destroy Resources Examples

```
# destroy everything
terraform destroy \
  -var name=$deployment_name \
  -var aws_region=us-west-2

# destroy redshift subnet group
terraform destroy -target aws_redshift_subnet_group.my_redshift_subnet_group \
 -var name=$deployment_name \
 -var aws_region=us-west-2

# destroy redshift cluster
terraform destroy -target aws_redshift_cluster.tf_redshift_cluster \
 -var name=$deployment_name \
 -var aws_region=us-west-2

# destroy redshift client heroku app
terraform destroy -target heroku_app.redshift_client \
 -var name=$deployment_name \
 -var aws_region=us-west-2
```