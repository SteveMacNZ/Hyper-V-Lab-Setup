<#
.SYNOPSIS
  To be run on the MSLAB domain controller after provisioning to configure additional settings
.DESCRIPTION
  To be run on the MSLAB domain controller after provisioning to configure additional settings 
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
#. Get-CommonFunctions.ps1                                 # Include Common Functions

#endregion
#region -------------------------------------------------------[Declarations]------------------------------------------------------
$DomainName = "Corp.contoso.com"                                # Domain Name from LabConfig.ps1
$DomainDN   = "DC=corp,DC=contoso,DC=com"                       # Domain name DN
$DomainPath ="OU=Managed Objects,DC=corp,DC=contoso,DC=com"     # Domain path based on DomainName and DefaultOUName from LabConfig.ps1
$LabPwd     = "SomeSecurePassword"                              # Intial password for user accounts
$OnMS       = "WhatSuffux.onmicrosoft.com"                      # M365 On Microsoft domain if syncing with Azure AD/M365

#$userarray = ("First","Last","Title","Department","Company","useronly/adminonly/both"),("First","Last","Title","Department","Company","useronly/adminonly/both"),
$userarray = ("Steve","McIntyre","Systems Architect","Contractor","Fujitsu NZ","both"),("Fred","Flintstone","Systems Administrator","ICT Team","Demo Lab","both"),("Barny","Rubble","Helpdesk Team Leader","ICT Team","Demo Lab","useronly")

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

#endregion
#region -----------------------------------------------------------[Execution]------------------------------------------------------------

$result = Show-ConsoleDialog -Message "Do you want to set the UPN sufix to the OnMicrosoft.com domain?" -Title "Azure AD Sync" -Choice 'Yes', 'No'
switch ($result){
  'Yes'{
    Write-InfoMsg "Adding $OnMS as UPN Suffix" 
    Get-ADForest | Set-ADForest -UPNSuffixes @{add="$OnMS"} 
  }
  'No'{ 
    Write-InfoMsg "OnMicrosoft Domain Suffix will not be used" 
  }
}

# Create OUs
Write-InfoMsg "Creating OUs"
New-ADOrganizationalUnit -Name "Managed Users" -Path "$DomainPath" -ProtectedFromAccidentalDeletion $True `
  -Description 'This OU is to group all user accounts for Group Policy Processing' `
  -OtherAttributes:@{"c"="NZ";"co"="New Zealand";"countryCode"="554"}
New-ADOrganizationalUnit -Name "Administrative Users" -Path "OU=Managed Users,$DomainPath" -ProtectedFromAccidentalDeletion $True `
  -Description 'Administrative User Accounts OU' -OtherAttributes:@{"c"="NZ";"co"="New Zealand";"countryCode"="554"}
New-ADOrganizationalUnit -Name "Standard Users" -Path "OU=Managed Users,$DomainPath" -ProtectedFromAccidentalDeletion $True `
  -Description 'Standard User Account OU' -OtherAttributes:@{"c"="NZ";"co"="New Zealand";"countryCode"="554"}
New-ADOrganizationalUnit -Name "Contractors" -Path "OU=Managed Users,$DomainPath" -ProtectedFromAccidentalDeletion $True `
  -Description 'Contractors Account OU' -OtherAttributes:@{"c"="NZ";"co"="New Zealand";"countryCode"="554"}
New-ADOrganizationalUnit -Name "Service Accounts" -Path "OU=Managed Users,$DomainPath" -ProtectedFromAccidentalDeletion $True `
  -Description 'Service Account OU' -OtherAttributes:@{"c"="NZ";"co"="New Zealand";"countryCode"="554"}
New-ADOrganizationalUnit -Name "Managed Workstations" -Path "$DomainPath" -ProtectedFromAccidentalDeletion $True `
  -Description 'Managed Workstations OU' -OtherAttributes:@{"c"="NZ";"co"="New Zealand";"countryCode"="554"}
New-ADOrganizationalUnit -Name "Managed Servers" -Path "$DomainPath" -ProtectedFromAccidentalDeletion $True `
  -Description 'Managed Servers OU' -OtherAttributes:@{"c"="NZ";"co"="New Zealand";"countryCode"="554"}
