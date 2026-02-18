[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

function Test-CommandAvailable {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Ensure-Winget {
    if (Test-CommandAvailable -Name "winget") {
        return
    }

    Write-Host "winget not found. Attempting bootstrap..."
    $bootstrapErrors = New-Object System.Collections.Generic.List[string]
    $tempPath = Join-Path $env:TEMP ("winget-bootstrap-" + [Guid]::NewGuid().ToString("N"))
    try {
        New-Item -Path $tempPath -ItemType Directory -Force | Out-Null
        $bundlePath = Join-Path $tempPath "Microsoft.DesktopAppInstaller.msixbundle"
        Invoke-WebRequest -Uri "https://aka.ms/getwinget" -OutFile $bundlePath
        Add-AppxPackage -Path $bundlePath
    }
    catch {
        $bootstrapErrors.Add("App Installer bootstrap failed: $($_.Exception.Message)")
    }
    finally {
        if (Test-Path -LiteralPath $tempPath) {
            Remove-Item -LiteralPath $tempPath -Recurse -Force
        }
    }

    $windowsAppsPath = Join-Path $env:LOCALAPPDATA "Microsoft\WindowsApps"
    if (($env:Path -split ";") -notcontains $windowsAppsPath) {
        $env:Path = "$windowsAppsPath;$env:Path"
    }

    if (Test-CommandAvailable -Name "winget") {
        return
    }

    if (Test-CommandAvailable -Name "scoop") {
        try {
            scoop install main/winget-cli
            if ($LASTEXITCODE -ne 0) {
                throw "scoop exited with code $LASTEXITCODE."
            }
        }
        catch {
            $bootstrapErrors.Add("Scoop fallback failed: $($_.Exception.Message)")
        }
    }

    if (Test-CommandAvailable -Name "winget") {
        return
    }

    if (Test-CommandAvailable -Name "choco") {
        $chocoInstalled = $false
        foreach ($candidate in @("winget", "winget-cli")) {
            try {
                choco install $candidate -y --no-progress
                if ($LASTEXITCODE -eq 0) {
                    $chocoInstalled = $true
                    break
                }
            }
            catch {
                $bootstrapErrors.Add("Chocolatey fallback '$candidate' failed: $($_.Exception.Message)")
            }
        }

        if (-not $chocoInstalled) {
            $bootstrapErrors.Add("Chocolatey fallback did not install winget.")
        }
    }

    if (-not (Test-CommandAvailable -Name "winget")) {
        $details = if ($bootstrapErrors.Count -gt 0) { "`n" + ($bootstrapErrors -join "`n") } else { "" }
        throw "winget is required but could not be installed automatically.$details"
    }
}

function Get-PackageManagers {
    $managers = New-Object System.Collections.Generic.List[string]
    if (Test-CommandAvailable -Name "winget") {
        $managers.Add("winget")
    }
    if (Test-CommandAvailable -Name "scoop") {
        $managers.Add("scoop")
    }
    if (Test-CommandAvailable -Name "choco") {
        $managers.Add("choco")
    }
    return $managers
}

function Select-PackageManager {
    $installed = Get-PackageManagers
    $options = New-Object System.Collections.Generic.List[string]
    $options.Add("winget")
    if ($installed -contains "scoop") {
        $options.Add("scoop")
    }
    if ($installed -contains "choco") {
        $options.Add("choco")
    }

    Write-Host "Select package manager for this installation:"
    for ($i = 0; $i -lt $options.Count; $i++) {
        $option = $options[$i]
        if ($option -eq "winget" -and -not (Test-CommandAvailable -Name "winget")) {
            Write-Host "[$($i + 1)] winget (will attempt bootstrap)"
        }
        else {
            Write-Host "[$($i + 1)] $option"
        }
    }

    while ($true) {
        $selectionInput = Read-Host "Enter selection number"
        $selectionIndex = 0
        if ([int]::TryParse($selectionInput, [ref]$selectionIndex) -and $selectionIndex -ge 1 -and $selectionIndex -le $options.Count) {
            return $options[$selectionIndex - 1]
        }
        Write-Host "Invalid selection. Please choose one of the listed numbers."
    }
}

function Install-Package {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Package,
        [Parameter(Mandatory = $true)]
        [string]$Manager
    )

    $errors = New-Object System.Collections.Generic.List[string]
    Write-Host "Installing $($Package.Name)..."

    switch ($Manager) {
        "winget" {
            if (-not [string]::IsNullOrWhiteSpace($Package.Winget)) {
                try {
                    winget install --id $Package.Winget --exact --source winget --accept-source-agreements --accept-package-agreements --silent --disable-interactivity
                    if ($LASTEXITCODE -ne 0) {
                        throw "winget exited with code $LASTEXITCODE."
                    }
                    return
                }
                catch {
                    $errors.Add("winget ($($Package.Winget)): $($_.Exception.Message)")
                }
            }
        }
        "scoop" {
            if (-not [string]::IsNullOrWhiteSpace($Package.Scoop)) {
                try {
                    scoop install $Package.Scoop
                    if ($LASTEXITCODE -ne 0) {
                        throw "scoop exited with code $LASTEXITCODE."
                    }
                    return
                }
                catch {
                    $errors.Add("scoop ($($Package.Scoop)): $($_.Exception.Message)")
                }
            }
        }
        "choco" {
            if (-not [string]::IsNullOrWhiteSpace($Package.Choco)) {
                try {
                    choco install $Package.Choco -y --no-progress
                    if ($LASTEXITCODE -ne 0) {
                        throw "choco exited with code $LASTEXITCODE."
                    }
                    return
                }
                catch {
                    $errors.Add("choco ($($Package.Choco)): $($_.Exception.Message)")
                }
            }
        }
    }

    if ($errors.Count -eq 0) {
        throw "No package manager mapping available for $($Package.Name)."
    }

    throw "Failed to install $($Package.Name).`n$($errors -join "`n")"
}

function Get-PythonCommand {
    if (Test-CommandAvailable -Name "python") {
        return "python"
    }

    if (Test-CommandAvailable -Name "py") {
        return "py"
    }

    return $null
}

function Copy-ConfigFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SourceRelativePath,
        [Parameter(Mandatory = $true)]
        [string]$DestinationPath
    )

    $sourcePath = Join-Path $PSScriptRoot $SourceRelativePath
    if (-not (Test-Path -LiteralPath $sourcePath)) {
        throw "Source file not found: $sourcePath"
    }

    $destinationDir = Split-Path -Path $DestinationPath -Parent
    if ($destinationDir -and -not (Test-Path -LiteralPath $destinationDir)) {
        New-Item -Path $destinationDir -ItemType Directory -Force | Out-Null
    }

    Copy-Item -LiteralPath $sourcePath -Destination $DestinationPath -Force
    Write-Host "Copied $SourceRelativePath -> $DestinationPath"
}

function Read-YesNo {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Prompt
    )

    $answer = Read-Host "$Prompt [y/N]"
    if ([string]::IsNullOrWhiteSpace($answer)) {
        return $false
    }

    return $answer.Trim().ToLowerInvariant() -in @("y", "yes")
}

function Install-OptionalNeovimConfig {
    $repoUrl = "https://github.com/januarpancaran/neovim-config"
    if (-not (Read-YesNo -Prompt "Install optional Neovim config from $repoUrl?")) {
        Write-Host "Skipping optional Neovim config."
        return
    }

    $targetPath = Join-Path $env:LOCALAPPDATA "nvim"
    $backupPath = $null
    if (Test-Path -LiteralPath $targetPath) {
        if (-not (Read-YesNo -Prompt "Existing config found at $targetPath. Replace it?")) {
            Write-Host "Keeping existing Neovim config."
            return
        }

        $timestamp = Get-Date -Format "yyyyMMddHHmmss"
        $backupPath = "$targetPath.backup-$timestamp"
        Move-Item -LiteralPath $targetPath -Destination $backupPath
    }

    $tempPath = Join-Path $env:TEMP ("nvim-config-" + [Guid]::NewGuid().ToString("N"))
    try {
        New-Item -Path $tempPath -ItemType Directory -Force | Out-Null
        $zipPath = Join-Path $tempPath "nvim-config.zip"
        $extractPath = Join-Path $tempPath "extract"
        Invoke-WebRequest -Uri "https://github.com/januarpancaran/neovim-config/archive/refs/heads/main.zip" -OutFile $zipPath
        Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

        $sourcePath = Join-Path $extractPath "neovim-config-main"
        if (-not (Test-Path -LiteralPath $sourcePath)) {
            throw "Unexpected archive structure for Neovim config."
        }

        Copy-Item -LiteralPath $sourcePath -Destination $targetPath -Recurse -Force
    }
    finally {
        if (Test-Path -LiteralPath $tempPath) {
            Remove-Item -LiteralPath $tempPath -Recurse -Force
        }
    }

    Write-Host "Installed Neovim config to $targetPath"
    if ($backupPath) {
        Write-Host "Previous config backed up to $backupPath"
    }
}

$selectedManager = Select-PackageManager
if ($selectedManager -eq "winget" -and -not (Test-CommandAvailable -Name "winget")) {
    Ensure-Winget
}
if (-not (Test-CommandAvailable -Name $selectedManager)) {
    throw "Selected package manager '$selectedManager' is not available."
}
Write-Host "Using package manager: $selectedManager"

$packages = @(
    @{ Name = "Git"; Winget = "Git.Git"; Scoop = "git"; Choco = "git" },
    @{ Name = "Neovim"; Winget = "Neovim.Neovim"; Scoop = "neovim"; Choco = "neovim" },
    @{ Name = "Starship"; Winget = "Starship.Starship"; Scoop = "starship"; Choco = "starship" },
    @{ Name = "zoxide"; Winget = "ajeetdsouza.zoxide"; Scoop = "zoxide"; Choco = "zoxide" },
    @{ Name = "fzf"; Winget = "junegunn.fzf"; Scoop = "fzf"; Choco = "fzf" },
    @{ Name = "bat"; Winget = "sharkdp.bat"; Scoop = "bat"; Choco = "bat" },
    @{ Name = "fastfetch"; Winget = "Fastfetch-cli.Fastfetch"; Scoop = "fastfetch"; Choco = "fastfetch" }
)

foreach ($package in $packages) {
    Install-Package -Package $package -Manager $selectedManager
}

$documents = [Environment]::GetFolderPath("MyDocuments")
$localAppData = [Environment]::GetFolderPath("LocalApplicationData")

$copyMap = @(
    @{ Source = "git-bash\.bashrc"; Destination = (Join-Path $HOME ".bashrc") },
    @{ Source = "git-bash\.bash_profile"; Destination = (Join-Path $HOME ".bash_profile") },
    @{ Source = "starship\starship.toml"; Destination = (Join-Path $HOME ".config\starship.toml") },
    @{ Source = "fastfetch\config.jsonc"; Destination = (Join-Path $localAppData "fastfetch\config.jsonc") },
    @{ Source = "powershell\Microsoft.PowerShell_profile.ps1"; Destination = (Join-Path $documents "PowerShell\Microsoft.PowerShell_profile.ps1") },
    @{ Source = "powershell\Microsoft.PowerShell_profile.ps1"; Destination = (Join-Path $documents "WindowsPowerShell\Microsoft.PowerShell_profile.ps1") },
    @{ Source = "vim\.vimrc"; Destination = (Join-Path $HOME ".vimrc") },
)

foreach ($entry in $copyMap) {
    Copy-ConfigFile -SourceRelativePath $entry.Source -DestinationPath $entry.Destination
}

Write-Host "Installation completed. Restart your terminal to apply all changes."
