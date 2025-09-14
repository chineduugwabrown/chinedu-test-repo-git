variable "terraform_sa_email" {
  description = "Service account email used by Terraform to create resources in the project."
  type        = string
  default     = "" # Set via -var or tfvars; leave empty to force explicit assignment.
}
