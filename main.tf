terraform {
  required_version = "1.5.2"
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.94.0"
    }
  }
  backend "s3" {
    endpoint                    = "storage.yandexcloud.net"
    bucket                      = "tfbucketsfstudy"
    region                      = "ru-central1"
    key                         = "terraform.tfstate"
    access_key                  = "<access_key>"
    secret_key                  = "<secret_key>"
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  service_account_key_file = "./service-admin.json"
  cloud_id                 = "<cloud_id>"
  folder_id                = "<folder_id>"
  zone                     = "ru-central1-a"
}

resource "yandex_vpc_network" "network_1" {
  name = "network_1"
}

resource "yandex_vpc_subnet" "subnet_1" {
  name           = "subnet_1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network_1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

module "lemp" {
  source                = "./modules"
  instance_family_image = "lemp"
  vpc_subnet_id         = yandex_vpc_subnet.subnet_1.id
  vpc_ip_address        = "192.168.10.10"
}

module "lamp" {
  source                = "./modules"
  instance_family_image = "lamp"
  vpc_subnet_id         = yandex_vpc_subnet.subnet_1.id
  vpc_ip_address        = "192.168.10.12"
}



resource "yandex_lb_target_group" "group-one" {
  name = "group-one"
  target {
    subnet_id = yandex_vpc_subnet.subnet_1.id
    address   = "192.168.10.10"
  }
  target {
    subnet_id = yandex_vpc_subnet.subnet_1.id
    address   = "192.168.10.12"
  }
}

resource "yandex_lb_network_load_balancer" "balancer_one" {
  name = "balancerone"
  listener {
    name = "listenerone"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }
  attached_target_group {
    target_group_id = yandex_lb_target_group.group-one.id
    healthcheck {
      name = "healthone"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}