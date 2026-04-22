terraform {
  required_version = "1.14.2"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.0"
    }
  }
}

resource "random_string" "example" {
  length  = 16
  special = false
}
