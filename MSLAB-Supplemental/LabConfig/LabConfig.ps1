#^ Lab Configuration Settings
$LabConfig=@{
    DomainAdminName="LabAdmin";                     # Used during 2_CreateParentDisks (no affect if changed after this step)
    AdminPassword="LS1setup!";                      # Used during 2_CreateParentDisks. If changed after, it will break the functionality of 3_Deploy.ps1
    Prefix = "MSLab-";                              # (Optional) All VMs and vSwitch are created with this prefix, so you can identify the lab. If not specified, Lab folder name is used
    SwitchName = "vSWI_Lab";                        # (Optional) Name of vSwitch
    SecureBoot=$true;                               # (Optional) Useful when testing unsigned builds (Useful for MS developers for daily builds)
    DCEdition="4";                                  # 4 for DataCenter or 3 for DataCenterCore
    ServerISOFolder="$PSScriptRoot\_ISOs";          # (Optional) Path to Server ISO images
    ServerMSUsFolder="$PSScriptRoot\_MSUs";         # (Optional) Path to Server CU updates
    DCVMProcessorCount=2;                           # (Optional) Sets DC vCPU count (default is 2vCPUs)
    EnableGuestServiceInterface=$true;              # (Optional) If True, then Guest Services integration component will be enabled on all VMs. This allows simple file copy from host to guests.
    InstallSCVMM="No";                              # (Optional) Yes/Prereqs/SQL/ADK/No
    DomainNetbiosName="Corp";                       # (Optional) If set, custom domain NetBios name will be used. if not specified, Default "corp" will be used
    DomainName="Corp.contoso.com";                  # (Optional) If set, custom DomainName will be used. If not specified, Default "Corp.contoso.com" will be used
    DefaultOUName="Managed Objects";                # (Optional) If set, custom OU for all machines and account will be used. If not specified, default "Workshop" is created
    Internet=$true;                                 # (Optional) If $true, it will add external vSwitch and configure NAT in DC to provide internet (Logic explained below)
    CustomDnsForwarders=@("8.8.8.8","1.1.1.1");     # (Optional) If configured, script will use those servers as DNS fordwarders in DC (Defaults to 8.8.8.8 and 1.1.1.1)
    PullServerDC=$true;                             # (Optional) If $false, then DSC Pull Server will not be configured on DC
    DHCPscope="10.10.10.0";                         # (Optional) 10.0.0.0 is configured if nothing is specified. Scope has to end with .0 (like 10.10.10.0). It's always /24       
    TelemetryLevel="Full";                          # (Optional) If configured, script will stop prompting you for telemetry. Values are "None","Basic","Full"
    AutoStartAfterDeploy=$false;                    # (Optional) If $false, no VM will be started; if $true or 'All' all lab VMs will be started after Deploy script; if 'DeployedOnly' only newly created VMs will be started.
    AutoCleanUp=$false;                             # (Optional) If set, after creating initial parent disks, files that are no longer necessary will be cleaned up. Best suited for use in automated deployments.
    AdditionalNetworksConfig=@();                   # Just empty array for config below
    VMs=@()                                         # Just empty array for config below
}

#^ VM Creation
#& Create 2x VMs for Azure AD Connect
1..2 | ForEach-Object { 
    $VMNames="SVR-AADC";                         # Here you can bulk edit name of 2 VMs created. In this case will be SVR-AADC1,SVR-AADC2 created
    $LABConfig.VMs += @{
        VMName = "$VMNames$_" ;
        Configuration = 'Simple' ;               # Simple/S2D/Shared/Replica
        ParentVHD = 'Win2022_G2.vhdx';           # VHD Name from .\ParentDisks folder
        VMProcessorCount=2;                      # Set VMs to 2 VCPUs
        MemoryStartupBytes= 1GB;                 # Startup memory size
        vTPM=$true;                              # (Optional) if $true, vTPM will be enabled for virtual machine. Gen2 only.
        Generation=2;                            # (Optional) set VM generation to 2
        DisableWCF=$true;                        # (Optional) If $True, then Disable Windows Consumer Features registry is added= no consumer apps in start menu.
        AddToolsVHD=$true                        # Add Tools VHD to VM
    }
}

#& Management LabVM
$LABConfig.VMs += @{ VMName = 'SVR-MGT'; Configuration = 'Simple'; ParentVHD = 'Win2022_G2.vhdx'; MemoryStartupBytes= 2GB ; vTPM=$true ; DisableWCF=$true ; Generation=2 ; VMProcessorCount=2 ; AddToolsVHD=$true }
#& Windows Admin Centre LabVM
$LABConfig.VMs += @{ VMName = 'SVR-WAC'; Configuration = 'Simple'; ParentVHD = 'Win2022_G2.vhdx'; MemoryStartupBytes= 2GB ; vTPM=$true ; DisableWCF=$true ; Generation=2 ; VMProcessorCount=2 ; AddToolsVHD=$true }

<# Uncomment to Create Windows Client Lab VMs
#& Create 2x Windows 11 VMs
1..2 | ForEach-Object { 
    $VMNames="CLI-WIN-";                         # Here you can bulk edit name of 2 VMs created. In this case will be CLI-WIN-1,CLI-WIN-2 created
    $LABConfig.VMs += @{
        VMName = "$VMNames$_" ;
        Configuration = 'Simple' ;               # Simple/S2D/Shared/Replica
        ParentVHD = 'Windows11Pro.vhdx';         # VHD Name from .\ParentDisks folder
        VMProcessorCount=2;                      # Set VMs to 2 VCPUs
        MemoryStartupBytes= 2GB;                 # Startup memory size
        vTPM=$true;                              # (Optional) if $true, vTPM will be enabled for virtual machine. Gen2 only.
        Generation=2;                            # (Optional) set VM generation to 2
        DisableWCF=$true;                        # (Optional) If $True, then Disable Windows Consumer Features registry is added= no consumer apps in start menu.

    }
}

#& Create a domain joined (Offline Domain Join Blob) Windows 10 and Windows 11 Lab VM
$LABConfig.VMs += @{ VMName = 'CLI-WIN-01'; Configuration = 'Simple'; ParentVHD = 'Windows11Pro.vhdx'; MemoryStartupBytes= 2GB ; vTPM=$true ; DisableWCF=$true ; Generation=2 ; VMProcessorCount=2 }
$LABConfig.VMs += @{ VMName = 'CLI-WIN-02'; Configuration = 'Simple'; ParentVHD = 'Windows10Pro_22H2.vhdx'; MemoryStartupBytes= 2GB ; vTPM=$true ; DisableWCF=$true ; Generation=2 ; VMProcessorCount=2 }

#& Create a non-domain joined LAB VM - Use this if wanting to Azure AD Domain Join a device
$LABConfig.VMs += @{ VMName = 'CLI-WIN-03'; Configuration = 'Simple'; ParentVHD = 'Windows11Pro.vhdx'; MemoryStartupBytes= 2GB ; vTPM=$true ; DisableWCF=$true ; Generation=2 ; VMProcessorCount=2; Unattend="None" }

#>