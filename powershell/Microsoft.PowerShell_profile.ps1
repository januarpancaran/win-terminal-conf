# History
if (Get-Module -ListAvailable PSReadLine) {
    Set-PSReadLineOption -HistorySaveStyle SaveIncrementally
    Set-PSReadLineOption -MaximumHistoryCount 10000
    Set-PSReadLineOption -HistoryNoDuplicates:$true
    Set-PSReadLineOption -HistorySavePath "$env:USERPROFILE\.ps_history"
}

# Keybinding
Set-PSReadLineKeyHandler -Chord "Ctrl+p" -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Chord "Ctrl+n" -Function HistorySearchForward

# Aliases
Set-Alias vi "nvim"
Set-Alias vim "nvim"
function nfzf { nvim (fzf -m --preview 'bat --color=always {}') }
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }

# Autostarts
if (Get-Command fastfetch.exe -ErrorAction SilentlyContinue) {
    fastfetch.exe
}

if (Get-Command starship.exe -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship.exe init powershell)
}

if (Get-Command zoxide.exe -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { zoxide.exe init powershell | Out-String })
}
