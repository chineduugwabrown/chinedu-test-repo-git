variable "terraform_sa_email" {
  description = "Service account email used by Terraform to create resources in the project."
  type        = string
  default     = "lekcub-dev-test@lekcub-project-1.iam.gserviceaccount.com" # Set via -var or tfvars.
  validation {
    condition     = length(var.terraform_sa_email) > 5
    error_message = "You must set terraform_sa_email to a valid service account email before apply."
  }
}

variable "manage_project_iam" {
  description = "Whether Terraform should attempt to grant IAM roles on the project (requires owner or project IAM admin privileges)."
  type        = bool
  default     = false
}
