$ErrorActionPreference = "SilentlyContinue"

function Get-OldestConnectTime {
    $oldestLogon = Get-CimInstance -ClassName Win32_LogonSession | 
        Where-Object {$_.LogonType -eq 2 -or $_.LogonType -eq 10} | 
        Sort-Object -Property StartTime | 
        Select-Object -First 1
    if ($oldestLogon) {
        return $oldestLogon.StartTime
    } else {
        return $null
    }
}

function Get-Signature {

    [CmdletBinding()]
     param (
        [string[]]$FilePath
    )

    $Existence = Test-Path -PathType "Leaf" -Path $FilePath
    $Authenticode = (Get-AuthenticodeSignature -FilePath $FilePath -ErrorAction SilentlyContinue).Status
    $Signature = "Invalid Signature (UnknownError)"

    if ($Existence) {
        if ($Authenticode -eq "Valid") {
            $Signature = "Firma Valida"
        }
        elseif ($Authenticode -eq "NotSigned") {
            $Signature = "Firma Invalida (No esta firmado)"
        }
        elseif ($Authenticode -eq "HashMismatch") {
            $Signature = "Firma Invalida (HashMismatch)"
        }
        elseif ($Authenticode -eq "NotTrusted") {
            $Signature = "Firma Invalida (NotTrusted)"
        }
        elseif ($Authenticode -eq "UnknownError") {
            $Signature = "Firma Invalida (UnknownError)"
        }
        return $Signature
    } else {
        $Signature = "El archivo no fue encontrado"
        return $Signature
    }
}

Clear-Host

Write-Host ""
Write-Host ""
Write-Host -ForegroundColor Red " Tranquilo joven usuario, estas en manos de los expertos. "
Write-Host ""
Write-Host -ForegroundColor Magenta " ░██████╗░█████╗░██╗░░░░░░█████╗░  ██╗░░░░░███████╗░██████╗░███████╗███╗░░██╗██████╗░░██████╗ "
Write-Host -ForegroundColor Magenta " ██╔════╝██╔══██╗██║░░░░░██╔══██╗  ██║░░░░░██╔════╝██╔════╝░██╔════╝████╗░██║██╔══██╗██╔════╝ "
Write-Host -ForegroundColor Magenta " ╚█████╗░██║░░██║██║░░░░░██║░░██║  ██║░░░░░█████╗░░██║░░██╗░█████╗░░██╔██╗██║██║░░██║╚█████╗░ "
Write-Host -ForegroundColor Magenta " ░╚═══██╗██║░░██║██║░░░░░██║░░██║  ██║░░░░░██╔══╝░░██║░░╚██╗██╔══╝░░██║╚████║██║░░██║░╚═══██╗ "
Write-Host -ForegroundColor Magenta " ██████╔╝╚█████╔╝███████╗╚█████╔╝  ███████╗███████╗╚██████╔╝███████╗██║░╚███║██████╔╝██████╔╝ "
Write-Host -ForegroundColor Magenta " ╚═════╝░░╚════╝░╚══════╝░╚════╝░  ╚══════╝╚══════╝░╚═════╝░╚══════╝╚═╝░░╚══╝╚═════╝░╚═════╝░ "
Write-Host ""
Write-Host -ForegroundColor Cyan "Juro lealtad inquebrantable a Kendo, Shadia, SkzW, Esteban y Yorshfly en el SS Team. Mi compromiso es un vínculo virtual, tejido con la firmeza de códigos entrelazados. En cada SS, mi lealtad persistirá, forjando una camaradería digital eterna en el vasto reino de la red. "
Write-Host ""
Write-Host -ForegroundColor DarkGreen " discord.gg/sololegends "
Write-Host ""
Write-Host ""

function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
if (!(Test-Admin)) {
    Write-Warning "Brother ejecutalo como ADMIN :V"
    Start-Sleep 10
    Exit
}

# Obtener la última vez que se encendió la computadora
$lastBootTime = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -ExpandProperty LastBootUpTime
$lastBootTime = [System.Management.ManagementDateTimeConverter]::ToDateTime($lastBootTime)
Write-Output "Última vez que se encendió la computadora: $lastBootTime"

$sw = [Diagnostics.Stopwatch]::StartNew()

if (!(Get-PSDrive -Name HKLM -PSProvider Registry)) {
    Try {
        New-PSDrive -Name HKLM -PSProvider Registry -Root HKEY_LOCAL_MACHINE
    }
    Catch {
        Write-Warning "Error montando HKEY_Local_Machine"
    }
}
$bv = ("bam", "bam\State")
Try {
    $Users = foreach($ii in $bv) {
        Get-ChildItem -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$($ii)\UserSettings\" | Select-Object -ExpandProperty PSChildName
    }
}
Catch {
    Write-Warning "Error Parseando BAM Key. Probablemente no soporta tu version de Windows :( "
    Exit
}
$rpath = @("HKLM:\SYSTEM\CurrentControlSet\Services\bam\", "HKLM:\SYSTEM\CurrentControlSet\Services\bam\state\")

$UserTime = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation").TimeZoneKeyName
$UserBias = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation").ActiveTimeBias
$UserDay = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation").DaylightBias

$Bam = Foreach ($Sid in $Users) {
    $u++

    foreach($rp in $rpath) {
        $BamItems = Get-Item -Path "$($rp)UserSettings\$Sid" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Property
        Write-Host -ForegroundColor DarkRed "Extrayendo " -NoNewLine
        Write-Host -ForegroundColor White "$($rp)UserSettings\$SID"
        $bi = 0 

        Try {
            $objSID = New-Object System.Security.Principal.SecurityIdentifier($Sid)
            $User = $objSID.Translate([System.Security.Principal.NTAccount])
            $User = $User.Value
        }
        Catch {
            $User = ""
        }
        $i = 0
        ForEach ($Item in $BamItems) {
            $i++
            $Key = Get-ItemProperty -Path "$($rp)UserSettings\$Sid" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $Item

            If ($key.length -eq 24) {
                $Hex = [System.BitConverter]::ToString($key[7..0]) -replace "-",""
                $TimeLocal = Get-Date ([DateTime]::FromFileTime([Convert]::ToInt64($Hex, 16))) -Format "yyyy-MM-dd HH:mm:ss"
                $TimeUTC = Get-Date ([DateTime]::FromFileTimeUtc([Convert]::ToInt64($Hex, 16))) -Format "yyyy-MM-dd HH:mm:ss"
                $Bias = -([convert]::ToInt32([Convert]::ToString($UserBias,2),2))
                $Day = -([convert]::ToInt32([Convert]::ToString($UserDay,2),2))
                $Biasd = $Bias / 60
                $Dayd = $Day / 60
                $TimeUser = (Get-Date ([DateTime]::FromFileTimeUtc([Convert]::ToInt64($Hex, 16))).addminutes($Bias)) -Format "yyyy-MM-dd HH:mm:ss"
                
                if ($TimeUTC -gt $lastBootTime) {
                    $d = if ((((split-path -path $item) | ConvertFrom-String -Delimiter "\\").P3) -match '\d{1}') {
                        ((split-path -path $item).Remove(23)).trimstart("\Device\HarddiskVolume")
                    } else {
                        ""
                    }
                    $f = if ((((split-path -path $item) | ConvertFrom-String -Delimiter "\\").P3) -match
