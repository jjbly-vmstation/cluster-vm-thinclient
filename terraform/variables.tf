variable "vmws_url" { 
  description = "VMware Workstation API URL"
  type        = string
  default     = "http://127.0.0.1:8697/api" 
}

variable "vmws_user" { 
  description = "VMware Workstation API User"
  type        = string
  default     = "vmadmin" 
}

variable "vmws_pass" { 
  description = "VMware Workstation API Password"
  type        = string
  sensitive   = true 
}

variable "vm_name" { 
  description = "Name of the Virtual Machine"
  type        = string 
}

variable "vm_description" { 
  description = "Description of the Virtual Machine"
  type        = string 
  default     = "Enterprise - Massgrave Activated"
}

variable "processors" { 
  description = "Number of vCPUs"
  type        = number
  default     = 4
}

variable "memory" { 
  description = "Memory in MB"
  type        = number
  default     = 12288
}

variable "sourceid" { 
  description = "Path to the Packer-generated VMX template"
  type        = string 
}

variable "dest_path" { 
  description = "Destination path for the new VMX file"
  type        = string 
}

