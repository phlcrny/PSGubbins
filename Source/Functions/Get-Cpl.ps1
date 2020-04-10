function Get-Cpl
{
    <#
    .SYNOPSIS
        Finds any .cpl files in a given location.
    .DESCRIPTION
        Performs a recursive search to find all unique .cpl files in a given location, and return the name and the associated file description.
    .PARAMETER Path
        The path which will be searched. By default this is 'C:\Windows\System32'
    .EXAMPLE
        Get-Cpl -Path "C:\"

        Name                  Description
        ----                  -----------
        appwiz.cpl            Shell Application Manager
        bthprops.cpl          Bluetooth Control Panel Applet
        CmiCnfgp.cpl          ConfigPanel DLL
        desk.cpl              Desktop Settings Control Panel
        Firewall.cpl          Windows Defender Firewall Control Panel DLL Launching Stub
        FlashPlayerCPLApp.cpl
        hdwwiz.cpl            Add Hardware Control Panel Applet
        igfxcpl.cpl           igfxcpl Module
        inetcpl.cpl
        intl.cpl              Control Panel DLL
        irprops.cpl           Infrared Control Panel Applet
        joy.cpl               Game Controllers Control Panel Applet
        main.cpl              Mouse and Keyboard Control Panel Applets
        MLCFG32.CPL           Microsoft Mail Configuration Library
        mmsys.cpl             Audio Control Panel
        ncpa.cpl              Network Connections Control-Panel Stub
        powercfg.cpl          Power Management Configuration Control Panel Applet
        sapi.cpl              Speech UX Control Panel
        sysdm.cpl
        TabletPC.cpl          Tablet PC Control Panel
        telephon.cpl          Telephony Control Panel
        timedate.cpl          Time Date Control Panel Applet
        wscui.cpl             Security and Maintenance
    .INPUTS
        String
    .OUTPUTS
        PSCUstomObject
    #>
    [CmdletBinding()]
    [Alias("Get-ControlPanelApplet")]
    [OutputType([PSCustomObject])]
    param
    (
        [Parameter(Mandatory = $False, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, HelpMessage = "The file path to search for CPL files.")]
        [ValidateScript( {
                if (Test-Path $_)
                {
                    $True
                }
                else
                {
                    throw "The specified location could not be found."
                }
            } )]
        [alias("FullName", "FilePath")]
        [string] $Path = "C:\Windows\System32"
    )

    try
    {
        if (Test-Path -Path $Path)
        {
            $SearchSplat = @{
                Path        = $Path
                Include     = "*.cpl"
                Recurse     = $True
                Force       = $True
                ErrorAction = "SilentlyContinue"
            }

            $Files = Get-ChildItem @SearchSplat | Sort-Object -Property "Name" -Unique

            forEach ($File in $Files)
            {
                [PSCustomObject]@{
                    Name        = $File.Name
                    Description = $File.VersionInfo.FileDescription
                    Path        = $File.FullName
                }
            }
        }
        else
        {
            Write-Warning -Message "The provided path is inaccessible ($Path)"
        }
    }
    catch
    {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}