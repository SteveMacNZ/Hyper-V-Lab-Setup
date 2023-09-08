# Hyper-V Lab Setup - Updated to leverage MSLAB
## Overview
 Additional files and PowerShell scripts to be used in conjuntction with the MSLAB kit https://aka.ms/mslab/download

## MSLAB-Supplemental
 Contains customisations and additional configuration scripts to be used with MSLAB:
 * DesktopInfo https://www.glenn.delahoy.com/desktopinfo/
     Download and extract zip file copy to .\Temp\ToolsVHD\Installers copy ini and png into folder to apply customisation
   * desktopinfo.ini ==> customised configuration file for DesktopInfo
   * Fujitsu-Logo-transparent.png ==> logo used in configuration file  
 * LabConfig
   * LabConfig.ps1 ==> replaces the default LabConfig.ps1 provided in the MSLAB kit (rename orginal before replacing)
 * PostSetup - contains scripts to be run post lab configuration
   * Invoke-InstallWindowsTerminal.ps1 ==> to install Windows Terminal on Servers https://github.com/microsoft/terminal
     Create WindowsTerminal Folder under .\Temp\ToolsVHD\Installers copy ps1 script and required modules from terminal_preinstallkit
   * CIS-Server2022.zip ==> CIS baseline group policies for Server 2022 + WMI Filters [extract to root of ToolsVHD]
   * GPOBackup.zip ==> Group Policy exports for LAPs & Renaming Local Admin account [extract to root of ToolsVHD]
   * Invoke-PostLabSetup.ps1 ==> Run on DC after installing to configure OUs, Groups, Users & Import GPO Backups





## Notes
 * Best viewed in Microsoft Visual Studio Code with Colorful Comments extension installed
 * Requires Hyper-V Role installed on your device (Works on Windows 10/11 - Enable the Hyper-V feature NB: Virtualisation needs to be enabled in BIOS)
