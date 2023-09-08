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
#. Get-CommonFunctions.ps1                                 # Include Common Functions

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

Function Get-Now{
    # PowerShell Method - uncomment below is .NET is unavailable
    #$Script:Now = (get-date).tostring("[dd/MM HH:mm:ss:ffff]")
    # .NET Call which is faster than PowerShell Method - comment out below if .NET is unavailable
    $Script:Now = ([DateTime]::Now).tostring("[dd/MM HH:mm:ss:ffff]")
}
  
Function Write-InfoMsg ($message) {
    Get-Now                                                                                       # Get currnet date timestamp
    Write-Host "$Script:Now [INFORMATION] $message"                                               # Display Information messge
    $null = $Script:Now                                                                           # Reset timestamp
}
Function Write-InfoHighlightedMsg ($message) {
    Get-Now                                                                                       # Get currnet date timestamp
    Write-Host "$Script:Now [INFORMATION] $message" -ForegroundColor Cyan                         # Display highlighted Information message
    $null = $Script:Now                                                                           # Reset timestamp
}
    
Function Write-WarningMsg ($message) {
    Get-Now                                                                                       # Get currnet date timestamp
    Write-Host "$Script:Now [WARNING] $message" -ForegroundColor Yellow                           # Display Warning Message
    $null = $Script:Now                                                                           # Reset timestamp
}
    
Function Write-SuccessMsg ($message) {
    Get-Now                                                                                       # Get currnet date timestamp
    Write-Host "$Script:Now [SUCCESS] $message" -ForegroundColor Green                            # Display Success Message
    $null = $Script:Now                                                                           # Reset timestamp
}
    
Function Write-ErrorMsg ($message) {
    Get-Now                                                                                       # Get currnet date timestamp
    Write-Host "$Script:Now [ERROR] $message" -ForegroundColor Red                                # Display Error Message
    $null = $Script:Now                                                                           # Reset timestamp
}

function Show-ConsoleDialog{
    <#
    .SYNOPSIS
      displays a console message with result returned into a switch statement
    .DESCRIPTION
      displays a console message with result returned into a switch statement
    .PARAMETER Message
      Message to be displayed
    .PARAMETER Title
      Title of the dialogue message
    .PARAMETER Choice
      choice options comma seperated    
    .INPUTS
      None
    .OUTPUTS
      returns result
    .NOTES
      $result = Show-ConsoleDialog -Message 'Restarting Server?' -Title 'Will restart server for maintenance' -Choice 'Yes','Cancel' ,'Later','Never','Always'
      switch ($result){
      'Yes'        { 'restarting' }
      'Cancel'     { 'doing nothing' }
      'Later'      { 'ok, later' }
      'Never'      { 'will not ask again' }
      'Always'     { 'restarting without notice now and ever' }
      }
    .LINK
      None
    .EXAMPLE
      ^ . Show-ConsoleDialog -Message "What you want to Do?" -Title "Question" -Choice 'Yes', 'No', 'Cancel', 'Abort'
      shows console dialog message with options
    #>  
      param(
        [Parameter(Mandatory)]
        [string]$Message,
        [string]$Title = 'PowerShell',
        # do not use choices with duplicate first letter
        # submit any number of choices you want to offer
        [string[]]
        $Choice = ('Yes', 'No', 'Cancel')
      )
      
      # turn choices into ChoiceDescription objects
      $choices = foreach ($_ in $choice){
        [System.Management.Automation.Host.ChoiceDescription]::new("&$_", $_)
      }
      
      # translate the user choice into the name of the chosen choice
      $choices[$host.ui.PromptForChoice($title, $message, $choices, 0)]. Label.Substring(1)
}
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
    'Basic'         { $ReqMods = @("xPSDesiredStateConfiguration", "xBitlocker", "ComputerManagementDsc", "WindowsDefender")
                        Foreach ($mod in $ReqMods){Install-Module -Name $mod} 
    }
    'Certificate'   { $ReqMods = @("xPSDesiredStateConfiguration", "xBitlocker", "ComputerManagementDsc", "WindowsDefender", "ActiveDirectoryCSDsc")
                        Foreach ($mod in $ReqMods){Install-Module -Name $mod}
    }
    'DC'            { $ReqMods = @("xPSDesiredStateConfiguration", "xBitlocker", "ComputerManagementDsc", "WindowsDefender", "ActiveDirectoryDsc", "DnsServerDsc")
                        Foreach ($mod in $ReqMods){Install-Module -Name $mod}
    }
    'NDES'          { $ReqMods = @("xPSDesiredStateConfiguration", "xBitlocker", "ComputerManagementDsc", "WindowsDefender")
                        Foreach ($mod in $ReqMods){Install-Module -Name $mod}
    }
    'Web'           { $ReqMods = @("xPSDesiredStateConfiguration", "xBitlocker", "ComputerManagementDsc", "WindowsDefender", "WebAdministrationDsc")
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