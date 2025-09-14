variable "terraform_sa_email" {
  description = "Service account email used by Terraform to create resources in the project."
  type        = string
  default     = "" # Set via -var or tfvars.
  validation {
    condition     = length(var.terraform_sa_email) > 5
    error_message = "You must set terraform_sa_email to a valid service account email before apply."
  }
}
