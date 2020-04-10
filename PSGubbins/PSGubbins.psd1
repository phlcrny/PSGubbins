@{
    RootModule        = "PSGubbins.psm1"
    GUID              = "b79c257b-b975-4c42-b354-7c260e34dc26"
    ModuleVersion     = "0.1.0"
    Author            = "Phil Carney"
    Description       = "A Powershell module of assorted gubbins that doesn't fit anywhere else"
    CompanyName       = "N/A"
    PowerShellVersion = "5.1"
    FunctionsToExport = @(
        "Get-Cpl"
        "Get-Msc"
        "New-Password"
        "New-RdpSession"
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @(
        "Get-ControlPanelApplet"
        "Get-MMCSnapIn"
        "New-Passphrase"
        "rdp"
    )
    PrivateData       = @{
        PSData = @{
            # Tags = @()
            LicenseUri = "https://github.com/phlcrny/PSGubbins/blob/master/licence.md"
            ProjectUri = "https://github.com/phlcrny/PSGubbins"
            # IconUri = ""
            # ReleaseNotes = ""
            # Prerelease string of this module
            # Prerelease = ""
            # RequireLicenseAcceptance = $false
            # ExternalModuleDependencies = @()
        }

    }
}