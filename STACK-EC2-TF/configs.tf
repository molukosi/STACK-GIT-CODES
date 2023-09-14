data "template_file" "bootstrap" {
  template = file(format("%s/scripts/bootstrap.tpl", path.module))

  vars = {
    GIT_REPO          = "https://github.com/stackitgit/CliXX_Retail_Repository.git",
    STACK_CLIXX_EFS   = aws_efs_file_system.stack-clixx-EFS.id,
    LOAD_BALANCER_DNS = aws_lb.clixx-app-load-balancer.dns_name,
    DATABASE          = locals.db_creds.DB_NAME,
    USER              = locals.db_creds.DB_USER,
    PASSWORD          = locals.db_creds.DB_PASSWORD,
    RDS_ENDPOINT      = split(":", aws_db_instance.clixx-retail-app.endpoint)[0],
    ORIGINAL_ENDPOINT = locals.db_creds.OLD_ENDPOINT
  }
}

output "rendered_script" {
  value = data.template_file.bootstrap.rendered
}