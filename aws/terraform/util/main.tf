# ---
# File is not yet used

variable "az_char" {
  type = "map"
  default = {
    "a" = "1"
    "b" = "2"
    "c" = "3"
  }
}

variable "amis" {
  type = "map"
  default = {
    "us-east-1" = "ami-b374d5a5"
    "us-west-2" = "ami-4b32be2b"
  }
}
