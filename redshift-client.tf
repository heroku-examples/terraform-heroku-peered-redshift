// deploy app to space
// create heroku postgres database, attach to app
// return redshift dburl as config var

# Create a new Heroku app
resource "heroku_app" "redshift_client" {
  name   = "${var.name}-redshift-client"
  space = "${heroku_space.default.name}"

  organization = {
    name = "${var.heroku_enterprise_team}"
  }
  region = "${lookup(var.aws_to_heroku_private_region, var.aws_region)}"

  config_vars {
    REDSHIFT_USERNAME = "${var.redshift_username}"
    REDSHIFT_PASSWORD = "${var.redshift_password}"
    REDSHIFT_DATABASE = "${var.redshift_dbname}"
    REDSHIFT_HOST = "${aws_redshift_cluster.tf_redshift_cluster.dns_name}"
  }

  buildpacks = [
    "heroku/nodejs"
  ]
}

resource "heroku_slug" "redshift_client" {
  app                            = "${heroku_app.redshift_client.id}"
  buildpack_provided_description = "Node.js"
  commit_description             = "manual slug build"
  file_path                      = "${var.redshift_client_app_slug_file_path}"

  process_types = {
    web = "npm start"
  }
}

resource "heroku_app_release" "redshift_client" {
  app     = "${heroku_app.redshift_client.id}"
  slug_id = "${heroku_slug.redshift_client.id}"
}

resource "heroku_formation" "redshift_client" {
  app        = "${heroku_app.redshift_client.id}"
  type       = "web"
  quantity   = "${var.redshift_client_app_count}"
  size       = "${var.redshift_client_app_size}"
  depends_on = ["heroku_app_release.redshift_client"]
}