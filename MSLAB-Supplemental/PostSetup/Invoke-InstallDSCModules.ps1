<#
.SYNOPSIS
  Installs DSC PowerShell Modules on a server based on the role
.DESCRIPTION
  Installs DSC PowerShell Modules on a server based on the role
.PARAMETER None
  None
.INPUTS
  What Inputs  
.OUTPUTS
  What outputs
.NOTES
  Version:        1.0.0.0
  Author:         Steve McIntyre
  Creation Date:  08/09/2023
  Purpose/Change: Initial Release
.LINK
  None
.EXAMPLE
  ^ . Invoke-InstallDSCModules.ps1
  does what with example of cmdlet
  Invoke-InstallDSCModules.ps1

#>

#requires -version 4
#region ------------------------------------------------------[Script Parameters]--------------------------------------------------

Param (
  #Script parameters go here
)

#endregion
#region ------------------------------------------------------[Initialisations]----------------------------------------------------

#& Global Error Action
#$ErrorActionPreference = 'SilentlyContinue'

#& Module Imports
#Import-Module ActiveDirectory

#& Includes - Scripts & Modules
. Get-CommonFunctions.ps1                                                           # Include Common Functions

#endregion
#region -------------------------------------------------------[Declarations]------------------------------------------------------
# Script sourced variables for General settings and Registry Operations
$Script:Date        = Get-Date -Format yyyy-MM-dd                                   # Date format in yyyy-mm-dd
$Script:Now         = ''                                                            # script sourced veriable for Get-Now function
$Script:ScriptName  = 'Invoke-InstallDSCModules'                                    # Script Name used in the Open Dialogue
$Script:dest        = "$PSScriptRoot"                                               # Destination path
$Script:LogDir      = "$PSScriptRoot"                                               # Logdir for Clear-TransLogs function for $PSScript Root
$Script:LogFile     = $Script:LogDir + "\" + $Script:Date + "_" + $env:USERNAME + "_" + $Script:ScriptName + ".log"    # logfile location and name
$Script:BatchName   = ''                                                            # Batch name variable placeholder
$Script:GUID        = '2b45ab63-020d-476f-a480-1a3bd5ae9c1f'                        # Script GUID
  #^ Use New-Guid cmdlet to generate new script GUID for each version change of the script
[version]$Script:Version  = '1.0.0.0'                                               # Script Version Number

#endregion
#region --------------------------------------------------------[Hash Tables]------------------------------------------------------

#& any script specific hash tables that are not included in Get-CommonFunctions.ps1

#endregion
#region -------------------------------------------------------[Functions]---------------------------------------------------------

#endregion
#region ------------------------------------------------------------[Classes]-------------------------------------------------------------

#& any script specific classes that are not included in Get-CommonFunctions.ps1


#endregion
#region -----------------------------------------------------------[Execution]------------------------------------------------------------
<#
? ---------------------------------------------------------- [NOTES:] -------------------------------------------------------------
& Best veiwed and edited with Microsoft Visual Studio Code with colorful comments extension
^ Transcription logging formatting use the following functions to Write-Host messages
  Write-InfoMsg "Message" writes informational message as Write-Host "$Script:Now [INFORMATION] Information Message" format
  Write-InfoHighlightedMsg "Message" writes highlighted information message as Write-Host "$Script:Now [INFORMATION] Highlighted Information Message" format
  Write-SuccessMsg "Message" writes success message as Write-Host "$Script:Now [SUCCESS] Warning Message" format"
  Write-WarningMsg "Message" writes warning message as Write-Host "$Script:Now [WARNING] Warning Message" format
  Write-ErrorMsg "Message" writes error message as Write-Host "$Script:Now [ERROR] Error Message" format
  Write-ErrorAndExitMsg "Message" writes error message as Write-Host "$Script:Now [ERROR] Error Message" format and exits script
? ---------------------------------------------------------------------------------------------------------------------------------
#>

Start-Logging                                                                           # Start Transcription logging    

$result = Show-ConsoleDialog -Message 'Choose the DSC Server Role' -Title 'DSC Server Role' -Choice 'Basic','Certificate','DC','NDES','Web'
switch ($result){
  'Basic'{ 
    $ReqMods = @("xPSDesiredStateConfiguration", "xBitlocker", "ComputerManagementDsc", "WindowsDefender")
    Foreach ($mod in $ReqMods){Install-Module -Name $mod} 
  }
  'Certificate'{ 
    $ReqMods = @("xPSDesiredStateConfiguration", "xBitlocker", "ComputerManagementDsc", "WindowsDefender", "ActiveDirectoryCSDsc")
    Foreach ($mod in $ReqMods){Install-Module -Name $mod}
  }
  'DC'{ 
    $ReqMods = @("xPSDesiredStateConfiguration", "xBitlocker", "ComputerManagementDsc", "WindowsDefender", "ActiveDirectoryDsc", "DnsServerDsc")
    Foreach ($mod in $ReqMods){Install-Module -Name $mod}
  }
  'NDES'{ 
    $ReqMods = @("xPSDesiredStateConfiguration", "xBitlocker", "ComputerManagementDsc", "WindowsDefender")
    Foreach ($mod in $ReqMods){Install-Module -Name $mod}
  }
  'Web'{ 
    $ReqMods = @("xPSDesiredStateConfiguration", "xBitlocker", "ComputerManagementDsc", "WindowsDefender", "WebAdministrationDsc")
    Foreach ($mod in $ReqMods){Install-Module -Name $mod}
  }
}

<#
# DSC and modules
Install-Module -Name xPSDesiredStateConfiguration -RequiredVersion 9.1.0
Install-Module -Name xBitlocker -RequiredVersion 1.4.0.0
Install-Module -Name WindowsDefender
Install-Module -Name ActiveDirectoryCSDsc -RequiredVersion 5.0.0
Install-Module -Name ActiveDirectoryDsc
Install-Module -Name xDhcpServer
Install-Module -Name NetworkingDsc
Install-Module -Name HyperVDsc -AllowPrerelease
Install-Module -Name DnsServerDsc -RequiredVersion 3.0.0
Install-Module -Name WebAdministrationDsc
Install-Module -Name ComputerManagementDsc -AllowPrerelease
#>

Stop-Transcript
#endregion
#---------------------------------------------------------[Execution Completed]----------------------------------------------------------