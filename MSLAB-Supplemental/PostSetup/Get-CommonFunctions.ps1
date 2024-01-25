<#
.SYNOPSIS
  Common Function Include Script
.DESCRIPTION
  Common Functions Include Script - containing common functions to be imported into the migration scripts using the 
.PARAMETER None
  None
.INPUTS
  None
.OUTPUTS
  None
.NOTES
  Version:        1.0
  Author:         Steve McIntyre
  Creation Date:  13/09/2022
  Purpose/Change: Initial Release
.LINK
  None
.EXAMPLE
  ^ . Get-CommonFunctions.ps1
  To import standard common Functions script as an include

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
#. .\Get-CommonFunctions.ps1                          # Include Common Functions

#endregion
#region -------------------------------------------------------[Declarations]------------------------------------------------------

# Script sourced variables for General settings and Registry Operations
$Script:Date        = Get-Date -Format yyyy-MM-dd                                   # Date format in yyyy-mm-dd
$Script:Now         = ''                                                            # script sourced veriable for Get-Now function
$Script:ScriptName  = ''                                                            # Script Name used in the Open Dialogue
$Script:dest        = $PSScriptRoot                                                 # Destination path
$Script:LogDir      = $PSScriptRoot                                                 # Logdir for Clear-TransLogs function for $PSScript Root
$Script:LogFile     = $Script:LogDir + "\" + $Script:Date + "_" + $env:USERNAME + "_" + $Script:ScriptName + ".log"    # logfile location and name
$Script:BatchName   = ''                                                            # Batch name variable placeholder
$Script:GUID        = '00000000-0000-0000-0000-000000000000'                        # Script GUID
  #^ Use New-Guid cmdlet to generate new script GUID for each version change of the script
[version]$Script:Version  = '0.0.0.0'                                               # Script Version Number
$Script:Client      = ''                                                            # Set Client Name - Used in Registry Operations
$Script:WHO         = whoami                                                        # Collect WhoAmI
$Script:Desc        = ""                                                            # Description displayed in Get-ScriptInfo function
$Script:Desc2       = ""                                                            # Description2 displayed in Get-ScriptInfo function
$Script:PSArchitecture = ''                                                         # Place holder for x86 / x64 bit detection
$Script:PSx32       = "$env:systemroot\SysWOW64\WindowsPowerShell\v1.0\powershell.exe" # PowerShell x86
$Script:PSx64       = "$env:systemroot\system32\WindowsPowerShell\v1.0\powershell.exe" # PowerShell x64

#^ File Picker / Folder Picker Setup
$Script:File  = ''                                                                  # File var for Get-FilePicker Function
$Script:FPDir       = '$PSScriptRoot'                                               # File Picker Initial Directory
$Script:FileTypes   = "Text files (*.txt)|*.txt|CSV File (*.csv)|*.csv|All files (*.*)|*.*" # File types to be listed in file picker
$Script:FileIndex   = "2"                                                           # What file type to set as default in file picker (based on above order)

#endregion
#region --------------------------------------------------------[Hash Tables]------------------------------------------------------

#* Hash table for Write-Host Errors to be used as spatted
$cerror = @{ForeGroundColor = "Red"; BackgroundColor = "white"}
#* Hash table for Write-Host Warnings to be used as spatted
$cwarning = @{ForeGroundColor = "Magenta"; BackgroundColor = "white"}
#* Hash table for Write-Host highlighted to be used as spatted
$chighlight = @{ForeGroundColor = "Blue"; BackgroundColor = "white"}

#* Hash table for Write-Host green text to be used as spatted
$tgreen = @{ForeGroundColor = "Green"}
#* Hash table for Write-Host red text to be used as spatted
$tred = @{ForeGroundColor = "Red"}

#^ Dummy Write-host for spatted formatting
Write-Host @chighlight
Write-Host @cwarning
Write-Host @cerror
Write-Host @tgreen
Write-Host @tred

#endregion
#region -------------------------------------------------------[Functions]---------------------------------------------------------

