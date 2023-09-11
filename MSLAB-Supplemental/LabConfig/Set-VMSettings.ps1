<#
.SYNOPSIS
  Configures LAB VM max/min memory and VM behaviour, adds virtual DVD drive to allow mounting ISOs
.DESCRIPTION
  Configures LAB VM max/min memory and VM behaviour, adds virtual DVD drive to allow mounting ISOs. Uses Lab prefix from labconfig.ps1 to apply only to matching VMs
.PARAMETER None
  None
.INPUTS
  None  
.OUTPUTS
  None
.NOTES
  Version:        1.0.0.0
  Author:         Steve McIntyre
  Creation Date:  11/09/2023
  Purpose/Change: Initial Release
.LINK
  None
.EXAMPLE
  ^ . Set-VMSettings.ps1
  does what with example of cmdlet
  Set-VMSettings.ps1

#>

. "$PSScriptRoot\LabConfig.ps1"                                                     # Load LabConfig....
$LABPrefix = $LabConfig.Prefix + "*"                                                # Set VM Prefix for VM Names
$Min = '512MB'                                                                      # Minimum Memory 
$Max = '4GB'                                                                        # Set Max Memory

$VMs = Get-VM | Select-Object -ExpandProperty Name                                  # Get All VM Names in Hyper-V

Foreach ($vm in $VMs){
    #Write-host $vm
    If ($vm -Like "$LABPrefix"){
        Write-host "Setting VM Configuration for $vm"
        Set-VM -Name $vm -DynamicMemory -MemoryMinimumBytes (Invoke-Expression $Min) -MemoryMaximumBytes (Invoke-Expression $Max) -AutomaticStartDelay '0' -AutomaticStopAction Shutdown -AutomaticStartAction Nothing -AutomaticCheckpointsEnabled $false
        Add-VMDvdDrive -VMName $vm
    }
}
