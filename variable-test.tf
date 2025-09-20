variable "admin_principal" {
  description = "The principal that is granted the admin role on the tenant project."
  type        = string
}

variable "billing_account" {
  description = "The specific billing account associated with the tenant projects. If specified it will be used. If null then the core.billing_account.id will be used."
  type        = string
}

variable "core" {
  description = "System core attributes. Curated subset of bootstrap and resman tfvars"
  type = object({
    automation = object({
      project_id = string
    })
    billing_account = object({
      id           = string
      is_org_level = bool
      no_iam       = bool
    })
    cidrs = object({
      primary = object({
        prod = object({
          gss     = string
          landing = string
        })
        staging = object({
          gss     = string
          landing = string
        })
      })
      secondary = object({
        prod = object({
          gss     = string
          landing = string
        })
        staging = object({
          gss     = string
          landing = string
        })
      })
    })
    crypto_key_rotation_period_seconds = string
    organization = object({
      id          = number
      customer_id = string
      domain      = string
    })
    prefix = string
    service_accounts = object({
      networking  = string
      gss-prod    = string
      gss-staging = string
    })
    regions = object({
      primary   = string
      secondary = string
    })
    outputs_bucket = string
    projects = object({
      gss-prod = object({
        folder          = string
        project_id      = string
        service_account = string
        gcs_bucket      = string
      })
      gss-staging = object({
        folder          = string
        project_id      = string
        service_account = string
        gcs_bucket      = string
      })
    })
  })
}

variable "descriptive_name" {
  description = "The descriptive name of the tenant project."
  type        = string
}

variable "tenant_automation" {
  description = "The automation attributes for the tenant"
  type = object({
    core_bucket          = string
    core_sa              = string
    outputs_bucket       = string
    prod_sa              = string
    prod_state_bucket    = string
    project_id           = string
    staging_sa           = string
    staging_state_bucket = string
    state_bucket         = string
  })
}

variable "tenant_folder_ids" {
  description = "The folder IDs to use for the tenant projects"
  type = object({
    prod    = string
    staging = string
    core    = string
    top     = string
  })
}

variable "tenant_cidrs" {
  description = "The CIDRs to use for the tenant prod and staging projects."
  type = object({
    primary = object({
      prod    = string
      staging = string
    })
    secondary = object({
      prod    = string
      staging = string
    })
  })
}

variable "tenant_id" {
  description = "The tenant ID defined in resman."
  type        = number
}

variable "tenant_prefix" {
  description = "The prefix to use for resources in the tenant project."
  type        = string
}

variable "tenant_shortname" {
  description = "The shortname of the tenant project."
  type        = string
}

variable "tenant_tag_values" {
  description = "The tag values to use for the tenant project."
  type        = object({})
}

variable "tenant_resman_project_ids" {
  description = "The project IDs of the tenant projects."
  type = object({
    prod    = string
    staging = string
  })
}

variable "tenant_resman_project_numbers" {
  description = "The project numbers of the tenant projects."
  type = object({
    prod    = number
    staging = number
  })
}

variable "tenant_resman_project_vpc_self_links" {
  description = "The self links of the tenant VPCs configured by tenant resman"
  type = object({
    prod    = string
    staging = string
  })
}

variable "environment" {
  description = "The environment to deploy the tenant project to."
  type        = string
  validation {
    condition     = contains(["prod", "staging"], var.environment)
    error_message = "The environment must be either 'prod' or 'staging'."
  }
}

variable "armory_images" {
  description = "Armory-provided images for optional use within tenant projects"
  type = object({
    stig_rhel8_golden_image_name = string
    stig_rhel8_snapshot_selflink = string
  })
}

variable "tenant_resman_armory_ssl_policy_self_links" {
  description = "The self links of the tenant armory SSL policies configured by tenant resman stage. Use for all load balancers"
  type = object({
    prod = object({
      primary   = string
      secondary = string
    })
    staging = object({
      primary   = string
      secondary = string
    })
  })
}

variable "sftp_outbound_thru_nat" {
  description = "Boolean to determine if SFTP outbound traffic should go through Cloud NAT"
  type        = bool
  default     = true
}

variable "public_subdomain" {
  description = <<EOT
Used to build the public-facing domain name used for the resources created 
in this repo. The map contains values for each environment ("prod" and "staging"). 
For example, if the base domain is "example.com" and the value for "prod" is "clarity",
the resulting public domain will be "clarity.example.com".
EOT
  type        = map(string)
  default = {
    prod    = "clarity"
    staging = "staging-clarity"
  }
}
