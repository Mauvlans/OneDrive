# ***************************************************************************
#
# Purpose: This script creates a schedualed task and executes 
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

# Script Added Here
$content = @'

Start-Process cmd -Argument "/c subset J: %onedrive%\documents"

'@
 
# creates custom folder and write PS script

$path = $(Join-Path $env:ProgramData CustomScripts)
if (!(Test-Path $path))
{
 New-Item -Path $path -ItemType Directory -Force -Confirm:$false
}
Out-File -FilePath $(Join-Path $env:ProgramData CustomScripts\MapJDrive.ps1) -Encoding unicode -Force -InputObject $content -Confirm:$false
 
# register script as scheduled task

$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-ExecutionPolicy Bypass -NonInteractive -WindowStyle Hidden -File C:\Programdata\CustomScripts\MapJDrive.ps1"
$trigger =  New-ScheduledTaskTrigger -AtLogon -RandomDelay (New-TimeSpan -Minutes 1)
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -Hidden -DontStopIfGoingOnBatteries -Compatibility Win8
$principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Users"
$task = New-ScheduledTask -Action $action -Trigger $trigger -Settings $settings -Principal $principal
Register-ScheduledTask -InputObject $task -TaskName "MapJDrive"

#wait 10 Seconds and Kick off Schedualed Task

Start-Sleep 10
Start-ScheduledTask -TaskName "MapJDrive"
