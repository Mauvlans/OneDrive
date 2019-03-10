# ***************************************************************************
#
# Purpose: One Drive Consolidate and Wait for Sync
#
# ------------- DISCLAIMER -------------------------------------------------
# This script code is provided as is with no guarantee or waranty concerning
# the usability or impact on systems and may be used, distributed, and
# modified in any way provided the parties agree and acknowledge the 
# Microsoft or Microsoft Partners have neither accountabilty or 
# responsibility for results produced by use of this script.
#
# Microsoft will not provide any support through any means.
# ------------- DISCLAIMER -------------------------------------------------
#
# ***************************************************************************

$ODFolderName = "OneDrive - Mauvlan"
$Source = "C:\"
$exclude_directories = @()
$IncludeType = @()
$Destination = "$env:userprofile\$ODFolderName\ODConsolidate"
$IncludeType = "*.jpg", "*.doc", "*.docx", "*.xls", "*.xlsx", "*.csv"
$exclude_directories = "c:\windows", "c:\data", "c:\program files"
$exclude_directories = $exclude_directories + $Destination
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
function ConsolidateFiles {
    param($DestinationDir)
    Get-ChildItem -path $Source -recurse -include $IncludeType -Exclude $exclude_directories -ErrorAction SilentlyContinue -PipelineVariable file | `
        ForEach-Object {
        $DestinationFile = "$DestinationDir\$(($file).Name)"
        if (!(($file).DirectoryName | Select-String $exclude_directories -simple)) {
            write-host "$($file).name)"
            if (Test-Path $DestinationFile) {
                $i = 0
                while (Test-Path $DestinationFile) {
                    $i += 1
                    $DestinationFile = "$DestinationDir\$(($file).basename)$i$(($file).extension)"
                }
                Copy-Item -Path $file -Destination $DestinationFile -Verbose -Force
            }
            else {
                Copy-Item -Path $file -Destination $DestinationFile -Verbose -Force
            }
        }
    }

    Write-Host "Files have successfully been copied" -ErrorAction SilentlyContinue

}
function WaitForSync {
    
    $Status = Get-ODStatus -ByPath "C:\Users\$env:username\$ODFolderName"
    if ($Status -eq "UpToDate") {
        {
            Write-Output "One Drive Up To Date Continuing"
            Exit
        }
    }
    elseif ($Status -eq "Syncing") {
        Clear-Host
        Start-Sleep 3
        do {
            $Status = Get-ODStatus -ByPath "C:\Users\$env:username\$ODFolderName"
            Write-Output "Onedrive is"$Status
            Start-Sleep 15
        }
        until ($Status -eq "UpToDate")
    }
}
function OneDriveLibOld {

        Param([string]$name) 
        if (-not(Get-Module -name $name)) { 
            if (Get-Module -ListAvailable | 
                    Where-Object { $_.name -eq $name }) {
                Copy-Item -path 
                Import-Module -Name $name 
                $true 
            } #end if module available then import 
            else { $false } #module not available 
        } # end if not module 
        else { $true } #module already loaded 
    } 

function OneDriveLib {

    Copy-Item -Path $ScriptDir\OneDriveLib.dll -Destination $env:psmodulePath -Force -Verbose

    Import-Module OneDriveLib.dll
}

if (!(test-path $Destination)) {New-Item -ItemType directory -Path $Destination -Verbose}

#OneDriveLib -name "OneDriveLib"
#Import-Module .\OneDriveLib.dll

OneDriveLib

ConsolidateFiles -DestinationDir $Destination

WaitForSync
