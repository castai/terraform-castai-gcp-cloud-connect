terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.0"
    }
    restapi = {
      source  = "Mastercard/restapi"
      version = ">= 1.18"
    }
  }
}
