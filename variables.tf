variable "vpc_cidr" {
  type = string
}

variable "linux_image" {
  type = string
}

variable "key_pair" {
  type = string
}

variable "task_definition_role" {
  type = string
}

variable "image_name" {
  type = string
}

variable "image_uri" {
  type = string
}

variable "app_envs" {
  type = list(map(string))
}
