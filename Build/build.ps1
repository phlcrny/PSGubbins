[CmdletBinding(DefaultParameterSetName = "Task")]
param(
    [Parameter(HelpMessage = "Runs the specified psake task", ParameterSetName = "Task")]
    [string[]] $Task = "default",

    [Parameter(HelpMessage = "Installs build requirements")]
    [switch] $Bootstrap,

    [Parameter(HelpMessage = "Displays details of psake tasks", ParameterSetName = "Help")]
    [alias("-help", "h")]
    [switch] $Help
)

$ErrorActionPreference = "Stop"

# I'm fairly sure pwsh doesn't need to be told to use modern TLS
# But Powershell will need it for the next breaking change to the PSGallery
if ($PSVersionTable.PSEdition -ne "Core")
{
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
}

if ($Bootstrap)
{
    [void] (Get-PackageProvider -Name NuGet -Force)
    if (-not (Get-PSRepository -Name "PSGallery"))
    {
        Register-PSRepository -Default
    }

    Set-PSRepository -Name "PSGallery" -InstallationPolicy "Trusted"

    if (-not (Get-Module -Name "PSDepend" -ListAvailable))
    {
        Install-Module -Name "PSDepend" -Repository "PSGallery" -Scope "CurrentUser" -Force
    }

    Import-Module -Name "PSDepend" -Verbose:$False

    $DependenciesSplat = @{
        Path    = Join-Path -Path $PSScriptRoot -ChildPath "requirements.psd1"
        Install = $True
        Import  = $True
        Force   = $True
    }
    Invoke-PSDepend @DependenciesSplat
}


if ($Help)
{
    Get-PSakeScriptTasks -buildFile (Join-Path -Path $PSScriptRoot -ChildPath "psakefile.ps1") |
        Format-Table "Name", "Description", "Alias", "DependsOn" -AutoSize
}
else
{
    Set-BuildEnvironment -BuildOutput "PSGubbins" -Force
    $psakeSplat = @{
        taskList  = $Task
        buildFile = Join-Path -Path $PSScriptRoot -ChildPath "psakefile.ps1"
        noLogo    = $True
        Verbose   = $VerbosePreference
    }

    Invoke-psake @psakeSplat
}