$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
if ($myWindowsPrincipal.IsInRole($adminRole)) {
    $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
    $Host.UI.RawUI.BackgroundColor = "DarkBlue"
    clear-host
} else {
    $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
    $newProcess.Arguments = $myInvocation.MyCommand.Definition;
    $newProcess.Verb = "runas";
    [System.Diagnostics.Process]::Start($newProcess);
    exit
}

winget install -e --id Python.Python.3.10
winget install -e --id Git.Git
winget install -e --id Microsoft.VisualStudioCode
winget install -e --id Google.AndroidStudio
winget install -e --id OpenJS.NodeJS.LTS
winget install -e --id Oracle.JDK.19
winget install -e --id Oracle.JavaRuntimeEnvironment
winget install -e --id Microsoft.DotNet.SDK.Preview
winget install -e --id Docker.DockerDesktop --location "C:\WINGET\Development\Docker"
winget install -e --id Microsoft.PowerToys
winget install -e --id Valve.Steam
winget install -e --id Discord.Discord
winget install -e --id Zoom.Zoom
winget install -e --id OpenWhisperSystems.Signal
winget install -e --id Google.Chrome
winget install -e --id Brave.Brave
winget install -e --id Microsoft.PowerShell
winget install -e --id Spotify.Spotify
winget install -e --id SlackTechnologies.Slack

# Docker Configuration
wsl --install
wsl --shutdown
wsl --export docker-desktop-data "C:\temp\docker-desktop-data.tar"
wsl --unregister docker-desktop-data
wsl --import docker-desktop-data "C:\WINGET\Development\Docker\WSL_Data" docker-desktop-data.tar --version 2
Remove-Item -LiteralPath "C:\temp\docker-desktop-data.tar"

# Git Configuration
git config --global submodule.recurse true
git config --global user.email "josh@devxt.com"
git config --global user.name "Josh XT"
Set-Content -Path ~/.gitmessage -Value "Updates"
git config --global commit.template ~/.gitmessage

# VS Configuration
dotnet tool install --global dotnet-ef

# Windows Updates
Install-Module PSWindowsUpdate -Force
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force
Import-Module PSWindowsUpdate -Force
Get-WindowsUpdate -Install -AcceptAll -IgnoreReboot

Write-Host "Setup complete. Run the GetRepos.ipynb notebook to clone all repos."

return 0