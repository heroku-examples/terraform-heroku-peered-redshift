output "redshift_url" {
  value = "${aws_redshift_cluster.tf_redshift_cluster.dns_name}"
}

output "heroku_app_name" {
  value = "${heroku_app.redshift_client.name}"
}