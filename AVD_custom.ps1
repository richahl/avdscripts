# Start logging
Start-Transcript "$($env:ProgramData)\Microsoft\RemoveWinApps\RemoveWinAppsv1.log"

# List of built-in apps to remove
$UninstallPackages = @(
    "Microsoft.BingWeather"
    "Microsoft.549981C3F5F10"
    "Microsoft.StorePurchaseApp"
    "Microsoft.Windows.DevHome"
    "Microsoft.GamingApp"
    "Microsoft.GetHelp"
    "Microsoft.Getstarted"
    "Microsoft.Messaging"
    "Microsoft.Microsoft3DViewer"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.MixedReality.Portal"
    "Microsoft.Office.OneNote"
    "Microsoft.OneConnect"
    "Microsoft.OutlookForWindows"
    "Microsoft.People"
    "Microsoft.Print3D"
    "Microsoft.SkypeApp"
    "Microsoft.Wallet"
    "Microsoft.WindowsAlarms"
    "microsoft.windowscommunicationsapps"
    "Microsoft.WindowsFeedbackHub"
    "Microsoft.WindowsCamera"
    "Microsoft.WindowsMaps"
    "Microsoft.XboxApp"
    "Microsoft.Xbox.TCUI"
    "Microsoft.XboxGameOverlay"
    "Microsoft.XboxGamingOverlay"
    "Microsoft.XboxIdentityProvider"
    "Microsoft.XboxSpeechToTextOverlay"
    "Microsoft.YourPhone"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"
    "MicrosoftCorporationII.QuickAssist"
)

# List of programs to uninstall
$UninstallPrograms = @(
)

# List of Windows Capabilities to uinstall
$UninstallCapabilities = @(
    "App.Support.QuickAssist~~~~0.0.1.0"
    "App.Support.ContactSupport~~~~0.0.1.0"
)

$InstalledPackages = Get-AppxPackage -AllUsers | Where {($UninstallPackages -contains $_.Name)}

$ProvisionedPackages = Get-AppxProvisionedPackage -Online | Where {($UninstallPackages -contains $_.DisplayName)}

$InstalledPrograms = Get-Package | Where {$UninstallPrograms -contains $_.Name}

$InstalledCapabilities = Get-WindowsCapability -Online | Where {$UninstallCapabilities -contains $_.Name}

# Remove provisioned packages first
ForEach ($ProvPackage in $ProvisionedPackages) {

    Write-Host -Object "Attempting to remove provisioned package: [$($ProvPackage.DisplayName)]..."

    Try {
        $Null = Remove-AppxProvisionedPackage -PackageName $ProvPackage.PackageName -Online -ErrorAction Stop
        Write-Host -Object "Successfully removed provisioned package: [$($ProvPackage.DisplayName)]"
    }
    Catch {Write-Warning -Message "Failed to remove provisioned package: [$($ProvPackage.DisplayName)]"}
}

# Remove appx packages
ForEach ($AppxPackage in $InstalledPackages) {
                                            
    Write-Host -Object "Attempting to remove Appx package: [$($AppxPackage.Name)]..."

    Try {
        $Null = Remove-AppxPackage -Package $AppxPackage.PackageFullName -AllUsers -ErrorAction Stop
        Write-Host -Object "Successfully removed Appx package: [$($AppxPackage.Name)]"
    }
    Catch {Write-Warning -Message "Failed to remove Appx package: [$($AppxPackage.Name)]"}
}

# Remove installed programs
$InstalledPrograms | ForEach {

    Write-Host -Object "Attempting to uninstall: [$($_.Name)]..."

    Try {
        $Null = $_ | Uninstall-Package -AllVersions -Force -ErrorAction Stop
        Write-Host -Object "Successfully uninstalled: [$($_.Name)]"
    }
    Catch {Write-Warning -Message "Failed to uninstall: [$($_.Name)]"}
}

# Remove Windows Capabilities
$InstalledCapabilities | ForEach {

    Write-Host -Object "Attempting to uninstall: [$($InstalledCapabilities.Name)]..."

    Try {
        $Null = $_ | Remove-WindowsCapability -online -name $InstalledCapabilities.Name -ErrorAction Stop
        Write-Host -Object "Successfully uninstalled: [$($InstalledCapabilities.Name)]"
    }
    Catch {Write-Warning -Message "Failed to uninstall: [$($InstalledCapabilities.Name)]"}
}

$RegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Dsh"
New-Item -Path $RegistryPath -Force
New-ItemProperty -Path $RegistryPath -Name "AllowNewsAndInterests" -Value "0" -PropertyType dword -Force



Stop-Transcript