variable "cluster_name" {
  type = string
}

variable "region" {
  type = string
}

variable "oidc_url_id" {
  type = string
  description = "Only the ID part from the OIDC URL: e.g. 60B90A48D1B25CC82ACF59C456653C13"
}

variable "account_id" {
  type = string
}