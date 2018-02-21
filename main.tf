variable "google_project" {}
variable "google_region" {}

data "google_compute_zones" "all" {}

provider "google" {
  project = "${var.google_project}"
  region  = "${var.google_region}"
}

resource "google_compute_instance_template" "test" {
  count        = 3
  machine_type = "n1-standard-1"

  disk {
    boot         = true
    source_image = "debian-cloud/debian-8"
  }

  network_interface {
    network = "default"

    access_config = {}
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_group_manager" "test" {
  count = 3

  name               = "test-${count.index+1}"
  base_instance_name = "test-${count.index+1}"

  instance_template = "${google_compute_instance_template.test.*.self_link[count.index]}"

  zone = "${data.google_compute_zones.all.names[count.index % length(data.google_compute_zones.all.names)]}"

  target_size = 1

  update_strategy = "RESTART"

  lifecycle {
    create_before_destroy = true
  }
}

data "google_compute_instance_group" "all" {
  count = 3
  name  = "${google_compute_instance_group_manager.test.*.name[count.index]}"
  zone  = "${google_compute_instance_group_manager.test.*.zone[count.index]}"
}

resource "google_compute_target_pool" "default" {
  name = "instance-pool"

  instances = ["${flatten(data.google_compute_instance_group.all.*.instances)}"]
}
