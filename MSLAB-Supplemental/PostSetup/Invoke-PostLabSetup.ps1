<#
.SYNOPSIS
  To be run on member servers after provisioning to configure additional settings
.DESCRIPTION
  To be run on member servers after provisioning to configure additional settings
.PARAMETER None
  None
.INPUTS
  What Inputs  
.OUTPUTS
  What outputs
.NOTES
  Version:        1.0.0.0
  Author:         Steve McIntyre
  Creation Date:  23/11/2023
  Purpose/Change: Initial Script
.LINK
  None
.EXAMPLE
  ^ . Invoke-PostLabSetup.ps1
  does what with example of cmdlet
  Invoke-PostLabSetup.ps1

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
$Script:ScriptName  = 'Invoke-PostLabSetup'                                         # Script Name used in the Open Dialogue
$Script:dest        = "$PSScriptRoot\Exports"                                       # Destination path
$Script:LogDir      = "$PSScriptRoot\Logs"                                          # Logdir for Clear-TransLogs function for $PSScript Root
$Script:LogFile     = $Script:LogDir + "\" + $Script:Date + "_" + $Script:ScriptName + ".log"    # logfile location and name
$Script:BatchName   = ''                                                            # Batch name variable placeholder
$Script:GUID        = '27ba89c2-417c-4b77-a5a2-adb845b85225'                        # Script GUID
  #^ Use New-Guid cmdlet to generate new script GUID for each version change of the script
[version]$Script:Version  = '1.0.0.0'                                               # Script Version Number

$SQLServerName        = "SVR-SQL"                                                   # SQL Server hostname
$SQLInstallerPath     = (get-location).Drive.Name + ":\SCVMM\SQL"                   # Path to SQL server install media
$ServiceAccountPwd    = "LS1setup!"                                                 # Password for Service Accounts from LabConfig.ps1
$ADKInstallerPath     = (get-location).Drive.Name + ":\SCVMM\"                      # Path to ADK / VMM Installer
$GenInstallerPath     = (get-location).Drive.Name + ":\Installers"                  # Path to general installers

#^ Desktop Info Shortcut Details
[String]$Script:SName = "Desktop Info"                                              # Shortcut Name
[String]$Script:SPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\$Script:SName.lnk"  # Shorcut path location
[String]$Script:SArgs = ""                                                          # Shortcut Arguments
[String]$Script:SDesc = "Desktop Info"                                              # Shortcut Description
[String]$Script:SFN   = ""                                                          # Shortcut Full Name
[String]$Script:SHT   = ""                                                          # Shortcut Hotkey
[String]$Script:SIL   = (get-location).Drive.Name + ":\DesktopInfo\DesktopInfo64.exe" # Shortcut Icon Location
[String]$Script:SRP   = ""                                                          # Shortcut Relative Path
[String]$Script:STP   = (get-location).Drive.Name + ":\DesktopInfo\DesktopInfo64.exe" # Shortcut Target Path
[String]$Script:SWD   = (get-location).Drive.Name + ":\DesktopInfo"                 # Shortcut Working directory
[Int32]$Script:SWS    = "1"                                                         # Window Start Size 1=Norm, 3=Maximized, 7=Minimized

#endregion
#region -------------------------------------------------------[Functions]---------------------------------------------------------

#endregion
#region ----------------------------------------------------------[HashTable]------------------------------------------------------------
# ^ Hash table for Virtual Machine Manager Install
$fileContent = @"
  [OPTIONS]
  CompanyName=Contoso
  CreateNewSqlDatabase=1
  SqlInstanceName=MSSQLServer
  SqlDatabaseName=VirtualManagerDB
  SqlMachineName=$SQLServerName
  VmmServiceLocalAccount=0
  LibrarySharePath=C:\ProgramData\Virtual Machine Manager Library Files
  LibraryShareName=MSSCVMMLibrary
  SQMOptIn = 1
  MUOptIn = 1
"@

#endregion
#region ------------------------------------------------------------[Classes]-------------------------------------------------------------

#endregion
#region -----------------------------------------------------------[Execution]------------------------------------------------------------

# Verify Running as Admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
If (!( $isAdmin )) {
Write-Host "-- Restarting as Administrator" -ForegroundColor Cyan ; Start-Sleep -Seconds 1
Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs 
exit
}

Invoke-TestPath -ParamPath $Script:dest                                             # Test and create folder structure 
Invoke-TestPath -ParamPath $Script:LogDir                                           # Test and create folder structure
Start-Logging                                                                       # Start Transcription logging
Clear-TransLogs                                                                     # Clear logs over 15 days old

# Set Organisation Details
Set-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name RegisteredOrganization -Value "Fujitsu NZ Lab"
Set-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name RegisteredOwner -Value "Lab User"

