<#
.SYNOPSIS
  Creates a new vhdx image of a ISO of a Windows Client OS to be used as a parent disk to support creation of lab machines
.DESCRIPTION
  Creates a new vhdx image of a ISO of a Windows Client OS to be used as a parent disk to support creation of lab machines
.PARAMETER None
  None
.INPUTS
  What Inputs  
.OUTPUTS
  What outputs
.NOTES
  Version:        1.0.0.1
  Author:         Steve McIntyre
  Creation Date:  11/09/2023
  Purpose/Change: Initial Release
.LINK
  None
.EXAMPLE
  ^ . New-WindowsClientParents.ps1
  does what with example of cmdlet
  New-WindowsClientParents.ps1

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
. "$PSScriptRoot\x0nn\Convert-WindowsImage"                                         # Import Convert-Windows Image script
. "$PSScriptRoot\LabConfig.ps1"                                                     # Load LabConfig....

#endregion
#region -------------------------------------------------------[Declarations]------------------------------------------------------

# Script sourced variables for General settings and Registry Operations
$Script:Date        = Get-Date -Format yyyy-MM-dd                                   # Date format in yyyy-mm-dd
$Script:Now         = ''                                                            # script sourced veriable for Get-Now function
$Script:ScriptName  = 'New-WindowsClientParents'                                    # Script Name used in the Open Dialogue
$Script:dest        = "$PSScriptRoot"                                               # Destination path
$Script:LogDir      = "$PSScriptRoot"                                               # Logdir for Clear-TransLogs function for $PSScript Root
$Script:LogFile     = $Script:LogDir + "\" + $Script:Date + "_" + $env:USERNAME + "_" + $Script:ScriptName + ".log"    # logfile location and name
$Script:BatchName   = ''                                                            # Batch name variable placeholder
$Script:GUID        = '426aeadb-2ad5-4ae8-8fe5-a0b99edfeada'                        # Script GUID
  #^ Use New-Guid cmdlet to generate new script GUID for each version change of the script
[version]$Script:Version  = '1.0.0.0'                                               # Script Version Number

$AdminPassword = $LabConfig.AdminPassword                                           # Get Admin Password from LabConfig
$TimeZone = (Get-TimeZone).id                                                       # Grab TimeZone
$ImageName = "LAB-CLI-WIN"                                                          # Image Computer Name to be used in the unattend.xml

#^ File Picker / Folder Picker Setup
$Script:File  = ''                                                                  # File var for Get-FilePicker Function
$Script:FPDir       = '$PSScriptRoot'                                               # File Picker Initial Directory
$Script:FileTypes   = "ISO Image (*.iso)|*.iso|All files (*.*)|*.*"                 # File types to be listed in file picker
$Script:FileIndex   = "1"                                                           # What file type to set as default in file picker (based on above order)


#endregion
#region --------------------------------------------------------[Hash Tables]------------------------------------------------------

#& any script specific hash tables that are not included in Get-CommonFunctions.ps1
$oeminformation=@"
    <OEMInformation>
        <SupportProvider>MSLab</SupportProvider>
        <SupportURL>https://aka.ms/mslab</SupportURL>
    </OEMInformation>
"@ 

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

