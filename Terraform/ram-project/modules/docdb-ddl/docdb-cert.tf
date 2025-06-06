resource "terraform_data" "get_cert" {
  provisioner "local-exec" {
    command = "curl -s -o ./global-bundle.pem ${var.docdb_ddl_wget_loc}"
  }
}