## Define new class name and date
$NewClassName = 'Win32_PnpSignedDriver_Custom'
$Date = Get-Date

## Remove class if exists
Remove-WmiObject $NewClassName -ErrorAction SilentlyContinue

# Create new WMI class
$newClass = New-Object System.Management.ManagementClass ("root\cimv2", [String]::Empty, $null)
$newClass["__CLASS"] = $NewClassName

## Create properties you want inventoried
$newClass.Qualifiers.Add("Static", $true)
$newClass.Properties.Add("DeviceClass", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("DeviceName", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("DriverDate", [System.Management.CimType]::DateTime, $false)
$newClass.Properties.Add("DriverProviderName", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("DriverVersion", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("HardwareID", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("DeviceID", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("ScriptLastRan", [System.Management.CimType]::String, $false)
$newClass.Properties["DeviceName"].Qualifiers.Add("Key", $true)
$newClass.Properties["DeviceID"].Qualifiers.Add("Key", $true)
$newClass.Put() | Out-Null

## Gather current driver information
Get-WmiObject win32_pnpsigneddriver -Property DeviceClass, DeviceName,DriverDate,DriverProviderName,DriverVersion,HardwareID,DeviceID | 
Where-Object {$_.DeviceClass -ne 'VOLUMESNAPSHOT' -and $_.DeviceClass -ne 'LEGACYDRIVER' -and $_.DriverProviderName -ne 'Microsoft' -and $_.DriverVersion -notlike "2:5*"} | 
ForEach-Object {

    ## Set driver information in new class
    Set-WmiInstance -Namespace root\cimv2 -class $NewClassName -argument @{
        DeviceClass = $_.DeviceClass;
        DeviceName = $_.DeviceName;
        DriverDate = $_.DriverDate;
        DriverProviderName = $_.DriverProviderName;
        DriverVersion = $_.DriverVersion;
        HardwareID = $_.HardwareID;
        DeviceID = $_.DeviceID;
        ScriptLastRan = $Date
	} | Out-Null
}

Write-Output "Complete"