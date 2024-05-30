resource "aws_s3_bucket" "data_bucket" {
    bucket = var.bucket_name
}
resource "aws_s3_bucket_public_access_block" "bucket_acl" {
  bucket = aws_s3_bucket.data_bucket.id
  block_public_acls   = var.block_public_access
  block_public_policy = var.block_public_access
}

output "bucket_arn" {
  value = aws_s3_bucket.data_bucket.arn
}

output "bucket_id" {
  value = aws_s3_bucket.data_bucket.id
}