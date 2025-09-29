param(
    [switch]$Install,
    [switch]$SkipPip
)

# Packages
$packages = @(
    "Neovim.Neovim",
    "Starship.Starship", 
    "feraxhp.grp",
    "Git.Git",
    "Microsoft.PowerShell",
    "Fastfetch-cli.Fastfetch",
    "Python.Python.3.13"
)

$pipPackages = @(
    "trash-cli"
)

function Test-AdminRights {
    return ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-Winget {
    if (-not (Test-AdminRights)) {
        Write-Warning "Administrator privileges required for Winget installation."
        return $false
    }

    try {
        Write-Output "Downloading and installing Winget..."
        $releases = Invoke-RestMethod -Uri "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
        $downloadUrl = $releases.assets | Where-Object { $_.name -like "*.msixbundle" } | Select-Object -First 1 -ExpandProperty browser_download_url

        $tempPath = "$env:TEMP\winget.msixbundle"
        Invoke-WebRequest -Uri $downloadUrl -OutFile $tempPath
        Add-AppxPackage $tempPath
        Remove-Item $tempPath -Force

        Write-Output "Winget installed successfully."
        return $true
    }
    catch {
        Write-Error "Failed to install Winget: $_"
        return $false
    }
}

function Install-Package {
    param(
        [string]$packageName,
        [string]$helper
    )

    Write-Output "Installing $packageName using $helper..."

    try {
        switch ($helper) {
            "winget" {
                $result = winget install $packageName --accept-package-agreements --accept-source-agreements
                if ($LASTEXITCODE -eq 0) {
                    Write-Output "✓ Successfully installed $packageName"
                    return $true
                }
                elseif ($LASTEXITCODE -eq -1978335189) {
                    Write-Output "✓ $packageName is already installed"
                    return $true
                }
                else {
                    Write-Warning "✗ Failed to install $packageName (Exit code: $LASTEXITCODE)"
                    return $false
                }
            }
            "choco" {
                $result = choco install $packageName -y
                if ($LASTEXITCODE -eq 0) {
                    Write-Output "✓ Successfully installed $packageName"
                    return $true
                }
                elseif ($LASTEXITCODE -eq 1641 -or $LASTEXITCODE -eq 3010) {
                    Write-Output "✓ $packageName installed (reboot may be required)"
                    return $true
                }
                else {
                    Write-Warning "✗ Failed to install $packageName (Exit code: $LASTEXITCODE)"
                    return $false
                }
            }
            "scoop" {
                $result = scoop install $packageName
                if ($LASTEXITCODE -eq 0) {
                    Write-Output "✓ Successfully installed $packageName"
                    return $true
                }
                elseif ($result -match "is already installed") {
                    Write-Output "✓ $packageName is already installed"
                    return $true
                }
                else {
                    Write-Warning "✗ Failed to install $packageName (Exit code: $LASTEXITCODE)"
                    return $false
                }
            }
        }
    }
    catch {
        Write-Error "Error installing $packageName : $_"
        return $false
    }
}

function Install-PipPackages {
    param([array]$packages)

    if (-not (Get-Command pip -ErrorAction SilentlyContinue)) {
        Write-Warning "pip not found. Make sure python is installed and in PATH"
        return 
    }

    Write-Output "`nInstalling pip packages..."

    foreach ($package in $packages) {
        Write-Output "Installing $package via pip..."
        try {
            pip install $package
            if ($LASTEXITCODE -eq 0) {
                Write-Output "✓ Successfully installed $package"
            }
            else {
                Write-Warning "✗ Failed to install $package via pip"
            }
        }
        catch {
            Write-Error "Error installing $package via pip: $_"
        }
    }
}

# Check package managers
Write-Output "=== Package Manager Detection ==="
$availableHelpers = @()

if (Get-Command winget -ErrorAction SilentlyContinue) { $availableHelpers += "winget" }
if (Get-Command choco -ErrorAction SilentlyContinue) { $availableHelpers += "choco" }
if (Get-Command scoop -ErrorAction SilentlyContinue) { $availableHelpers += "scoop" }

if ($availableHelpers.Count -eq 0) {
    Write-Output "No package managers detected."
    $confirm = Read-Host "Do you want to install Winget? (Y/N)"

    if ($confirm -in @("Y", "YES", "y", "yes")) {
        if (Install-Winget) {
            $selectedHelper = "winget"
        }
        else {
            Write-Error "Failed to install Winget. Exiting."
            exit 1
        }
    }
    else {
        Write-Output "Installation cancelled. Exiting script."
        exit 1
    }
}
else {
    $priority = @("winget", "choco", "scoop")
    $selectedHelper = $priority | Where-Object { $_ -in $availableHelpers } | Select-Object -First 1
    Write-Output "Available package managers: $($availableHelpers -join ', ')"
}

Write-Output "Selected package manager: $selectedHelper"

# Install packages
if ($Install) {
    Write-Output "`n=== Installing Predefined Packages ==="
    $successCount = 0
    $totalCount = $packages.Count
    
    foreach ($package in $packages) {
        if (Install-Package -packageName $package -helper $selectedHelper) {
            $successCount++
        }
    }
    
    Write-Output "`n=== Package Installation Summary ==="
    Write-Output "Successfully installed: $successCount/$totalCount packages"
    
    if (-not $SkipPip) {
        Install-PipPackages -packages $pipPackages
    }
    else {
        Write-Output "Skipping pip packages installation."
    }
}
elseif ($packageName) {
    Write-Output "`n=== Installing Single Package ==="
    Install-Package -packageName $package -helper $selectedHelper
}
else {
    Write-Output "`n=== Usage Instructions ==="
    Write-Output "Usage options:"
    Write-Output "  .\script.ps1 -Install          # Install all predefined packages"
    Write-Output "  .\script.ps1 -Install -SkipPip # Install packages but skip pip packages"
    Write-Output ""
    Write-Output "Predefined packages:"
    $packages | ForEach-Object { Write-Output "  - $_" }
    Write-Output ""
    Write-Output "Predefined pip packages:"
    $pipPackages | ForEach-Object { Write-Output "  - $_" }
}

# Moving Configuration Files
Write-Output "Moving Configuration Files"

$HOME_DIR = $env:USERPROFILE

if (Test-Path "git-bash") {
    Get-ChildItem -Path "git-bash\*" | Copy-Item -Destination $HOME_DIR -Force
}

if (Test-Path "vim") {
    Get-ChildItem -Path "vim\*" | Copy-Item -Destination $HOME_DIR -Force
}

# Create and Populate Config Dir
$CONFIG_DIR = Join-Path $HOME_DIR ".config"
if (-not (Test-Path $CONFIG_DIR)) {
    New-Item -ItemType Directory -Path $CONFIG_DIR -Force | Out-Null

    if (Test-Path "fastfetch") {
        Copy-Item -Path "fastfetch" -Destination $CONFIG_DIR -Force
    }

    if (Test-Path "starship") {
        Copy-Item -Path "starship" -Destination $CONFIG_DIR -Force
    }
}

# Create and Populate Neovim Dir
$NVIM_DIR = Join-Path $HOME_DIR "AppData\Local\nvim"
if (-not (Test-Path $NVIM_DIR)) {
    New-Item -ItemType Directory -Path $NVIM_DIR -Force | Out-Null

    if (Test-Path "nvim") {
        Get-ChildItem -Path "nvim\*" | Copy-Item -Destination $NVIM_DIR -Force
    }
}

# Create and Populate Windows Powershell Dir
$POWERSHELL_DIR = Join-Path $HOME_DIR "Documents\WindowsPowerShell"
if (-not (Test-Path $POWERSHELL_DIR)) {
    New-Item -ItemType Directory -Path $POWERSHELL_DIR -Force | Out-Null

    if (Test-Path "powershell") {
        Get-ChildItem -Path "powershell\*" | Copy-Item -Destination $POWERSHELL_DIR -Force
    }
}

# Create and Populate Pwsh Dir
$PWSH_DIR = Join-Path $HOME_DIR "Documents\Powershell"
if (Get-Command pwsh -ErrorAction SilentlyContinue) {
    if (-not (Test-Path $PWSH_DIR)) {
        New-Item -ItemType Directory -Path $PWSH_DIR -Force | Out-Null
    }

    if (Test-Path "powershell") {
        Get-ChildItem -Path "powershell\*" | Copy-Item -Destination $PWSH_DIR -Force
    }
}

Write-Output "Installation Completed!"