vmws_url       = "http://127.0.0.1:8697/api"
vmws_user      = "vmadmin"
# vmws_pass is omitted here for security; pass it via CLI or environment variable (TF_VAR_vmws_pass)
vm_name        = "win11-production"
vm_description = "Production - Office/Visio - Activated"
processors     = 4
memory         = 12288
sourceid       = "/mnt/media/iso/win11e/win11-template.vmx"
dest_path      = "/mnt/storage/vmware/win11-production/win11-production.vmx"