#& FilePicker function for selecting input file via explorer window
Function Get-FilePicker {
  param (
    #^ Description to use in the dialogue
    [Parameter(ValueFromPipeline=$true)]
    [String]
    $Description
  )
  [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
  $ofd = New-Object System.Windows.Forms.OpenFileDialog
  $ofd.InitialDirectory = $Script:FPDir                                                         # Sets initial directory to script root
  $ofd.Title            = "$Description"                                                        # Title for the Open Dialogue
  $ofd.Filter           = $Script:FileTypes                                                     # File Types filter
  $ofd.FilterIndex      = $Script:FileIndex                                                     # What file type to default to
  $ofd.RestoreDirectory = $true                                                                 # Reset the directory path
  #$ofd.ShowHelp         = $true                                                                 # Legacy UI              
  $ofd.ShowHelp         = $false                                                                # Modern UI
  if($ofd.ShowDialog() -eq "OK") { $ofd.FileName }
  $Script:File = $ofd.Filename
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
    
  .LINK
    None
  .EXAMPLE
    ^ . $Script:DestDir = Get-FolderPicker -InitialPath $Script:FPDir -Description "Select folder for destination" 
    shows console dialog message with options
  #>
  
  param (
    #^ Description to use in the dialogue
    [Parameter(ValueFromPipeline=$true)]
    [String]
    $Description
  )
  
  [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null
  $fdir = New-Object System.Windows.Forms.FolderBrowserDialog
  #$fdir.InitialDirectory    = $Script:FPDir
  #$fdir.ShowHiddenFiles     = $true
  $fdir.ShowNewFolderButton = $true
  #$fdir.ShowPinnedPlaces    = $true
  $fdir.Description         = $Description
  $fdir.rootfolder          = "MyComputer"

  if($fdir.ShowDialog() -eq "OK"){ $folder += $fdir.SelectedPath }
  return $folder
}
  

#Create Unattend for VHD 
Function CreateUnattendFileVHD{
  param (
    [parameter(Mandatory=$true)]
    [string]
    $Computername,
    [parameter(Mandatory=$true)]
    [string]
    $AdminPassword,
    [parameter(Mandatory=$true)]
    [string]
    $Path,
    [parameter(Mandatory=$true)]
    [string]
    $TimeZone
  )

  if ( Test-Path "$path\Unattend.xml" ) {
    Remove-Item "$path\Unattend.xml"
  }
  $unattendFile = New-Item "$path\Unattend.xml" -type File

  $fileContent =  @"
<?xml version='1.0' encoding='utf-8'?>
<unattend xmlns="urn:schemas-microsoft-com:unattend" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

  <settings pass="offlineServicing">
   <component
        xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        language="neutral"
        name="Microsoft-Windows-PartitionManager"
        processorArchitecture="amd64"
        publicKeyToken="31bf3856ad364e35"
        versionScope="nonSxS"
        >
      <SanPolicy>1</SanPolicy>
    </component>
 </settings>
 <settings pass="specialize">
    <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
        <ComputerName>$Computername</ComputerName>
        $oeminformation
        <RegisteredOwner>PFE</RegisteredOwner>
        <RegisteredOrganization>Contoso</RegisteredOrganization>
    </component>
 </settings>
 <settings pass="oobeSystem">
    <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
      <UserAccounts>
        <AdministratorPassword>
           <Value>$AdminPassword</Value>
           <PlainText>true</PlainText>
        </AdministratorPassword>
      </UserAccounts>
      <OOBE>
        <HideEULAPage>true</HideEULAPage>
        <SkipMachineOOBE>true</SkipMachineOOBE> 
        <SkipUserOOBE>true</SkipUserOOBE> 
      </OOBE>
      <TimeZone>$TimeZone</TimeZone>
    </component>
  </settings>
</unattend>

"@

  Set-Content -path $unattendFile -value $fileContent

  #return the file object
  Return $unattendFile 
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

Write-InfoMsg "Creating Unattend.xml for image"
# Create Unattend File
CreateUnattendFileVHD -Computername $ImageName -AdminPassword $AdminPassword -path "$dest" -TimeZone $TimeZone

Write-InfoHighlightedMsg "Select ISO Image to convert to vhdx"
Get-FilePicker -Description "Select ISO Image to convert to Windows Image"

Write-Host ""

Write-InfoHighlightedMsg "Select vhdx parent folder"
$Script:DestDir = Get-FolderPicker -Description "Select folder to store parent vhdx"

$Index = Read-Host "Enter the image index number required version or Name (e.g. Pro) to list available"
$Name = Read-Host "Enter the name of the vhdx (e.g. Windows10Pro_22H2)"
Write-Host "" 

#Create Parent Image
#Convert-WindowsImage -SourcePath "E:\Apps&ISOs\Win11ISO\Windows.iso" -VHDFormat "VHDX" -Edition "6" -SizeBytes 127GB -DiskLayout "UEFI" -UnattendPath "$dest\Unattend.xml" -VHDPath "$dest\ParentDisks\Windows11Pro.vhdx"
Write-InfoHighlightedMsg "Creating Parent VHDX for Windows Client OS"
Convert-WindowsImage -SourcePath "$Script:File" -VHDFormat "VHDX" -Edition "$Index" -SizeBytes 127GB -DiskLayout "UEFI" -UnattendPath "$dest\Unattend.xml" -VHDPath "$Script:DestDir\$Name.vhdx"

Write-Host ''
Get-Now
Write-Host "$Script:Now [INFORMATION] Processing finished + any outputs"                          

Get-Now
Write-Host "================================================================================"  
Write-Host "================= $Script:Now Processing Finished ====================" 
Write-Host "================================================================================" 

Stop-Transcript
#endregion
#---------------------------------------------------------[Execution Completed]----------------------------------------------------------