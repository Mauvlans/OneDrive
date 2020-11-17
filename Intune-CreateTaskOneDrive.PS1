<#
.SYNOPSIS
    Creates a scheduled task to enable folder redirection into OneDrive
#>

# Variables
$Url = "Redirect-FoldersOneDrive.ps1"
$Target = "$env:ProgramData\Scripts"
$Script = "Redirect-FoldersOneDrive.ps1"
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

Set-Location $ScriptDir

# If local path for script doesn't exist, create it
If (!(Test-Path $Target)) { New-Item -Path $Target -Type Directory -Force }

# Download the script from the source repository
If (Test-Path "$Target\$Script") { Remove-Item -Path "$Target\$Script" -Force }
Copy-Item -Path $Url -Destination $Target

# Create the scheduled task to run the script at logon
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-ExecutionPolicy Bypass -NonInteractive -WindowStyle Hidden -File $Target\$Script"
$trigger =  New-ScheduledTaskTrigger -AtLogon -RandomDelay (New-TimeSpan -Minutes 1)
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -Hidden -DontStopIfGoingOnBatteries -Compatibility Win8
$principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Users"
$task = New-ScheduledTask -Action $action -Trigger $trigger -Settings $settings -Principal $principal
Register-ScheduledTask -InputObject $task -TaskName "Redirect Folders to OneDrive"

#Remove Get Help & Poeple Apps

Write-Output "Uninstalling default apps"

$apps = @(
    "Microsoft.GetHelp"

    "Microsoft.People"
)

foreach ($app in $apps) {
    Write-Output "Trying to remove $app"

    Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage

    Get-AppXProvisionedPackage -Online |

        Where-Object DisplayName -EQ $app |

        Remove-AppxProvisionedPackage -Online

}

Stop-Transcript