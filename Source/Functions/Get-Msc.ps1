function Get-Msc
{
    <#
    .SYNOPSIS
        Finds any .msc files (MMC snap-ins) in a specified location.
    .DESCRIPTION
        Performs a recursive search to find all unique .msc files in a given location, and return the name and the associated file description.
    .PARAMETER Path
        The path to be searched for snap-in files.
    .EXAMPLE
        Get-Msc -Path "C:\"
    .INPUTS
        String
    .OUTPUTS
        PSCUstomObject
    #>
    [CmdletBinding()]
    [Alias("Get-MMCSnapIn")]
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
                Include     = "*.msc"
                Recurse     = $True
                ErrorAction = "SilentlyContinue"
            }

            $Files = Get-ChildItem @SearchSplat | Sort-Object -Property "Name" -Unique

            forEach ($File in $Files)
            {
                [PSCustomObject]@{
                    Name = $File.Name
                    Path = $File.FullName
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