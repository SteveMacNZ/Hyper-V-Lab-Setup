<#
.SYNOPSIS
  Add Contoso Demo User Accounts into AD - Use if connecting to Microsoft Contoso Demo tenant
.DESCRIPTION
  Add Contoso Demo User Accounts into AD - Use if connecting to Microsoft Contoso Demo tenant 
.PARAMETER None
  None
.INPUTS
  ContosoDemoUsers.csv - CSV Input file containing Contoso Demo users  
.OUTPUTS
  None
.NOTES
  Version:        1.0.0.0
  Author:         Steve McIntyre
  Creation Date:  29/11/2023
  Purpose/Change: Initial Release
.LINK
  None
.EXAMPLE
  ^ . Add-DemoUsers.ps1
  does what with example of cmdlet
  Add-DemoUsers.ps1

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
$Script:ScriptName  = 'Add-DemoUsers'                                               # Script Name used in the Open Dialogue
$Script:dest        = "$PSScriptRoot\Exports"                                       # Destination path
$Script:LogDir      = "$PSScriptRoot\Logs"                                          # Logdir for Clear-TransLogs function for $PSScript Root
$Script:LogFile     = $Script:LogDir + "\" + $Script:Date + "_" + $Script:ScriptName + ".log"    # logfile location and name
$Script:BatchName   = ''                                                            # Batch name variable placeholder
$Script:GUID        = '9d22b707-6b99-4a8d-b4f4-205eab24d09c'                        # Script GUID
  #^ Use New-Guid cmdlet to generate new script GUID for each version change of the script
[version]$Script:Version  = '1.0.0.0'                                               # Script Version Number

$DomainName = "Corp.contoso.com"                                                    # Domain Name from LabConfig.ps1
$DomainPath ="OU=Managed Objects,DC=corp,DC=contoso,DC=com"                         # Domain path based on DomainName and DefaultOUName from LabConfig.ps1
$LabPwd     = "cqU~w+06G7#;X6bI"                                                    # Intial password for user accounts
$OnMS       = "M365x52636157.onmicrosoft.com"                                       # M365 On Microsoft domain if syncing with Azure AD/M365
$CSVIn      = ".\ContosoDemoUsers.csv"                                              # CSV path to Contoso Demo User CSV file

#endregion
#region -------------------------------------------------------[Functions]---------------------------------------------------------

#endregion
#region ------------------------------------------------------------[Classes]-------------------------------------------------------------

#endregion
#region -----------------------------------------------------------[Execution]------------------------------------------------------------

Invoke-TestPath -ParamPath $Script:dest                                             # Test and create folder structure 
Invoke-TestPath -ParamPath $Script:LogDir                                           # Test and create folder structure
Start-Logging                                                                       # Start Transcription logging
Clear-TransLogs                                                                     # Clear logs over 15 days old

$result = Show-ConsoleDialog -Message "Do you want to set the UPN sufix to the OnMicrosoft.com domain?" -Title "Azure AD Sync" -Choice 'Yes', 'No'

# Create Users
If ($result -eq "Yes"){$emaildomain = $OnMS}else{$emaildomain = $DomainName}        # Set UPN and mail domain on $result

$userarray = Import-csv  -Path $CSVIn                                               # Import CSV file containing User Details

foreach ($usr in $userarray){
  $First = $usr.givenName
  $Last = $usr.surname
  $DisplayName = $usr.displayName
  $SAM = $usr.SAM
  $Manager = $usr.Manager
  
  #Check if the user account already exists in AD
  if (Get-ADUser -F {SamAccountName -eq $SAM}){
    #If user does exist, output a warning message
    Write-WarningMsg "A user account $SAM has already exist in Active Directory."
  }
  else{
    Write-InfoMsg "Creating standard User Account for $First $Last"
    New-ADUser -Name "$First $Last" -SamAccountName "$SAM" -UserPrincipalName "$SAM@$emaildomain" -GivenName "$First" -Surname "$Last" -DisplayName "$DisplayName" `
      -EmailAddres "$SAM@$emaildomain" -Enabled $True -ChangePasswordAtLogon $False -PasswordNeverExpires $False -Path "OU=Standard Users,OU=Managed Users,$DomainPath" `
      -AccountPassword (convertto-securestring $LabPwd -AsPlainText -Force)

    # Test for account
    If (Get-ADUser "$SAM"){Write-SuccessMsg "Account for $First $Last was created"}else{Write-ErrorMsg "Account for $First $Last was not created"}

    # Reset variables
    ($First,$Last,$DisplayName,$SAM) = $null
  }  
}

Write-Host ""

Write-InfoMsg "Assigning Manager to User Accounts"
foreach ($usr in $userarray){
  $First = $usr.givenName
  $Last = $usr.surname
  $DisplayName = $usr.displayName
  $SAM = $usr.SAM
  $Manager = $usr.Manager

  if (Get-ADUser -F {SamAccountName -eq $SAM}){
    Write-InfoMsg "Setting $DisplayName manager to $Manager"
    If ($Manager -ne "nil"){
      get-aduser -Identity "$SAM" | Set-ADUser -Manager "$Manager"
    }
    else{Write-WarningMsg "No Manager Assigned Skipping user"}

    # Reset variables
  ( $First,$Last,$DisplayName,$SAM,$Manager) = $null
  }
  else{
    Write-WarningMsg "A user account $SAM does not exist in Active Directory."
  }
}

Get-Now
Write-Host "================================================================================"  
Write-Host "================= $Script:Now Processing Finished ====================" 
Write-Host "================================================================================" 

Stop-Transcript
#endregion
#---------------------------------------------------------[Execution Completed]----------------------------------------------------------