terraform {
	backend "s3" {
		endpoint = "storage.yandexcloud.net"
		bucket = "s3-bucket-mxssclxck"
		region = "ru-central1"
		key = "s3-bucket-mxssclxck/terraform.tfstate"
		skip_region_validation = true
		skip_credentials_validation = true
		skip_metadata_api_check = false
	}
}