variable "bucket_name" {
    type = string
    description = "Name of the S3 bucket"
}

variable "block_public_access" {
    type = bool
    description = "Access control level of the bucket"
    default = true
}
