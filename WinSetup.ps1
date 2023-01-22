$packages = [ordered]@{}
if(!(Test-Path -Path "C:\ProgramData\Automation")) { ((New-Item -Path "C:\ProgramData\Automation" -ItemType Directory) | Out-Null) }
if(!($env:ChocolateyInstall)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}
if (Test-Path -Path "C:\ProgramData\Automation\packages.csv") {
    Import-Csv -Path "C:\ProgramData\Automation\packages.csv" -Delimiter "," | ForEach-Object { $packages.Add($_.Package, $_.Arguments) }
} else {
    # Update this if $packages if needed, key is package name from Chocolatey, value is the arguments if any.
    $packages = [ordered]@{
        "git" = ""
        "nodejs-lts" = ""
        "powershell-core" = ""
        "firefox" = ""
        "vscode" = ""
        "yarn" = ""
        "winscp" = ""
        "powertoys" = ""
        "microsoft-teams.install" = ""
        "microsoftazurestorageexplorer" = ""
        "powerbi" = ""
        "sql-server-management-studio" = ""
        "visualstudio2022enterprise" = "--allWorkloads --includeRecommended --includeOptional --passive --locale en-US"
    }
    $csv = """Package"",""Arguments""`n"
    foreach($package in $packages.Keys) {
        $csv += """$($package)"",""$($packages[$package])""`n"
    }
    Add-Content -Path "C:\ProgramData\Automation\packages.csv" -Value $csv
}
if(!(Test-Path -Path "C:\ProgramData\Automation\Updater.ps1")) { (Copy-Item -Path $MyInvocation.MyCommand.Path -Destination "C:\ProgramData\Automation\Updater.ps1") }
if(!(Get-ScheduledTaskInfo -TaskName "Chocolatey App Updates")) {    
    $action = New-ScheduledTaskAction -Execute "C:\Program Files\PowerShell\7\pwsh.exe" -Argument '"C:\ProgramData\Automation\Updater.ps1"'
    Register-ScheduledTask -Action $action -Trigger (New-ScheduledTaskTrigger -Daily -At 2am) -TaskName "Chocolatey App Updates" -Description "Free third party patching!" -User "NT AUTHORITY\SYSTEM" -RunLevel Highest
}
$installed = (choco list -l --idonly)
foreach($p in $packages.Keys) {
    $installCheck = ($installed | where-object { $_.Key -eq $p })
    if ($null -eq $installCheck) {
        Write-Host "Installing $($p)..."
        if($packages[$p] -eq "") {
            (choco install $p --force -y)
        } else {
            (choco install $p --force -y --package-parameters $packages[$p])
        }
        Write-Host "$($p) installation complete."
        Add-Content -Path "C:\ProgramData\Automation\install.log" "$($p) installed $((Get-Date))"
    }
}
choco upgrade all -y
return 0
