# Hyper-V Lab Setup - Updated to leverage MSLAB
## Overview
 Additional files and PowerShell scripts to be used in conjuntction with the MSLAB kit https://aka.ms/mslab/download

## MSLAB-Supplemental
 Contains customisations and additional configuration scripts to be used with MSLAB:
 * DesktopInfo https://www.glenn.delahoy.com/desktopinfo/
     <br> Download and extract zip file copy to .\Temp\ToolsVHD\Installers copy ini and png into folder to apply customisation
   * **desktopinfo.ini** - customised configuration file for DesktopInfo
   * **Fujitsu-Logo-transparent.png** - logo used in configuration file  
 * LabConfig
   * **LabConfig.ps1** - replaces the default LabConfig.ps1 provided in the MSLAB kit (rename orginal before replacing)
   * **Add-DesktopInfo.ps1** - Mounts parent disk and copies DesktopInfo to C:\ProgramData\DesktopInfo and creates startup shortcut [run after comletion of 2_CreateParentDisks.ps1]
   * **New-WindowsClientParents.ps1** - Creates Windows 10/11 Parent Image  [Using https://github.com/x0nn/Convert-WindowsImage save to x0nn folder] 
   * **Set-VMSettings.ps1** - Run after deploying lab using .\Deploy.ps1 to set VM Min/Max RAM and VM behaviour
 * PostSetup - contains scripts to be run post lab configuration
   * **Invoke-InstallWindowsTerminal.ps1** - to install Windows Terminal on Servers https://github.com/microsoft/terminal
     <br> Create WindowsTerminal Folder under .\Temp\ToolsVHD\Installers copy ps1 script and required modules from terminal_preinstallkit
   * **CIS-Server2022.zip** - CIS baseline group policies for Server 2022 + WMI Filters [extract to root of ToolsVHD]
   * **GPOBackup.zip** - Group Policy exports for LAPs & Renaming Local Admin account [extract to root of ToolsVHD]
   * **Invoke-PostLabSetup.ps1** - Run on DC after installing to configure OUs, Groups, Users & Import GPO Backups
     * Sets Custom UPN if needed for AD Connect Sync to M365   
     *  Creates OUs  
     *  Creates Licensing Groups  
     *  Creates NDES groups  
     *  Creates Windows LAPS groups
     *  Creates User accounts [Standard and Admin Accounts] 
     *  Creates NDES Service Account 
     *  Extends AD Schema for Windows LAPS 
     *  Imports Group Policies from export [CIS Baseline, LAPS and rename local admin]
   *  **Invoke-InstallDSCModules.ps1** - Installs DSC modules from PSGallery based on the server role  
   - [ ] **DSC Scripts** - Desired State Configuration  (ToDo)
  

## Notes
 * Best viewed in Microsoft Visual Studio Code with Colorful Comments extension installed
 * Requires Hyper-V Role installed on your device (Works on Windows 10/11 - Enable the Hyper-V feature NB: Virtualisation needs to be enabled in BIOS)
