variable "vmws_url" { default = "http://127.0.0.1:8697/api" }
variable "vmws_user" { default = "vmadmin" }
variable "vmws_pass" { type = string }

variable "vm_name" { type = string }
variable "vm_description" { 
  type = string 
  default = "Enterprise - Massgrave Activated"
}
variable "processors" { 
  type = number
  default = 4
}
variable "memory" { 
  type = number
  default = 12288
}
variable "sourceid" { type = string }
variable "dest_path" { type = string }