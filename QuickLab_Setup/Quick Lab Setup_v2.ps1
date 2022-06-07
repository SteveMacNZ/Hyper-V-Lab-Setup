#! Quick Lab Setup
#==========================================================================================================================================================

#? ---------------------------------------------------------------------- NOTES: --------------------------------------------------------------------------
#& Best viewed in Microsoft Visual Studio Code with Colorful Comments extension installed
#* Requires Hyper-V Role installed on your device (Works on Windows 10 - Enable the Hyper-V feature NB: Virtualisation needs to be enabled in BIOS)
#? To create parent VHDX - Create a new Hyper-V VM and install the OS. At the OOBE screen (Entering of Country) press Ctrl + Shift + F3 to enter Audit Mode
#? In Audit Mode install any Windows Updates and/or additional apps you require (reboot as required) when finished editing run sysprep with Enter OOBE | 
#? Generalize | Shutdown - once shut down copy to the folder path e.g. C:\Hyper-V\Virtual Hard Disks and rename as required. Delete the parent VM
#? You can now use this VHDX as the parent disk(s) for your VMs... If you require a isolated network create a private switch in Hyper-V and use pfsense VM
#? to provide firewall / routing.  
#^ New-VMSwitch -Name "vSWI_172.70.70.x" -SwitchType "Private" -Notes "vSwitch for 172.70.70.0/24 Subnet"
#? --------------------------------------------------------------------------------------------------------------------------------------------------------

$ParentDisk = 'D:\Hyper-V\Virtual Hard Disks\SVR2K22Std(D)_14-01-22_sysprepd.vhdx'
$ParentDiskC = 'D:\Hyper-V\Virtual Hard Disks\SVR2K22Std(C)_14-01-22_sysprepd.vhdx'
$VMDest = 'D:\Hyper-V'
$vSWI = 'vSWI_172.70.70.x'

