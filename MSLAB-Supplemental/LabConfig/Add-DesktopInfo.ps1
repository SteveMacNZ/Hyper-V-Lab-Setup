<#
.SYNOPSIS
  Mounts MS Lab parent image and copies Desktop Info
.DESCRIPTION
  Mounts MS Lab parent image and copies Desktop Info 
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
  ^ . Add-DesktopInfo.ps1
  does what with example of cmdlet
  Add-DesktopInfo.ps1

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
$Script:ScriptName  = 'Add-DesktopInfo'                                             # Script Name used in the Open Dialogue
$Script:dest        = "$PSScriptRoot\Exports"                                       # Destination path
$Script:LogDir      = "$PSScriptRoot"                                               # Logdir for Clear-TransLogs function for $PSScript Root
$Script:LogFile     = $Script:LogDir + "\" + $Script:Date + "_" + $env:USERNAME + "_" + $Script:ScriptName + ".log"    # logfile location and name
$Script:BatchName   = ''                                                            # Batch name variable placeholder
$Script:GUID        = 'ab69bec7-7f02-4dbe-aa02-534e58bb4d00'                        # Script GUID
  #^ Use New-Guid cmdlet to generate new script GUID for each version change of the script
[version]$Script:Version  = '1.0.0.0'                                               # Script Version Number

[String]$Script:SName = "Desktop Info"                                              # Shortcut Name
[String]$Script:SPath = ""                                                          # Shorcut path location
[String]$Script:SArgs = ""                                                          # Shortcut Arguments
[String]$Script:SDesc = "Desktop Info"                                              # Shortcut Description
[String]$Script:SFN = ""                                                            # Shortcut Full Name
[String]$Script:SHT = ""                                                            # Shortcut Hotkey
[String]$Script:SIL = "C:\ProgramData\DesktopInfo\DesktopInfo64.exe"                # Shortcut Icon Location
[String]$Script:SRP = ""                                                            # Shortcut Relative Path
[String]$Script:STP = "C:\ProgramData\DesktopInfo\DesktopInfo64.exe"                # Shortcut Target Path
[String]$Script:SWD = "C:\ProgramData\DesktopInfo"                                  # Shortcut Working directory
[Int32]$Script:SWS = "1"                                                            # Window Start Size 1=Norm, 3=Maximized, 7=Minimized

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

Write-InfoMsg "Mounting Parent Disk Image"
# Mounts Parent VHDX and sets drive path
$DriveLetter = (Mount-VHD -Path "$PSScriptRoot\ParentDisks\Win2022_G2.vhdx" -PassThru | Get-Disk | Get-Partition | Get-Volume).DriveLetter
$DrivePath = $DriveLetter + ":"                                                         # Create drive path

# Copy DesktopInfo to VHDX
Try{
    Write-InfoMsg "Copying DesktopInfo to Parent Disk Image"
    Copy-Item -Path "$PSScriptRoot\Temp\ToolsVHD\Installers\DesktopInfo\*" -Destination "$DrivePath\ProgramData\DesktopInfo" -Recurse
}
Catch{
    Write-ErrorMsg "Error copying DesktopInfo to Parent VHDX"
    Write-Host $PSItem.Exception.Message -ForegroundColor RED  
}
Finally{
    $Error.Clear()                                                                                  # Clear error log
}

# Create Shortcut in All Users Startup
$Script:SPath = "$DriveLetter\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\$Script:SName.lnk"  # Shorcut path location

Try{
    Get-Now
    Write-InfoMsg "Creating DesktopInfo start menu shortcut"

    $WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut("$Script:SPath")
    if ($Script:STP){$Shortcut.TargetPath = $Script:STP}
    if ($Script:SArgs){$Shortcut.Arguments = "$Script:SArgs"}
    if ($Script:SWS){$ShortCut.WindowStyle = $Script:SWS}
    if ($Script:SDesc){$Shortcut.Description = "$Script:SDesc"}
    if ($Script:SWD){$Shortcut.WorkingDirectory ="$Script:SWD"}
    if ($Script:SIL){$Shortcut.IconLocation = $Script:SIL}
    if ($Script:SRPL){$Shortcut.RelativePath = $Script:SRP}
    if ($Script:SHT){$Shortcut.Hotkey = $Script:SHT}
    if ($Script:SFN){$Shortcut.FullName = $Script:SFN}
    $Shortcut.Save() 
}
Catch{
    Write-ErrorMsg "Error creating Start up Shortcut"
    Write-Host $PSItem.Exception.Message -ForegroundColor RED  
}
Finally{
    $Error.Clear()                                                                                  # Clear error log
}



Write-InfoMsg "Dismounting Parent Disk Image"
Dismount-VHD -Path "$PSScriptRoot\ParentDisks\Win2022_G2.vhdx"                          # Dismounts parent VHDX

Stop-Transcript
#endregion
#---------------------------------------------------------[Execution Completed]----------------------------------------------------------