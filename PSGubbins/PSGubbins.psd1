@{
    RootModule        = "PSGubbins.psm1"
    GUID              = "b79c257b-b975-4c42-b354-7c260e34dc26"
    ModuleVersion     = "0.2.0"
    Author            = "Phil Carney"
    Description       = "A Powershell module of assorted gubbins and utilities that don't fit anywhere else."
    FunctionsToExport = @(
        "Get-Cpl"
        "Get-CCMLog"
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
            Tags = @("utilities", "rdp", "sccm", "ccm", "gubbins")
            LicenseUri = "https://github.com/phlcrny/PSGubbins/blob/master/licence.md"
            ProjectUri = "https://github.com/phlcrny/PSGubbins"
            ReleaseNotes = "https://github.com/phlcrny/PSGubbins/blob/master/changelog.md"
        }
    }
}