# Configure DesktopInfo Shortcut
Try{
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
  Write-ErrorMsg "Error creating Start up Shortcut" @cerror
  Write-Host $PSItem.Exception.Message -ForegroundColor RED 
}
Finally{
  $Error.Clear()                                                                                  # Clear error log
}

#region Windows Terminal
# * Install Windows Terminal
$TermFiles = Get-ChildItem -Path "$GenInstallerPath\Windows Terminal" | Select-Object -ExpandProperty Name
Foreach ($file in $TermFiles){
  If ($file -like "Microsoft.VCLibs.*.appx"){
    $VCLib = $file
  }
  elseif ($file -like "Microsoft.UI.*.appx"){
    $UI = $file
  }
  elseif ($file -like "Microsoft.WindowsTerminal_*.msixbundle"){
    $WinTerm = $file
  }
  else{
    write-host "$file not required for install"
  }
}
Add-AppxPackage "$GenInstallerPath\Windows Terminal\$VCLib"       # Install VC Libraries
Add-AppxPackage "$GenInstallerPath\Windows Terminal\$UI"          # Install UI Xaml
Add-AppxPackage "$GenInstallerPath\Windows Terminal\$WinTerm"     # Install Windows Terminal

#region SQL
# * Install SQL if Hostname matches SQL Server Name
If ($ENV:HostName -eq $SQLServerName){
  $StartDateTime = get-date
  Write-InfoMsg "SQL server detected installing SQL"
  If (Test-Path -Path "$SQLInstallerPath\setup.exe"){
    $setupfile = (Get-Item -Path "$SQLInstallerPath\setup.exe" -ErrorAction SilentlyContinue).fullname
    Write-InfoMsg "$Setupfile found..." -ForegroundColor Cyan
  }
  else{
    # Open File dialog
    Write-InfoMsg "Please locate SQL Setup.exe" -ForegroundColor Green
    [reflection.assembly]::loadwithpartialname("System.Windows.Forms")
    $openFile = New-Object System.Windows.Forms.OpenFileDialog
    $openFile.Filter = "setup.exe files |setup.exe|All files (*.*)|*.*" 
    If($openFile.ShowDialog() -eq "OK"){
      $setupfile=$openfile.filename
      Write-InfoMsg "File $setupfile selected" -ForegroundColor Cyan
    }
    if (!$openFile.FileName){
      Write-ErrorMsg "setup.exe was not selected... Exiting" -ForegroundColor Red
      Write-ErrorMsg "Press any key to continue ..."
      $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | OUT-NULL
      $HOST.UI.RawUI.Flushinputbuffer()
      #Exit 
    }
  }
  If ($setupfile){
    Write-Host "Installing SQL..." -ForegroundColor Green
    & $setupfile /q /ACTION=Install /FEATURES=SQLEngine /INSTANCENAME=MSSQLSERVER /SQLSVCACCOUNT="Corp\SQL_SA" /SQLSVCPASSWORD="$ServiceAccountPwd" /SQLSYSADMINACCOUNTS="Corp\Domain Admins" /AGTSVCACCOUNT="Corp\SQL_Agent" /AGTSVCPASSWORD="$ServiceAccountPwd" /TCPENABLED=1 /IACCEPTSQLSERVERLICENSETERMS /Indicateprogress /UpdateEnabled=0
    
    if ((get-service MSSQLServer).Status -ne "Running"){
      do{
        Write-Host "Waiting for SQL Service to start"
        Start-Sleep 10
        Start-Service -Name MSSQLServer
      }
      until ((get-service MSSQLServer).Status -eq "Running")
      Write-Host "SQL Service is running"
    }  
  }
  Write-Host "SQL install finished at $(Get-date) and took $(((get-date) - $StartDateTime).TotalMinutes) Minutes" 
}
#endregion

