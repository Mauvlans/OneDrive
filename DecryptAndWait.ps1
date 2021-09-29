# ***************************************************************************
#
# Purpose: Decrypts Specified Drive and waits for completion
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

$ComputerName = "."
$BitLockerDrive = Get-Wmiobject -Namespace "root\CIMv2\Security\MicrosoftVolumeEncryption" -Class "Win32_EncryptableVolume" -ComputerName $ComputerName -Filter "DriveLetter='C:'"
$Status = $BitLockerDrive.GetConversionStatus()
if ($Status.ConversionStatus -eq 0) {
    {Exit}
}
elseif ($Status.ConversionStatus -eq 1) {
    Invoke-Command {manage-bde.exe -off C:}
    Clear-Host
    Start-Sleep 3
    do {
        $BitLockerDrive = Get-Wmiobject -Namespace "root\CIMv2\Security\MicrosoftVolumeEncryption" -Class "Win32_EncryptableVolume" -ComputerName $ComputerName -Filter "DriveLetter='C:'"
        $Status = $BitLockerDrive.GetConversionStatus()
        Start-Sleep 15
    }
    until ($Status.ConversionStatus -eq 0)
}
if ($Status.ConversionStatus -eq 0) {
    {Exit}
}