#& Start Transcriptions
Function Start-Logging{
  try {
    Stop-Transcript | Out-Null
  } catch [System.InvalidOperationException] { }                                     # jobs are running
  $ErrorActionPreference = "Continue"                                                # Set Error Action Handling
  Get-Now                                                                            # Get current date time
  Start-Transcript -path $Script:LogFile -IncludeInvocationHeader -Append            # Start Transcription append if log exists
  Write-Host ''                                                                      # write Line spacer into Transcription file
  Write-Host ''                                                                      # write Line spacer into Transcription file
  Write-Host "================================================================================" 
  Write-Host "================== $Script:Now Processing Started ====================" 
  Write-Host "================================================================================"  
  Write-Host ''

  Write-Host ''                                                                       # write Line spacer into Transcription file
}

#& Date time formatting for timestamped updated
Function Get-Now{
  # PowerShell Method - uncomment below is .NET is unavailable
  #$Script:Now = (get-date).tostring("[dd/MM HH:mm:ss:ffff]")
  # .NET Call which is faster than PowerShell Method - comment out below if .NET is unavailable
  $Script:Now = ([DateTime]::Now).tostring("[dd/MM HH:mm:ss:ffff]")
}

#& Updated function for informational messages
Function Write-InfoMsg ($message) {
  Get-Now                                                                             # Get currnet date timestamp
  Write-Host "$Script:Now [INFORMATION] $message"                                     # Display Information messge
  $null = $Script:Now                                                                 # Reset timestamp
}
 
#& Updated function for informational highlighted messages
Function Write-InfoHighlightedMsg ($message) {
  Get-Now                                                                             # Get currnet date timestamp
  Write-Host "$Script:Now [INFORMATION] $message" -ForegroundColor Cyan               # Display highlighted Information message
  $null = $Script:Now                                                                 # Reset timestamp
}

#& Updated function for warning messages
Function Write-WarningMsg ($message) {
  Get-Now                                                                             # Get currnet date timestamp
  Write-Host "$Script:Now [WARNING] $message" -ForegroundColor Yellow                 # Display Warning Message
  $null = $Script:Now                                                                 # Reset timestamp
}

#& Updated function for Success messages
Function Write-SuccessMsg ($message) {
  Get-Now                                                                              # Get currnet date timestamp
  Write-Host "$Script:Now [SUCCESS] $message" -ForegroundColor Green                   # Display Success Message
  $null = $Script:Now                                                                  # Reset timestamp
}

#& Updated function for error messages
Function Write-ErrorMsg ($message) {
  Get-Now                                                                              # Get currnet date timestamp
  Write-Host "$Script:Now [ERROR] $message" -ForegroundColor Red                       # Display Error Message
  $null = $Script:Now                                                                  # Reset timestamp
}

#& Updated function for error and exit messages
Function Write-ErrorAndExitMsg ($message) {
  Get-Now                                                                                       # Get currnet date timestamp
  Write-Host "$Script:Now [ERROR] $message" -ForegroundColor Red                                # Display Error Message
  $null = $Script:Now                                                                           # Reset timestamp
  Write-Host "Press enter to continue ..."                                                      # Display user prompt
  Stop-Transcript                                                                               # Stop transcription
  Read-Host | Out-Null                                                                          # Wait for user prompt
  Exit                                                                                          # Terminte script }
}  

#& Clean up log files in script root older than 15 days
Function Clear-TransLogs{
  Get-Now
  Write-Host "$Script:Now - Cleaning up transaction logs over 15 days old" @cwarning
  Get-ChildItem $Script:LogDir -recurse "*$Script:ScriptName.log" -force | Where-Object {$_.lastwritetime -lt (get-date).adddays(-15)} | Remove-Item -force
}