#Region ADK
# * Install ADK
$InstallADK = Show-ConsoleDialog -Message "Do you want to install ADK?" -Title "Install ADK?" -Choice 'Yes', 'No'
switch ($InstallADK){
  'Yes'{
    $StartDateTime = get-date
    If (Test-Path -Path "$ADKInstallerPath\ADK\ADKsetup.exe"){
      $setupfile = Get-Item -Path "$ADKInstallerPath\ADK\ADKsetup.exe" -ErrorAction SilentlyContinue
    }
    else{
      # Open File dialog
      Write-Host "Please locate ADKSetup.exe" -ForegroundColor Green
    
      [reflection.assembly]::loadwithpartialname("System.Windows.Forms")
      $openFile = New-Object System.Windows.Forms.OpenFileDialog
      $openFile.Filter = "ADKSetup.exe files |ADKSetup.exe|All files (*.*)|*.*" 
      If($openFile.ShowDialog() -eq "OK"){
        $setupfile=$openfile.filename
        Write-Host  "File $setupfile selected" -ForegroundColor Cyan
      }
    }
    
    if ($setupfile.versioninfo.ProductBuildPart -ge 17763){
      If (Test-Path -Path "$ADKInstallerPath\ADKwinPE\adkwinpesetup.exe"){
        $winpesetupfile = Get-Item -Path "$ADKInstallerPath\ADKwinPE\adkwinpesetup.exe" -ErrorAction SilentlyContinue
      }
      else{
        # Open File dialog
        Write-Host "Please locate adkwinpesetup.exe" -ForegroundColor Green
    
        [reflection.assembly]::loadwithpartialname("System.Windows.Forms")
        $openFile = New-Object System.Windows.Forms.OpenFileDialog
        $openFile.Filter = "adkwinpesetup.exe files |adkwinpesetup.exe|All files (*.*)|*.*" 
        If($openFile.ShowDialog() -eq "OK"){
          $setupfile=$openfile.filename
          Write-Host  "File $setupfile selected" -ForegroundColor Cyan
        }
      }
    }
    
    Write-Host "Installing ADK..." -ForegroundColor Cyan
    
    if ($SetupFile.versioninfo.ProductBuildPart -ge 17763){
      Write-Host "ADK $($SetupFile.versioninfo.ProductBuildPart) Is being installed..." -ForegroundColor Cyan
      Start-Process -Wait -FilePath $setupfile.fullname -ArgumentList "/features OptionID.DeploymentTools /quiet"
      Write-Host "ADKwinPE $($winpeSetupFile.versioninfo.ProductBuildPart) Is being installed..." -ForegroundColor Cyan
      Start-Process -Wait -FilePath $winpesetupfile.fullname -ArgumentList "/features OptionID.WindowsPreinstallationEnvironment /quiet"
    }
    else{
      Write-Host "ADK $($SetupFile.versioninfo.ProductBuildPart) Is being installed..." -ForegroundColor Cyan
      Start-Process -Wait -FilePath $setupfile.fullname -ArgumentList "/features OptionID.DeploymentTools OptionID.WindowsPreinstallationEnvironment /quiet"
    }
    Write-Host "ADK install finished at $(Get-date) and took $(((get-date) - $StartDateTime).TotalMinutes) Minutes"    
  
  }
  'No'{ 
    Write-InfoMsg "ADK will not be added"
  }
}
#endregion

#region VMM
# * Install Virtual Machine Manager
$InstallVMM = Show-ConsoleDialog -Message "Do you want to install VMM (Note: SQL Must be installed first)?" -Title "Install Virtual Machine Manager?" -Choice 'Yes', 'No'
switch ($InstallVMM){
  'Yes'{
    $StartDateTime = get-date
    If (Test-Path -Path "$ADKInstallerPath\SCVMM\setup.exe"){
      $setupfile = (Get-Item -Path "$ADKInstallerPath\SCVMM\setup.exe" -ErrorAction SilentlyContinue).fullname
      Write-Host "$Setupfile found..." -ForegroundColor Cyan
    } 
    else{
      # Open File dialog
      Write-Host "Please locate Setup.exe" -ForegroundColor Green
  
      [reflection.assembly]::loadwithpartialname("System.Windows.Forms")
      $openFile = New-Object System.Windows.Forms.OpenFileDialog
      $openFile.Filter = "setup.exe files |setup.exe|All files (*.*)|*.*" 
      If($openFile.ShowDialog() -eq "OK")
      {
        $setupfile=$openfile.filename
        Write-Host  "File $setupfile selected" -ForegroundColor Cyan
      } 
    }
  
    Write-Host "Installing VMM..." -ForegroundColor Green

    # create unattend file for VMM installation
    $unattendFile = New-Item "$PSScriptRoot\VMServer.ini" -type File
    Set-Content $unattendFile $fileContent

    Write-Host "VMM is being installed..." -ForegroundColor Cyan
    & $setupfile /server /i /f $PSScriptRoot\VMServer.ini /IACCEPTSCEULA /VmmServiceDomain Corp /VmmServiceUserName vmm_SA /VmmServiceUserPassword LS1setup!
    do{
      Start-Sleep 1
    }until ($null -eq (Get-Process | Where-Object {$_.Description -eq "Virtual Machine Manager Setup"} -ErrorAction SilentlyContinue))
    
    Write-Host "VMM is Installed" -ForegroundColor Green
    
    Remove-Item "$PSScriptRoot\VMServer.ini" -ErrorAction Ignore
    
    Write-Host "VMM install finished at $(Get-date) and took $(((get-date) - $StartDateTime).TotalMinutes) Minutes"
  }
  'No'{ 
    Write-InfoMsg "VMM will not be added"
  }
}    
#endregion


Get-Now
Write-Host "================================================================================"  
Write-Host "================= $Script:Now Processing Finished ====================" 
Write-Host "================================================================================" 

Stop-Transcript
#endregion
#---------------------------------------------------------[Execution Completed]----------------------------------------------------------