New-ADOrganizationalUnit -Name "Application Servers" -Path "OU=Managed Servers,$DomainPath" -ProtectedFromAccidentalDeletion $True `
  -Description 'Application Servers OU' -OtherAttributes:@{"c"="NZ";"co"="New Zealand";"countryCode"="554"}
New-ADOrganizationalUnit -Name "PKI Servers" -Path "OU=Managed Servers,$DomainPath" -ProtectedFromAccidentalDeletion $True `
  -Description 'PKI Servers OU' -OtherAttributes:@{"c"="NZ";"co"="New Zealand";"countryCode"="554"}
New-ADOrganizationalUnit -Name "Web Servers" -Path "OU=Managed Servers,$DomainPath" -ProtectedFromAccidentalDeletion $True `
  -Description 'Web Servers OU' -OtherAttributes:@{"c"="NZ";"co"="New Zealand";"countryCode"="554"}
New-ADOrganizationalUnit -Name "Database Servers" -Path "OU=Managed Servers,$DomainPath" -ProtectedFromAccidentalDeletion $True `
  -Description 'Database Servers OU' -OtherAttributes:@{"c"="NZ";"co"="New Zealand";"countryCode"="554"}
New-ADOrganizationalUnit -Name "Management Servers" -Path "OU=Managed Servers,$DomainPath" -ProtectedFromAccidentalDeletion $True `
  -Description 'Management Servers OU' -OtherAttributes:@{"c"="NZ";"co"="New Zealand";"countryCode"="554"}
New-ADOrganizationalUnit -Name "Managed Groups" -Path "$DomainPath" -ProtectedFromAccidentalDeletion $True `
  -Description 'Managed Groups OU' -OtherAttributes:@{"c"="NZ";"co"="New Zealand";"countryCode"="554"}
New-ADOrganizationalUnit -Name "Security Groups" -Path "OU=Managed Groups,$DomainPath" -ProtectedFromAccidentalDeletion $True `
  -Description 'Security Groups OU' -OtherAttributes:@{"c"="NZ";"co"="New Zealand";"countryCode"="554"}
New-ADOrganizationalUnit -Name "Distribution Groups" -Path "OU=Managed Groups,$DomainPath" -ProtectedFromAccidentalDeletion $True `
  -Description 'Distribution Groups OU' -OtherAttributes:@{"c"="NZ";"co"="New Zealand";"countryCode"="554"}