#! Quick VM Creation
#^ DC VM
$VMName = 'SVR-LAB-DC01'
$Proc = '2'
$Min = '512MB'
$Max = '2GB'
New-Item -Name $VMName -Path $VMDest -ItemType "directory"
New-VHD -ParentPath $ParentDiskC -Path ($VMDest + '\' + $VMName + '\' + $VMName + '_OS.vhdx') -Differencing
New-VHD -Path ($VMDest + '\' + $VMName + '\' + $VMName + '_ADDS.vhdx') -Dynamic -SizeBytes (Invoke-Expression '20GB')
New-VM -Name $VMName -MemoryStartupBytes (Invoke-Expression '1GB') -BootDevice VHD -VHDPath ($VMDest + '\' + $VMName + '\' + $VMName + '_OS.vhdx') -Path $VMDest -Generation 2 -SwitchName $vSWI
Set-VM -Name $VMName -ProcessorCount $Proc -DynamicMemory -MemoryMinimumBytes (Invoke-Expression $Min) -MemoryMaximumBytes (Invoke-Expression $Max) -AutomaticStartDelay '0' -AutomaticStopAction Shutdown -AutomaticStartAction Nothing -AutomaticCheckpointsEnabled $false
Add-VMHardDiskDrive -VMName $VMName -Path ($VMDest + '\' + $VMName + '\' + $VMName + '_ADDS.vhdx')
Add-VMDvdDrive -VMName $VMName

#^ MGT VM
$VMName = 'SVR-LAB-MGT'
$Proc = '2'
$Min = '2GB'
$Max = '4GB'
New-Item -Name $VMName -Path $VMDest -ItemType "directory"
New-VHD -ParentPath $ParentDisk -Path ($VMDest + '\' + $VMName + '\' + $VMName + '_OS.vhdx') -Differencing
New-VM -Name $VMName -MemoryStartupBytes (Invoke-Expression '1GB') -BootDevice VHD -VHDPath ($VMDest + '\' + $VMName + '\' + $VMName + '_OS.vhdx') -Path $VMDest -Generation 2 -SwitchName $vSWI
Set-VM -Name $VMName -ProcessorCount $Proc -DynamicMemory -MemoryMinimumBytes (Invoke-Expression $Min) -MemoryMaximumBytes (Invoke-Expression $Max) -AutomaticStartDelay '0' -AutomaticStopAction Shutdown -AutomaticStartAction Nothing -AutomaticCheckpointsEnabled $false
Add-VMDvdDrive -VMName $VMName

#^ Enterprise Root Authority (ERA) [CA] VM
$VMName = 'SVR-LAB-ERA'
$Proc = '2'
$Min = '512MB'
$Max = '2GB'
New-Item -Name $VMName -Path $VMDest -ItemType "directory"
New-VHD -ParentPath $ParentDisk -Path ($VMDest + '\' + $VMName + '\' + $VMName + '_OS.vhdx') -Differencing
New-VM -Name $VMName -MemoryStartupBytes (Invoke-Expression '1GB') -BootDevice VHD -VHDPath ($VMDest + '\' + $VMName + '\' + $VMName + '_OS.vhdx') -Path $VMDest -Generation 2 -SwitchName $vSWI
Set-VM -Name $VMName -ProcessorCount $Proc -DynamicMemory -MemoryMinimumBytes (Invoke-Expression $Min) -MemoryMaximumBytes (Invoke-Expression $Max) -AutomaticStartDelay '0' -AutomaticStopAction Shutdown -AutomaticStartAction Nothing -AutomaticCheckpointsEnabled $false
Add-VMDvdDrive -VMName $VMName

#^ Intermediate Certificate Authority (ICA) [CA] VM
$VMName = 'SVR-LAB-ICA'
$Proc = '2'
$Min = '512MB'
$Max = '2GB'
New-Item -Name $VMName -Path $VMDest -ItemType "directory"
New-VHD -ParentPath $ParentDisk -Path ($VMDest + '\' + $VMName + '\' + $VMName + '_OS.vhdx') -Differencing
New-VM -Name $VMName -MemoryStartupBytes (Invoke-Expression '1GB') -BootDevice VHD -VHDPath ($VMDest + '\' + $VMName + '\' + $VMName + '_OS.vhdx') -Path $VMDest -Generation 2 -SwitchName $vSWI
Set-VM -Name $VMName -ProcessorCount $Proc -DynamicMemory -MemoryMinimumBytes (Invoke-Expression $Min) -MemoryMaximumBytes (Invoke-Expression $Max) -AutomaticStartDelay '0' -AutomaticStopAction Shutdown -AutomaticStartAction Nothing -AutomaticCheckpointsEnabled $false
Add-VMDvdDrive -VMName $VMName

#^ Web Server IIS VM
$ParentDisk = 'D:\Hyper-V\Virtual Hard Disks\SVR2K22Std(D)_14-01-22_sysprepd.vhdx'
$VMDest = 'D:\Hyper-V'
$vSWI = 'vSWI_172.70.70.x'
$VMName = 'SVR-LAB-IIS'
$Proc = '2'
$Min = '512MB'
$Max = '2GB'
New-Item -Name $VMName -Path $VMDest -ItemType "directory"
New-VHD -ParentPath $ParentDisk -Path ($VMDest + '\' + $VMName + '\' + $VMName + '_OS.vhdx') -Differencing
New-VM -Name $VMName -MemoryStartupBytes (Invoke-Expression '1GB') -BootDevice VHD -VHDPath ($VMDest + '\' + $VMName + '\' + $VMName + '_OS.vhdx') -Path $VMDest -Generation 2 -SwitchName $vSWI
Set-VM -Name $VMName -ProcessorCount $Proc -DynamicMemory -MemoryMinimumBytes (Invoke-Expression $Min) -MemoryMaximumBytes (Invoke-Expression $Max) -AutomaticStartDelay '0' -AutomaticStopAction Shutdown -AutomaticStartAction Nothing -AutomaticCheckpointsEnabled $false
Add-VMDvdDrive -VMName $VMName


#^ WIN10 ENT VM - Domain Joined 
New-Item -Name 'WIN10-PC01' -Path 'C:\Hyper-V' -ItemType "directory"
New-VHD -ParentPath 'C:\Hyper-V\Virtual Hard Disks\Win10(E)_20H2_2021-05_sysprepd.vhdx' -Path 'C:\Hyper-V\Win10-PC01\Win10-PC01_OS.vhdx' -Differencing
New-VM -Name 'WIN10-PC01' -MemoryStartupBytes (Invoke-Expression '1GB') -BootDevice VHD -VHDPath 'C:\Hyper-V\Win10-PC01\WIN10-PC01_OS.vhdx' -Path 'C:\Hyper-V' -Generation 2 -SwitchName 'vSWI_172.50.50.x'
Set-VM -Name 'WIN10-PC01' -ProcessorCount '1' -DynamicMemory -MemoryMinimumBytes (Invoke-Expression '512MB') -MemoryMaximumBytes (Invoke-Expression '1GB') -AutomaticStartDelay '0' -AutomaticStopAction Shutdown -AutomaticStartAction Nothing -AutomaticCheckpointsEnabled $false
Add-VMDvdDrive -VMName 'WIN10-PC01'

#^ WIN10 PRO VM - AAD Joined 
New-Item -Name 'WIN10-PC02' -Path 'C:\Hyper-V' -ItemType "directory"
New-VHD -ParentPath 'C:\Hyper-V\Virtual Hard Disks\Win10(P)_20H2_2021-05_sysprepd.vhdx' -Path 'C:\Hyper-V\Win10-PC01\Win10-PC02_OS.vhdx' -Differencing
New-VM -Name 'WIN10-PC02' -MemoryStartupBytes (Invoke-Expression '1GB') -BootDevice VHD -VHDPath 'C:\Hyper-V\Win10-PC01\WIN10-PC02_OS.vhdx' -Path 'C:\Hyper-V' -Generation 2 -SwitchName 'vSWI_172.50.50.x'
Set-VM -Name 'WIN10-PC02' -ProcessorCount '1' -DynamicMemory -MemoryMinimumBytes (Invoke-Expression '512MB') -MemoryMaximumBytes (Invoke-Expression '1GB') -AutomaticStartDelay '0' -AutomaticStopAction Shutdown -AutomaticStartAction Nothing -AutomaticCheckpointsEnabled $false
Add-VMDvdDrive -VMName 'WIN10-PC02'

#! Quick VM Config
#==========================================================================================================================================================

#& DC VM
Rename-computer -newname SVR-DC01
New-NetIPAddress -InterfaceAlias Ethernet -IPAddress 172.50.50.1 -DefaultGateway 172.50.50.254 -AddressFamily IPv4 -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses ("172.50.50.1","127.0.0.1","8.8.8.8")
Set-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name RegisteredOrganization -Value "Fujitsu NZ DemoLab"
$Make = Get-WmiObject Win32_ComputerSystem | Select-object -ExpandProperty Manufacturer
$Model = Get-WmiObject Win32_ComputerSystem | Select-object -ExpandProperty Model
$Logo = 'C:\Windows\System32\oobe\FujitsuLogo.bmp'
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" -Name Manufacturer -PropertyType String -Value $Make -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" -Name Model -PropertyType String -Value $Model -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" -Name Logo -PropertyType String -Value $Logo -Force

Restart-Computer

Initialize-Disk -Number 1
New-Partition -DiskNumber 1 -AssignDriveLetter -UseMaximumSize
Get-Volume
Set-Volume -DriveLetter C -NewFileSystemLabel "OS"
Format-Volume -DriveLetter E -FileSystem NTFS -NewFileSystemLabel "ADDS" -Confirm:$false

Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Install-WindowsFeature DNS -IncludeManagementTools
Install-WindowsFeature DHCP -IncludeManagementTools

Install-ADDSForest -DomainName "demo.lab.internal" -DomainNetbiosName "DEMOLAB" -InstallDNS -ForestMode 7 -DomainMode 7  -DatabasePath E:\NTDS -SysvolPath E:\SYSVOL -LogPath E:\LOGS -Confirm

netsh dhcp add securitygroups
Restart-service dhcpserver
Add-DhcpServerInDC -DnsName SVR-DC01.demo.lab.internal -IPAddress 172.50.50.1
Set-ItemProperty -Path registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ServerManager\Roles\12 -Name ConfigurationState -Value 2
Set-DhcpServerv4DnsSetting -ComputerName SVR-DC01.demo.lab.internal -DynamicUpdates "Always" -DeleteDnsRRonLeaseExpiry $True
Set-DhcpServerDnsCredential -Credential (Get-Credential) -ComputerName SVR-DC01.demo.lab.internal
Add-DhcpServerv4Scope -name "LAN -172.50.50.0/24" -StartRange 172.50.50.20 -EndRange 172.50.50.253 -SubnetMask 255.255.255.0 -State Active
Add-DhcpServerv4ExclusionRange -ScopeID 172.50.50.0 -StartRange 172.50.50.200 -EndRange 172.50.50.253
Set-DhcpServerv4OptionValue -ComputerName SVR-DC01.demo.lab.internal -ScopeID 172.50.50.0 -Router 172.50.50.254
Set-DhcpServerv4OptionValue -ComputerName SVR-DC01.demo.lab.internal -DnsServer 172.50.50.1  -DnsDomain demo.lab.internal
Add-DnsServerPrimaryZone -DynamicUpdate Secure -NetworkId 172.50.50/24 -ReplicationScope Domain

$credentials= Get-Credential
New-ADOrganizationalUnit -Name:"Managed Users" -Path:"DC=demo,DC=lab,DC=internal" -ProtectedFromAccidentalDeletion:$True -Credential $credentials -Description:'This OU is to group all user accounts for Group Policy Processing' -OtherAttributes:@{"c"="NZ";"co"="New Zealand";"countryCode"="554"}
New-ADOrganizationalUnit -Name:"Administrative Users" -Path:"OU=Managed Users,DC=demo,DC=lab,DC=internal" -ProtectedFromAccidentalDeletion:$True -Credential $credentials -Description:'Administrative User Accounts OU' -OtherAttributes:@{"c"="NZ";"co"="New Zealand";"countryCode"="554"}
New-ADOrganizationalUnit -Name:"Standard Users" -Path:"OU=Managed Users,DC=demo,DC=lab,DC=internal" -ProtectedFromAccidentalDeletion $True -Credential $credentials -Description:'Standard User Account OU' -OtherAttributes:@{"c"="NZ";"co"="New Zealand";"countryCode"="554"}
New-ADOrganizationalUnit -Name:"Contractors" -Path:"OU=Managed Users,DC=demo,DC=lab,DC=internal" -ProtectedFromAccidentalDeletion $True -Credential $credentials -Description:'Contractors Account OU' -OtherAttributes:@{"c"="NZ";"co"="New Zealand";"countryCode"="554"}
New-ADOrganizationalUnit -Name:"Service Accounts" -Path:"OU=Managed Users,DC=demo,DC=lab,DC=internal" -ProtectedFromAccidentalDeletion $True -Credential $credentials -Description:'Service Account OU' -OtherAttributes:@{"c"="NZ";"co"="New Zealand";"countryCode"="554"}
New-ADOrganizationalUnit -Name:"Managed Clients" -Path:"DC=demo,DC=lab,DC=internal" -ProtectedFromAccidentalDeletion $True -Credential $credentials -Description:'This OU is to group all computer accounts for Group Policy Processing' -OtherAttributes:@{"c"="NZ";"co"="New Zealand";"countryCode"="554"}
New-ADOrganizationalUnit -Name:"Managed Desktops" -Path:"OU=Managed Clients,DC=demo,DC=lab,DC=internal" -ProtectedFromAccidentalDeletion $True -Credential $credentials -Description:'Managed Desktops OU' -OtherAttributes:@{"c"="NZ";"co"="New Zealand";"countryCode"="554"}
New-ADOrganizationalUnit -Name:"Managed Laptops" -Path:"OU=Managed Clients,DC=demo,DC=lab,DC=internal" -ProtectedFromAccidentalDeletion $True -Credential $credentials -Description:'Managed Laptops OU' -OtherAttributes:@{"c"="NZ";"co"="New Zealand";"countryCode"="554"}
New-ADOrganizationalUnit -Name:"Managed Workstations" -Path:"OU=Managed Clients,DC=demo,DC=lab,DC=internal" -ProtectedFromAccidentalDeletion $True -Credential $credentials -Description:'Managed Workstations OU' -OtherAttributes:@{"c"="NZ";"co"="New Zealand";"countryCode"="554"}
New-ADOrganizationalUnit -Name:"Managed Servers" -Path:"DC=demo,DC=lab,DC=internal" -ProtectedFromAccidentalDeletion $True -Credential $credentials -Description:'Managed Servers OU' -OtherAttributes:@{"c"="NZ";"co"="New Zealand";"countryCode"="554"}
New-ADOrganizationalUnit -Name:"Application Servers" -Path:"OU=Managed Servers,DC=demo,DC=lab,DC=internal" -ProtectedFromAccidentalDeletion $True -Credential $credentials -Description:'Application Servers OU' -OtherAttributes:@{"c"="NZ";"co"="New Zealand";"countryCode"="554"}
New-ADOrganizationalUnit -Name:"PKI Servers" -Path:"OU=Managed Servers,DC=demo,DC=lab,DC=internal" -ProtectedFromAccidentalDeletion $True -Credential $credentials -Description:'PKI Servers OU' -OtherAttributes:@{"c"="NZ";"co"="New Zealand";"countryCode"="554"}
New-ADOrganizationalUnit -Name:"Web Servers" -Path:"OU=Managed Servers,DC=demo,DC=lab,DC=internal" -ProtectedFromAccidentalDeletion $True -Credential $credentials -Description:'Web Servers OU' -OtherAttributes:@{"c"="NZ";"co"="New Zealand";"countryCode"="554"}
New-ADOrganizationalUnit -Name:"Database Servers" -Path:"OU=Managed Servers,DC=demo,DC=lab,DC=internal" -ProtectedFromAccidentalDeletion $True -Credential $credentials -Description:'Database Servers OU' -OtherAttributes:@{"c"="NZ";"co"="New Zealand";"countryCode"="554"}
New-ADOrganizationalUnit -Name:"Management Servers" -Path:"OU=Managed Servers,DC=demo,DC=lab,DC=internal" -ProtectedFromAccidentalDeletion $True -Credential $credentials -Description:'Management Servers OU' -OtherAttributes:@{"c"="NZ";"co"="New Zealand";"countryCode"="554"}
New-ADOrganizationalUnit -Name:"Managed Groups" -Path:"DC=demo,DC=lab,DC=internal" -ProtectedFromAccidentalDeletion $True -Credential $credentials -Description:'Managed Groups OU' -OtherAttributes:@{"c"="NZ";"co"="New Zealand";"countryCode"="554"}
New-ADOrganizationalUnit -Name:"Security Groups" -Path:"OU=Managed Groups,DC=demo,DC=lab,DC=internal" -ProtectedFromAccidentalDeletion $True -Credential $credentials -Description:'Security Groups OU' -OtherAttributes:@{"c"="NZ";"co"="New Zealand";"countryCode"="554"}
New-ADOrganizationalUnit -Name:"Distribution Groups" -Path:"OU=Managed Groups,DC=demo,DC=lab,DC=internal" -ProtectedFromAccidentalDeletion $True -Credential $credentials -Description:'Distribution Groups OU' -OtherAttributes:@{"c"="NZ";"co"="New Zealand";"countryCode"="554"}
New-ADOrganizationalUnit -Name:"Licensing Groups" -Path:"OU=Managed Groups,DC=demo,DC=lab,DC=internal" -ProtectedFromAccidentalDeletion $True -Credential $credentials -Description:'Licensing Groups OU' -OtherAttributes:@{"c"="NZ";"co"="New Zealand";"countryCode"="554"}

New-ADGroup -Name "LIC O365 BP" -SamAccountName LIC_O365_BP -GroupCategory Security -GroupScope Universal -DisplayName "LIC O365 Business Premium" -Path "OU=Licensing Groups,OU=Managed Groups,DC=demo,DC=lab,DC=internal" -Description "Members of this group will be assigned O365 Business Premium License"
New-ADGroup -Name "LIC O365 E3" -SamAccountName LIC_O365_E3 -GroupCategory Security -GroupScope Universal -DisplayName "LIC O365 Enterprise E3" -Path "OU=Licensing Groups,OU=Managed Groups,DC=demo,DC=lab,DC=internal" -Description "Members of this group will be assigned O365 Enterprise E3 License"
New-ADGroup -Name "LIC O365 E5" -SamAccountName LIC_O365_E5 -GroupCategory Security -GroupScope Universal -DisplayName "LIC O365 Enterprise E5" -Path "OU=Licensing Groups,OU=Managed Groups,DC=demo,DC=lab,DC=internal" -Description "Members of this group will be assigned O365 Enterprise E5 License"
New-ADGroup -Name "LIC M365 Business" -SamAccountName LIC_M365_B -GroupCategory Security -GroupScope Universal -DisplayName "LIC M365 Business" -Path "OU=Licensing Groups,OU=Managed Groups,DC=demo,DC=lab,DC=internal" -Description "Members of this group will be assigned M365 Business License"
New-ADGroup -Name "LIC M365 E3" -SamAccountName LIC_M365_E3 -GroupCategory Security -GroupScope Universal -DisplayName "LIC M365 Enterprise E3" -Path "OU=Licensing Groups,OU=Managed Groups,DC=demo,DC=lab,DC=internal" -Description "Members of this group will be assigned M365 Enterprise E3 License"
New-ADGroup -Name "LIC M365 E5" -SamAccountName LIC_M365_E5 -GroupCategory Security -GroupScope Universal -DisplayName "LIC M365 Enterprise E5" -Path "OU=Licensing Groups,OU=Managed Groups,DC=demo,DC=lab,DC=internal" -Description "Members of this group will be assigned M365 Enterprise E5 License"
New-ADGroup -Name "LIC M365 F3" -SamAccountName LIC_M365_F3 -GroupCategory Security -GroupScope Universal -DisplayName "LIC M365 Enterprise F3 (Frontline)" -Path "OU=Licensing Groups,OU=Managed Groups,DC=demo,DC=lab,DC=internal" -Description "Members of this group will be assigned M365 Enterprise E5 License"
New-ADGroup -Name "LIC AAD P2" -SamAccountName LIC_AAD_P2 -GroupCategory Security -GroupScope Universal -DisplayName "LIC Azure AD P2" -Path "OU=Licensing Groups,OU=Managed Groups,DC=demo,DC=lab,DC=internal" -Description "Members of this group will be assigned M365 Enterprise E5 License"
New-ADGroup -Name "LIC EXO P2" -SamAccountName LIC_EXO -GroupCategory Security -GroupScope Universal -DisplayName "LIC Exchange Online P2" -Path "OU=Licensing Groups,OU=Managed Groups,DC=demo,DC=lab,DC=internal" -Description "Members of this group will be assigned Exchange Online P2 License"
New-ADGroup -Name "LIC Visio" -SamAccountName LIC_VSO -GroupCategory Security -GroupScope Universal -DisplayName "LIC Visio Online" -Path "OU=Licensing Groups,OU=Managed Groups,DC=demo,DC=lab,DC=internal" -Description "Members of this group will be assigned Visio Online License"
New-ADGroup -Name "LIC Project" -SamAccountName LIC_PJT -GroupCategory Security -GroupScope Universal -DisplayName "LIC Project Online" -Path "OU=Licensing Groups,OU=Managed Groups,DC=demo,DC=lab,DC=internal" -Description "Members of this group will be assigned Project Online License"

New-ADGroup -Name "NDES Servers" -SamAccountName SEC_NDES_SVR -GroupCategory Security -GroupScope Universal -DisplayName "NDES Servers" -Path "OU=Security Groups,OU=Managed Groups,DC=demo,DC=lab,DC=internal" -Description "Members of this group will be used to assign permissions for NDES Servers"


New-ADComputer -Name "SVR-MGT" -SamAccountName "SVR-MGT" -Description "Management Server [SVR2019STD]" -Path "OU=Management Servers,OU=Managed Servers,DC=demo,DC=lab,DC=internal" -Enabled $True -Location "Wellington, NZ"
New-ADComputer -Name "SVR-ERA" -SamAccountName "SVR-ERA" -Description "Enterprise Root CA Server [SVR2019STD]" -Path "OU=PKI Servers,OU=Managed Servers,DC=demo,DC=lab,DC=internal" -Enabled $True -Location "Wellington, NZ"
New-ADComputer -Name "SVR-NDES" -SamAccountName "SVR-NDES" -Description "NDES MEM Enrolment Server [SVR2019STD]" -Path "OU=PKI Servers,OU=Managed Servers,DC=demo,DC=lab,DC=internal" -Enabled $True -Location "Wellington, NZ"
New-ADComputer -Name "SVR-CDP" -SamAccountName "SVR-CDP" -Description "CDP/CRL Server [SVR2019STD]" -Path "OU=PKI Servers,OU=Managed Servers,DC=demo,DC=lab,DC=internal" -Enabled $True -Location "Wellington, NZ"
New-ADComputer -Name "SVR-SQL" -SamAccountName "SVR-SQL" -Description "SQL Server Server [SVR2019STD]" -Path "OU=Database Servers,OU=Managed Servers,DC=demo,DC=lab,DC=internal" -Enabled $True -Location "Wellington, NZ"
New-ADComputer -Name "WIN10-PC01" -SamAccountName "WIN10-PC01" -Description "Windows 10 Domain PC [WIN10 20H2]" -Path "OU=Managed Desktops,OU=Managed Clients,DC=demo,DC=lab,DC=internal" -Enabled $True -Location "Wellington, NZ"

$LabPwd = "EnterPasswordhereforlabusers!"

New-ADUser -Name "Joe Bloggs" -SamAccountName "bloggsj" -UserPrincipalName "joe.bloggs@demo.lab.internal" -GivenName "Joe" -Surname "Bloggs" -DisplayName "Joe Bloggs" `
    -Description "Fujitsu Support Account" -Department "Contractor" -Country "NZ" -City "Wellington" -Company "Fujitsu NZ" -EmailAddres "joe.bloggs@demo.lab.internal" `
    -StreetAddress "Fujitsu Tower, 141 The Terrace, Wellington, New Zealand 6011" -Title "Senior Technical Consultant" -Office "Fujitsu Tower" -Enabled $True -ChangePasswordAtLogon $False `
    -PasswordNeverExpires $False -Path "OU=Standard Users,OU=Managed Users,DC=demo,DC=lab,DC=internal" `
    -AccountPassword (convertto-securestring $LabPwd -AsPlainText -Force)

New-ADUser -Name "Adm Joe Bloggs" -SamAccountName "adm_bloggsj" -UserPrincipalName "adm_joe.bloggs@demo.lab.internal" -GivenName "Joe" -Surname "Bloggs" -DisplayName "Joe Bloggs [Admin]" `
    -Description "Fujitsu Support Account" -Department "Contractor" -Country "NZ" -City "Wellington" -Company "Fujitsu NZ" -EmailAddres "adm_joe.bloggs@demo.lab.internal" `
    -StreetAddress "Fujitsu Tower, 141 The Terrace, Wellington, New Zealand 6011" -Title "Senior Technical Consultant" -Office "Fujitsu Tower" -Enabled $True -ChangePasswordAtLogon $False `
    -PasswordNeverExpires $False -Path "OU=Administrative Users,OU=Managed Users,DC=demo,DC=lab,DC=internal" `
    -AccountPassword (convertto-securestring $LabPwd -AsPlainText -Force)
    
New-ADUser -Name "Steve McIntyre" -SamAccountName "mcintyres" -UserPrincipalName "steve.mcintyre@demo.lab.internal" -GivenName "Steve" -Surname "McIntyre" -DisplayName "Steve McIntyre" `
    -Description "Fujitsu Support Account" -Department "Contractor" -Country "NZ" -City "Wellington" -Company "Fujitsu NZ" -EmailAddres "steve.mcintyre@demo.lab.internal" `
    -StreetAddress "Fujitsu Tower, 141 The Terrace, Wellington, New Zealand 6011" -Title "Senior Technical Consultant" -Office "Fujitsu Tower" -Enabled $True -ChangePasswordAtLogon $False `
    -PasswordNeverExpires $False -Path "OU=Standard Users,OU=Managed Users,DC=demo,DC=lab,DC=internal" `
    -AccountPassword (convertto-securestring $LabPwd -AsPlainText -Force)

New-ADUser -Name "Adm Steve McIntyre" -SamAccountName "adm_mcintyres" -UserPrincipalName "adm_steve.mcintyre@demo.lab.internal" -GivenName "Steve" -Surname "McIntyre" -DisplayName "Steve McIntyre [Admin]" `
    -Description "Fujitsu Support Account" -Department "Contractor" -Country "NZ" -City "Wellington" -Company "Fujitsu NZ" -EmailAddres "adm_steve.mcintyre@demo.lab.internal" `
    -StreetAddress "Fujitsu Tower, 141 The Terrace, Wellington, New Zealand 6011" -Title "Senior Technical Consultant" -Office "Fujitsu Tower" -Enabled $True -ChangePasswordAtLogon $False `
    -PasswordNeverExpires $False -Path "OU=Administrative Users,OU=Managed Users,DC=demo,DC=lab,DC=internal" `
    -AccountPassword (convertto-securestring $LabPwd -AsPlainText -Force)

New-ADUser -Name "Fred Flintstone" -SamAccountName "flintstonef" -UserPrincipalName "fred.flintstone@demo.lab.internal" -GivenName "Fred" -Surname "Flintstone" -DisplayName "Fred Flintstone" `
    -Description "CEO" -Department "SLT" -Country "NZ" -City "Wellington" -Company "Demo Lab Inc." -EmailAddres "fred.flintstone@demo.lab.internal" `
    -StreetAddress "Fujitsu Tower, 141 The Terrace, Wellington, New Zealand 6011" -Title "Cheif Executive Officer" -Office "Fujitsu Tower" -Enabled $True -ChangePasswordAtLogon $False `
    -PasswordNeverExpires $False -Path "OU=Standard Users,OU=Managed Users,DC=demo,DC=lab,DC=internal" `
    -AccountPassword (convertto-securestring $LabPwd -AsPlainText -Force)

New-ADUser -Name "Barney Rubble" -SamAccountName "rubbleb" -UserPrincipalName "barney.rubble@demo.lab.internal" -GivenName "Barney" -Surname "Rubble" -DisplayName "Barney Rubble" `
    -Description "CTO" -Department "SLT" -Country "NZ" -City "Wellington" -Company "Demo Lab Inc." -EmailAddres "barney.rubble@demo.lab.internal" `
    -StreetAddress "Fujitsu Tower, 141 The Terrace, Wellington, New Zealand 6011" -Title "Cheif Technical Officer" -Office "Fujitsu Tower" -Enabled $True -ChangePasswordAtLogon $False `
    -PasswordNeverExpires $False -Path "OU=Standard Users,OU=Managed Users,DC=demo,DC=lab,DC=internal" `
    -AccountPassword (convertto-securestring $LabPwd -AsPlainText -Force)

Get-ADForest | Set-ADForest -UPNSuffixes @{add="M365x993667.onmicrosoft.com"}
    
#& MGT VM
Rename-computer -newname SVR-MGT
New-NetIPAddress -InterfaceAlias Ethernet -IPAddress 172.50.50.2 -DefaultGateway 172.50.50.254 -AddressFamily IPv4 -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses ("172.50.50.1","8.8.8.8")
Set-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name RegisteredOrganization -Value "Fujitsu NZ DemoLab"
$Make = Get-WmiObject Win32_ComputerSystem | Select-object -ExpandProperty Manufacturer
$Model = Get-WmiObject Win32_ComputerSystem | Select-object -ExpandProperty Model
$Logo = 'C:\Windows\System32\oobe\FujitsuLogo.bmp'
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" -Name Manufacturer -PropertyType String -Value $Make -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" -Name Model -PropertyType String -Value $Model -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" -Name Logo -PropertyType String -Value $Logo -Force
Set-Volume -DriveLetter C -NewFileSystemLabel "OS"
Restart-Computer
add-computer -domainname demo.lab.internal -Credential (Get-Credential) -restart -force
    
 #& Win 10 VM
 Rename-computer -newname WIN10-PC01
 Set-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name RegisteredOrganization -Value "Fujitsu NZ DemoLab"
 $Make = Get-WmiObject Win32_ComputerSystem | Select-object -ExpandProperty Manufacturer
 $Model = Get-WmiObject Win32_ComputerSystem | Select-object -ExpandProperty Model
 $Logo = 'C:\Windows\System32\oobe\FujitsuLogo.bmp'
 New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" -Name Manufacturer -PropertyType String -Value $Make -Force
 New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" -Name Model -PropertyType String -Value $Model -Force
 New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" -Name Logo -PropertyType String -Value $Logo -Force
 Restart-Computer
 add-computer -domainname demo.lab.internal -Credential (Get-Credential) -restart -force