#& FilePicker function for selecting input file via explorer window
Function Get-FilePicker {
  Param ()
  [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
  $ofd = New-Object System.Windows.Forms.OpenFileDialog
  $ofd.InitialDirectory = $Script:FPDir                                                         # Sets initial directory to script root
  $ofd.Title            = "Select file for $Script:ScriptName"                                  # Title for the Open Dialogue
  $ofd.Filter           = $Script:FileTypes                                                     # File Types filter
  $ofd.FilterIndex      = $Script:FileIndex                                                     # What file type to default to
  $ofd.RestoreDirectory = $true                                                                 # Reset the directory path
  #$ofd.ShowHelp         = $true                                                                 # Legacy UI              
  $ofd.ShowHelp         = $false                                                                # Modern UI
  if($ofd.ShowDialog() -eq "OK") { $ofd.FileName }
  $Script:File = $ofd.Filename
}

#& TestPath function for testing and creating directories
Function Invoke-TestPath{
  [CmdletBinding()]
  param (
    #^ Path parameter for testing/creating destination paths
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [String]
    $ParamPath
  )
  Try{
    # Check to see if the report location exists, if not create it
    if ((Test-Path -Path $ParamPath -PathType Container) -eq $false){
      Get-Now
      Write-Host "$Script:Now [INFORMATION] Destination Path $($ParamPath) does not exist: creating...." @chighlight
      New-Item $ParamPath -ItemType Directory | Out-Null
      Get-Now
      Write-Verbose "$Script:Now [INFORMATION] Destination Path $($ParamPath) created"
    }
  }  
  Catch{
    #! Error handling for folder creation 
    Get-Now
    Write-Host "$Script:Now [Error] Error creating directories" @cerror
    Write-Host $PSItem.Exception.Message
    Stop-Transcript
    Break
  }
}

#& Display ScriptInfo
Function Get-ScriptInfo{
    
  Write-Host "#==============================================================================="
  Write-Host "# Name:             $Script:ScriptName"
  Write-Host "# Version:          $Script:Version"
  Write-Host "# GUID:             $Script:GUID"
  Write-Host "# Running As:       $Script:WHO"
  Write-Host "# PS Architecture:  $Script:PSArchitecture"
  Write-Host "# Description:"
  Write-Host "# $Script:Desc"
  Write-Host "# $Script:Desc2"
  Write-Host "#-------------------------------------------------------------------------------"
  Write-Host "# Log:              $Script:LogFile"
  Write-Host "# Exports:          $Script:dest"
  Write-Host "#==============================================================================="
  Write-Host ""
  Write-Host ""
  Write-Host ""
}

Function Get-PSArch{
  # Determines if PowerShell is running as a x86 or x64 bit process
  $Arch = [intptr]::Size

  If ($Arch -eq 4){Write-Host "PowerShell is running the script as x86"; $Script:PSArchitecture = "x86 [32 bit]"}
  If ($Arch -eq 8){Write-Host "PowerShell is running the script as x64"; $Script:PSArchitecture = "x64 [64 bit]"}
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

#& FolderPicker function for selecting a folder via explorer window
Function Get-FolderPicker{
# $Script:ISODir = Get-FolderPicker -InitialPath $Script:FPDir -Description "Select folder for ISO" 
<#
.SYNOPSIS
  Displays folder picker, allowing user to select a folder
.DESCRIPTION
  Displays folder picker, allowing user to select a folder
.PARAMETER InitialPath
  Initial folder path to be displayed
.PARAMETER Description
  Description of what should be displayed   
.INPUTS
  None
.OUTPUTS
  returns selected folder
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
  ^ . $Script:DestDir = Get-FolderPicker -InitialPath $Script:FPDir -Description "Select folder for destination" 
  shows console dialog message with options
#>

  param (
    #^ Description to use in the dialogue
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [String]
    $InitialPath,
    #^ Description to use in the dialogue
    [Parameter(ValueFromPipeline=$true)]
    [String]
    $Description
  )
  
  [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null
  $fdir = New-Object System.Windows.Forms.FolderBrowserDialog
  $fdir.InitialDirectory    = $InitialPath
  $fdir.ShowHiddenFiles     = $true
  $fdir.ShowNewFolderButton = $true
  $fdir.ShowPinnedPlaces    = $true
  $fdir.Description         = $Description
  $fdir.rootfolder          = "MyComputer"

  if($fdir.ShowDialog() -eq "OK"){ $folder += $fdir.SelectedPath }
  return $folder
}

#endregion
#region ------------------------------------------------------------[Classes]-------------------------------------------------------------

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



#endregion
#---------------------------------------------------------[Execution Completed]----------------------------------------------------------