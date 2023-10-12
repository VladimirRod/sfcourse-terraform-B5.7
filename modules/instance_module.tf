terraform {
  required_version = "1.5.2"
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.94.0"
    }
  }
}

provider "yandex" {
  service_account_key_file = "./service-admin.json"
  cloud_id                 = "<cloud_id>"
  folder_id                = "<folder_id>"
  zone                     = "ru-central1-a"
}

data "yandex_compute_image" "image" {
  family = var.instance_family_image
}

resource "yandex_compute_instance" "vm" {
  name = "terraform-${var.instance_family_image}"
  platform_id = "standard-v3"

  resources {
	cores  = 2
	memory = 2
	core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.image.id
	}
  }
  network_interface {
    subnet_id = var.vpc_subnet_id
    ip_address = var.vpc_ip_address
	nat = true
  }
  metadata = {
    user-data = "${file("cloud-init.yaml")}"
  }
}
