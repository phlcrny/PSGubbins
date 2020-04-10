function New-RdpSession
{
    <#
    .SYNOPSIS
        Launches a Remote Desktop connection to specified computer(s).
    .DESCRIPTION
        Uses mstsc.exe to launch a Remote Desktop connection to specified computer(s) subject a successful ping.
    .PARAMETER ComputerName
        The computer(s) to be connected to.
    .PARAMETER PassThru
        Whether or not an object is output to represent each session.
    .PARAMETER SkipPing
        Dictates that a successful ping should not be required to attempt connection.
    .EXAMPLE
        rdp -ComputerName "dc01", "file01"
    .EXAMPLE
        rdp dc01
    .EXAMPLE
        rdp file01 -SkipTest
    .EXAMPLE
        rdp 10.0.10.50
    .INPUTS
        Strings
    .OUTPUTS
        PSCustomObject (optional)
    #>
    [CmdletBinding(ConfirmImpact = "Low", SupportsShouldProcess = $True)]
    [OutputType("PSCustomObject")]
    [Alias("rdp")]
    param
    (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, HelpMessage = "The computer(s) to RDP to")]
        [string[]] $ComputerName,

        [Parameter(Mandatory = $False, Position = 1, HelpMessage = "Whether or not an object is output to represent each session.")]
        [switch] $PassThru,

        [Parameter(Mandatory = $False, Position = 2, HelpMessage = "Dictates that a successful ping should not be required to attempt connection.")]
        [switch] $SkipPing
    )

    BEGIN
    {
        if ($PSBoundParameters.ContainsKey("Debug"))
        {
            $DebugPreference = "Continue"
        }
        Write-Debug -Message "BEGIN Block"
    }

    PROCESS
    {
        Write-Debug -Message "PROCESS Block"
        forEach ($Computer in $ComputerName)
        {
            Write-Verbose -Message "Pinging '$Computer'"
            $PingTest = $Null
            $PingTest = Test-Connection -ComputerName $Computer -Count 2 -ErrorAction "SilentlyContinue"

            if ($PingTest)
            {
                if ($PSCmdlet.ShouldProcess($Computer, "Create new RDP session"))
                {
                    $RdpSplat = @{
                        FilePath     = "mstsc.exe"
                        ArgumentList = "/v:$Computer"
                        PassThru     = $True
                        ErrorAction  = "Stop"
                    }

                    try
                    {
                        $Process = Start-Process @RdpSplat
                        if ($PassThru)
                        {
                            [PSCustomObject]@{
                                ComputerName = $Computer
                                IPv4Address  = $PingTest.IPv4Address | Sort-Object -Unique
                                PID          = $Process.Id
                            }
                        }
                    }
                    catch
                    {
                        Write-Warning -Message "Problems starting RDP session with '$Computer'"
                    }
                }
            }
            else
            {
                Write-Verbose -Message "Ping to '$Computer' failed. Skipping RDP connection."
            }
        }
    }

    END
    {
        Write-Debug -Message "END Block"
    }
}