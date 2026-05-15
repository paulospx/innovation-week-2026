<#
.SYNOPSIS
    Downloads packages (NuGet, PowerShell modules, or generic files) using pure PowerShell.

.DESCRIPTION
    Accepts a list of package names and downloads them to a specified folder.
    Supports:
      - NuGet packages (.nupkg) from nuget.org
      - PowerShell modules from PSGallery
      - Generic URLs (if you pass full URLs instead of names)

.EXAMPLE
    .\Download-Packages.ps1 -PackageNames "Newtonsoft.Json", "Microsoft.PowerShell.Management" -Destination "C:\Downloads\Packages"

.EXAMPLE
    .\Download-Packages.ps1 -PackageNames "https://example.com/file.zip" -Destination "C:\Temp"
#>

param(
    [Parameter(Mandatory=$true)]
    [string[]]$PackageNames,

    [string]$Destination = ".\Downloads",

    [ValidateSet("NuGet", "PSModule", "Auto")]
    [string]$Type = "Auto"
)

# Create destination folder
$Destination = Resolve-Path -Path $Destination -ErrorAction SilentlyContinue
if (-not $Destination) {
    $Destination = New-Item -Path $Destination -ItemType Directory -Force
}

Write-Host "Downloading to: $Destination" -ForegroundColor Green

foreach ($item in $PackageNames) {
    Write-Host "`nProcessing: $item" -ForegroundColor Cyan

    try {
        if ($item -like "http*") {
            # Direct URL download
            $fileName = [System.IO.Path]::GetFileName($item)
            $outPath = Join-Path $Destination $fileName
            Invoke-WebRequest -Uri $item -OutFile $outPath -UseBasicParsing
            Write-Host "  Downloaded: $fileName" -ForegroundColor Green
        }
        elseif ($Type -eq "PSModule" -or ($Type -eq "Auto" -and $item -notmatch "\.")) {
            # PowerShell Module
            # Check for version in name (e.g., ModuleName:1.2.3)
            if ($item -match ":([\d\.]+)$") {
                $modName, $modVersion = $item -split ":"
                Save-Module -Name $modName -Path $Destination -RequiredVersion $modVersion -Force -ErrorAction Stop
                Write-Host "  Saved PowerShell module: $modName ($modVersion)" -ForegroundColor Green
            } else {
                # List available versions
                $modName = $item
                $moduleInfo = Find-Module -Name $modName -ErrorAction Stop
                Write-Host "  No version specified. Available versions for $modName (latest last):" -ForegroundColor Yellow
                $moduleInfo.Version | ForEach-Object { Write-Host "    $_" }
                Save-Module -Name $modName -Path $Destination -Force -ErrorAction Stop
                Write-Host "  Saved PowerShell module: $modName (latest)" -ForegroundColor Green
            }
        }
        else {
            # NuGet package (default)
            # Check for version in name (e.g., PackageName:1.2.3)
            if ($item -match ":([\d\.]+)$") {
                $pkgName, $pkgVersion = $item -split ":"
            } else {
                $pkgName = $item
                $pkgVersion = $null
            }
            $nugetSource = "https://api.nuget.org/v3/index.json"
            $metadata = Invoke-RestMethod -Uri "https://api.nuget.org/v3/registration5-gz-semver2/$($pkgName.ToLower())/index.json" -UseBasicParsing
            Write-Host "  Metadata for $pkgName retrieved successfully." -ForegroundColor Green
            $allVersions = @()
            foreach ($entry in $metadata.items) {
                foreach ($ver in $entry.items) {
                    $allVersions += $ver.catalogEntry.version
                }
            }
            if ($pkgVersion) {
                if ($allVersions -contains $pkgVersion) {
                    $downloadVersion = $pkgVersion
                } else {
                    Write-Host "  Version $pkgVersion not found for $pkgName. Available versions:" -ForegroundColor Yellow
                    $allVersions | ForEach-Object { Write-Host "    $_" }
                    throw "Version $pkgVersion not found."
                }
            } else {
                Write-Host "  No version specified. Available versions for $pkgName (latest last):" -ForegroundColor Yellow
                $allVersions | ForEach-Object { Write-Host "    $_" }
                $downloadVersion = $allVersions[-1]
                Write-Host "  Downloading latest version: $downloadVersion" -ForegroundColor Green
            }
            $downloadUrl = "https://www.nuget.org/api/v2/package/$pkgName/$downloadVersion"
            $fileName = "$pkgName.$downloadVersion.nupkg"
            $outPath = Join-Path $Destination $fileName
            Invoke-WebRequest -Uri $downloadUrl -OutFile $outPath -UseBasicParsing
            Write-Host "  Downloaded NuGet package: $fileName" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "  Failed to download $item : $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`nAll downloads completed!" -ForegroundColor Green