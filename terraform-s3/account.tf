resource "yandex_iam_service_account" "service" {
	folder_id = var.folder_id
	name = var.account_name
}

resource "yandex_resourcemanager_folder_iam_member" "serivce_editor" {
	folder_id = var.folder_id
	role = "editor"
	member = "serviceAccount:${yandex_iam_service_account.service.id}"
}

resource "yandex_iam_service_account_static_access_key" "terraform_service_account_key" {
	service_account_id = yandex_iam_service_account.service.id
}

resource "yandex_storage_bucket" "tf-bucket" {
	bucket = "s3-bucket-mxssclxck"
	access_key = yandex_iam_service_account_static_access_key.terraform_service_account_key.access_key
	secret_key = yandex_iam_service_account_static_access_key.terraform_service_account_key.secret_key

	anonymous_access_flags {
		read = false
		list = false
	}

	force_destroy = true

provisioner "local-exec" {
	command = "echo export ACCESS_KEY=${yandex_iam_service_account_static_access_key.terraform_service_account_key.access_key} > ../terraform/backend.tfvars"
}
provisioner "local-exec" {
	command = "echo export SECRET_KEY=${yandex_iam_service_account_static_access_key.terraform_service_account_key.secret_key} >> ../terraform/backend.tfvars"
}
}