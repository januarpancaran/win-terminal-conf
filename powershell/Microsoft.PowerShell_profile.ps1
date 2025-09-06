# History
Set-PSReadLineOption -HistorySaveStyle SaveIncrementally
Set-PSReadLineOption -MaximumHistoryCount 10000
Set-PSReadLineOption -HistoryNoDuplicates:$true
Set-PsReadLineOption -HistorySavePath "$env:USERPROFILE\.ps_history"

# Keybinding
Set-PSReadLineKeyHandler -Chord "Ctrl+p" -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Chord "Ctrl+n" -Function HistorySearchForward

# Fastfetch
if (Get-Command fastfetch -ErrorAction SilentlyContinue) {
  fastfetch
}

# Aliases
Set-Alias vi "nvim"
Set-Alias vim "nvim"
function nfzf { nvim (fzf -m --preview 'bat --color=always {}') }
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }

# Autostarts
Invoke-Expression (&starship init powershell)
Invoke-Expression (& { zoxide init powershell | Out-String })
