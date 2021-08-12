# Hyper-V Lab Setup
 PowerShell scripts for creation of lab VMs in Hyper-V, it is not designed for Production use

 Requires parent VHDX of sysprep'd OS, differencing disks are used in VMs

 * Notes
 Best viewed in Microsoft Visual Studio Code with Colorful Comments extension installed
 Requires Hyper-V Role installed on your device (Works on Windows 10 - Enable the Hyper-V feature NB: Virtualisation needs to be enabled in BIOS)
 To create parent VHDX - Create a new Hyper-V VM and install the OS. At the OOBE screen (Entering of Country) press Ctrl + Shift + F3 to enter Audit Mode
 In Audit Mode install any Windows Updates and/or additional apps you require (reboot as required) when finished editing run sysprep with Enter OOBE | 
 Generalize | Shutdown - once shut down copy to the folder path e.g. C:\Hyper-V\Virtual Hard Disks and rename as required. Delete the parent VM
 You can now use this VHDX as the parent disk(s) for your VMs... If you require a isolated network create a private switch in Hyper-V and use pfsense VM
 to provide firewall / routing.  
 New-VMSwitch -Name "vSWI_172.70.70.x" -SwitchType "Private" -Notes "vSwitch for 172.70.70.0/24 Subnet"