New-ADOrganizationalUnit -Name "Licensing Groups" -Path "OU=Managed Groups,$DomainPath" -ProtectedFromAccidentalDeletion $True `
  -Description 'Licensing Groups OU' -OtherAttributes:@{"c"="NZ";"co"="New Zealand";"countryCode"="554"}

# Create licensing Groups
Write-InfoMsg "Creating Licensing Groups"
New-ADGroup -Name "LIC M365 E3" -SamAccountName LIC_M365_E3 -GroupCategory Security -GroupScope Universal `
  -DisplayName "LIC M365 Enterprise E3" -Path "OU=Licensing Groups,OU=Managed Groups,$DomainPath" `
  -Description "Members of this group will be assigned M365 Enterprise E3 License"
New-ADGroup -Name "LIC M365 E5" -SamAccountName LIC_M365_E5 -GroupCategory Security -GroupScope Universal `
  -DisplayName "LIC M365 Enterprise E5" -Path "OU=Licensing Groups,OU=Managed Groups,$DomainPath" `
  -Description "Members of this group will be assigned M365 Enterprise E5 License"
New-ADGroup -Name "LIC M365 F3" -SamAccountName LIC_M365_F3 -GroupCategory Security -GroupScope Universal `
  -DisplayName "LIC M365 Enterprise F3 (Frontline)" -Path "OU=Licensing Groups,OU=Managed Groups,$DomainPath" `
  -Description "Members of this group will be assigned M365 Enterprise E5 License"
New-ADGroup -Name "LIC AAD P2" -SamAccountName LIC_AAD_P2 -GroupCategory Security -GroupScope Universal `
  -DisplayName "LIC Azure AD P2" -Path "OU=Licensing Groups,OU=Managed Groups,$DomainPath" `
  -Description "Members of this group will be assigned M365 Enterprise E5 License"
New-ADGroup -Name "LIC EXO P2" -SamAccountName LIC_EXO -GroupCategory Security -GroupScope Universal `
  -DisplayName "LIC Exchange Online P2" -Path "OU=Licensing Groups,OU=Managed Groups,$DomainPath" `
  -Description "Members of this group will be assigned Exchange Online P2 License"
New-ADGroup -Name "LIC Visio" -SamAccountName LIC_VSO -GroupCategory Security -GroupScope Universal `
  -DisplayName "LIC Visio Online" -Path "OU=Licensing Groups,OU=Managed Groups,$DomainPath" `
  -Description "Members of this group will be assigned Visio Online License"
New-ADGroup -Name "LIC Project" -SamAccountName LIC_PJT -GroupCategory Security -GroupScope Universal `
  -DisplayName "LIC Project Online" -Path "OU=Licensing Groups,OU=Managed Groups,$DomainPath" `
  -Description "Members of this group will be assigned Project Online License"
New-ADGroup -Name "LIC TeamsPro" -SamAccountName LIC_PJT -GroupCategory Security -GroupScope Universal `
  -DisplayName "LIC Teams Professional" -Path "OU=Licensing Groups,OU=Managed Groups,$DomainPath" `
  -Description "Members of this group will be assigned Teams Professional License"  

# Create Security Groups
Write-InfoMsg "Creating Security Groups"

# Create Server Groups
New-ADGroup -Name "NDES Servers" -SamAccountName SEC_NDES_SVR -GroupCategory Security -GroupScope Universal -DisplayName "NDES Servers" -Path "OU=Security Groups,OU=Managed Groups,$DomainPath" -Description "Members of this group will be used to assign permissions for NDES Servers"
# Create LAPs Groups
New-ADGroup -Name "CORP-LAPS-View-Tier1-Server-Passwords" -SamAccountName SEC_LAP_T1Server -GroupCategory Security -GroupScope Universal -DisplayName "LAPS View Tier 1 Server Passwords" -Path "OU=Security Groups,OU=Managed Groups,$DomainPath" -Description "Members of this group can decrypt LAPs passwords for Tier 1 Servers"
New-ADGroup -Name "CORP-LAPS-View-Tier0-Server-Passwords" -SamAccountName SEC_LAP_T0Server -GroupCategory Security -GroupScope Universal -DisplayName "LAPS View Tier 0 Server Passwords" -Path "OU=Security Groups,OU=Managed Groups,$DomainPath" -Description "Members of this group can decrypt LAPs passwords for Tier 0 Servers"
New-ADGroup -Name "CORP-LAPS-View-Tier0-DSRM-Passwords" -SamAccountName SEC_LAP_T0DSRM -GroupCategory Security -GroupScope Universal -DisplayName "LAPS View Tier 0 DSRM Passwords" -Path "OU=Security Groups,OU=Managed Groups,$DomainPath" -Description "Members of this group can decrypt LAPs passwords for Tier 0 DRSM"

# Create Users
If ($result -eq "Yes"){$emaildomain = $OnMS}else{$emaildomain = $DomainName} # Set UPN and mail domain on $result

foreach ($usr in $userarray){
  $First = $usr[0]
  $Last = $usr[1]
  $Title = $usr[2]
  $Dept = $usr[3]
  $Company = $usr[4]
  $AccType = $usr[5]

  # Calculate UPN
  $SAM = $last + $first[0]

  If (($AccType -eq "useronly") -or ($AccType -eq "both")){
    # Create Standard User Account
    Write-InfoMsg "Creating standard User Account for $First $Last"
    New-ADUser -Name "$First $Last" -SamAccountName "$SAM" -UserPrincipalName "$first.$last@$emaildomain" -GivenName "$First" -Surname "$Last" -DisplayName "$last, $First" `
      -Description "Fujitsu Support Account" -Department "$Dept" -Country "NZ" -City "Wellington" -Company "$Company" -EmailAddres "$first.$last@$emaildomain" `
      -StreetAddress "Level 3, 40 Bowen Street, Wellington, New Zealand 6011" -Title "$Title" -Office "Fujitsu Wellington" -Enabled $True -ChangePasswordAtLogon $False `
      -PasswordNeverExpires $False -Path "OU=Standard Users,OU=Managed Users,$DomainPath" `
      -AccountPassword (convertto-securestring $LabPwd -AsPlainText -Force)

    # Test for account
    If (Get-ADUser "$SAM"){Write-SuccessMsg "Account for $First $Last was created"}else{Write-ErrorMsg "Account for $First $Last was not created"}
  }

  If (($AccType -eq "adminonly") -or ($AccType -eq "both")){
    # Create Admin User Account 
    Write-InfoMsg "Creating administrative User Account for $First $Last" 
    New-ADUser -Name "Adm $First $Last" -SamAccountName "adm_$SAM" -UserPrincipalName "adm_$first.$last@$emaildomain" -GivenName "$First" -Surname "$Last" -DisplayName "$last, $First [Admin]" `
      -Description "Fujitsu Support Account" -Department "$Dept" -Country "NZ" -City "Wellington" -Company "$Company" -EmailAddres "adm_$first.$last@$emaildomain" `
      -StreetAddress "Level 3, 40 Bowen Street, Wellington, New Zealand 6011" -Title "$Title" -Office "Fujitsu Wellington" -Enabled $True -ChangePasswordAtLogon $False `
      -PasswordNeverExpires $False -Path "OU=Administrative Users,OU=Managed Users,$DomainPath" `
      -AccountPassword (convertto-securestring $LabPwd -AsPlainText -Force)
    
    # Test for account
    If (Get-ADUser "adm_$SAM"){
      Write-SuccessMsg "Admin Account for $First $Last was created"
      Write-InfoMsg "Add admin user to Admin Groups"
      Add-ADGroupMember -Identity "Domain Admins" -Members "adm_$SAM"   
      Add-ADGroupMember -Identity "Enterprise Admins" -Members "adm_$SAM"
      Add-ADGroupMember -Identity "Schema Admins" -Members "adm_$SAM"
      Add-ADGroupMember -Identity "CORP-LAPS-View-Tier1-Server-Passwords" -Members "adm_$SAM"
    }
    else{
      Write-ErrorMsg "Admin Account for $First $Last was not created"
    }
  }  
  
  # Reset variables
  ($First,$Last,$Title,$Dept,$Company,$AccType,$SAM) = $null
}

# Create Service Account for NDES
Write-InfoMsg "Creating NDES Service Account"
New-ADUser -Name "SVC NDES" -SamAccountName "svc_ndes" -UserPrincipalName "svc_ndes@$DomainName" -GivenName "NDES" -Surname "Service" -DisplayName "NDES Service Account" `
  -Description "NDES Service Account" -Country "NZ" -City "Wellington" `
  -StreetAddress "Level 3, 40 Bowen Street, Wellington, New Zealand 6011" -Title "Service Account" -Office "Fujitsu Wellington" -Enabled $True -ChangePasswordAtLogon $False `
  -PasswordNeverExpires $False -Path "OU=Service Accounts,OU=Managed Users,$DomainPath" `
  -AccountPassword (convertto-securestring $LabPwd -AsPlainText -Force)

# Test for NDES account
If (Get-ADUser "svc_ndes"){Write-SuccessMsg "NDES Service Account created"}else{Write-ErrorMsg "NDES Service Account was not created"}

# Enable LAPs
Write-InfoMsg "Enabling LAPs"
Update-LapsADSchema
Set-LapsADComputerSelfPermission -Identity "$DomainDN"

# Import Group Policy Objects
Write-host "Have you imported the WMI filters? Please import before contuning"
#pause
Write-InfoMsg "Importing Group Policies"
Import-GPO -BackupId "5A92E34B-8C7A-4146-BF40-6A131EB877F8" -TargetName "SEC - Rename Local Admin" -Path "D:\GPOBackup" -CreateIfNeeded     # Rename local administrator account to GhostAdmin and disable
Import-GPO -BackupId "46ABA2DA-43C1-4CBB-86CD-5DC701DB09CB" -TargetName "SEC - LAPS Tier 0 Server" -Path "D:\GPOBackup" -CreateIfNeeded     # LAPS policy for Tier 0 Servers
Import-GPO -BackupId "1A3ED640-E62D-491F-AEE5-A0E58D66041F" -TargetName "SEC - LAPS Tier 0 DSRM" -Path "D:\GPOBackup" -CreateIfNeeded       # LAPS policy for Tier 0 DSRM
Import-GPO -BackupId "490AD999-5374-4847-9D78-E3E0FCD88CD5" -TargetName "SEC - LAPS Tier 1 Server" -Path "D:\GPOBackup" -CreateIfNeeded     # LAPS policy for Tier 1 Servers
Import-GPO -BackupId "F0128B1F-844A-4C17-9AD1-BD32F85F7BB9" -TargetName "SEC - CIS User Level 1" -Path "D:\CIS\Server2022v2.0.0\User-L1" -CreateIfNeeded    # CIS User Level 1 Policy
Import-GPO -BackupId "CCC587D4-8D61-4199-BC5A-F423C572F229" -TargetName "SEC - CIS User Level 2" -Path "D:\CIS\Server2022v2.0.0\User-L2" -CreateIfNeeded    # CIS User Level 2 Policy
Import-GPO -BackupId "89ACD606-6BB2-430A-BC86-3BF900671A9F" -TargetName "SEC - CIS Windows Server 2022 Level 1" -Path "D:\CIS\Server2022v2.0.0\MS-L1" -CreateIfNeeded    # CIS Windows Server 2022 Member Server L1 Policy
Import-GPO -BackupId "9BAEF3A8-2FA4-4732-80B5-4811B64038C6" -TargetName "SEC - CIS Windows Server 2022 Level 2" -Path "D:\CIS\Server2022v2.0.0\MS-L2" -CreateIfNeeded    # CIS Windows Server 2022 Member Server L2 Policy
Import-GPO -BackupId "29E1A86D-0DB7-4603-AFEE-8A635C8212E6" -TargetName "SEC - CIS Windows Server 2022 Level 2 Services" -Path "D:\CIS\Server2022v2.0.0\MS-L2 Services" -CreateIfNeeded    # CIS Windows Server 2022 Member Server L2 Services Policy
Import-GPO -BackupId "7A536913-BE78-49A7-8495-795F65458798" -TargetName "SEC - CIS Windows Server 2022 NGWS" -Path "D:\CIS\Server2022v2.0.0\MS-NGWS" -CreateIfNeeded    # CIS Windows Server 2022 Member Server NGWS Policy
Import-GPO -BackupId "BB2B244E-9173-4A5F-AB75-ADDC7B003C59" -TargetName "SEC - CIS Windows Server 2022 DC Level 1" -Path "D:\CIS\Server2022v2.0.0\DC-L1" -CreateIfNeeded    # CIS Windows Server 2022 Domain Controller L1 Policy
Import-GPO -BackupId "1049F57E-2233-47EF-8486-2941AFFE5BDF" -TargetName "SEC - CIS Windows Server 2022 DC Level 1 Services" -Path "D:\CIS\Server2022v2.0.0\DC-L1 Services" -CreateIfNeeded    # CIS Windows Server 2022 Domain Controller L1 Services Policy
Import-GPO -BackupId "B56766A3-0E30-4569-B91F-7A12EB6ECE47" -TargetName "SEC - CIS Windows Server 2022 DC Level 2" -Path "D:\CIS\Server2022v2.0.0\DC-L2" -CreateIfNeeded    # CIS Windows Server 2022 Domain Controller L2 Policy

Set-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name RegisteredOrganization -Value "Fujitsu NZ Lab"
Set-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name RegisteredOwner -Value "Lab User"


#endregion
#---------------------------------------------------------[Execution Completed]----------------------------------------------------------