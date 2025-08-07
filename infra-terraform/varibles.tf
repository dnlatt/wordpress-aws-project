variable "region" {
  description = "AWS region"
  default     = "ap-southeast-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "ami" {
  description = "Amazon Linux 2 AMI ID"
  default     = "ami-0df7a207adb9748c7"
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  default     = "wordpress-s3-latt"
}
