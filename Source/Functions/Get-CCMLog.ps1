function Get-CCMLog
{
    <#
    .SYNOPSIS
        Retrieves entries from Configuration Manager's logs.
    .DESCRIPTION
        Retrieves entries from Configuration Manager's log files from a local or remote computer and filters using pre-set patterns.
    .PARAMETER LogName
        The name of the log name to be retrieved
    .PARAMETER ComputerName
        The computer(s) whose logs will queried.
    .PARAMETER Count
        The number of lines that will be retrieved from each specified log.
    .PARAMETER AllMessages
        Returns all log entries rather than using the default pattern-matching for filtering.
    .EXAMPLE
        Get-CCMLog -ComputerName "lt-12345" -Count 25

        Retrieves the AppEnforce log of lt-12345
    .EXAMPLE
        Get-CCMLog -LogName "AppDiscovery"

        Retrieves the AppDiscovery log of the local machine
    .EXAMPLE
        Get-CCMLog -LogName "AppIntentEval", "AppDiscovery", "AppEnforce" | Out-GridView

        Retrieves the 'AppIntentEval', 'AppDiscovery' and 'AppEnforce' log entries and outputs to Out-GridView for interactive search and manipulation.
    .EXAMPLE
        Get-CCMLog -LogName PolicyAgent, AppDiscovery, AppIntentEval, CAS, ContentTransferManager, DataTransferService, AppEnforce | Out-GridView

        Retrieves logs allowing for the tracing of a deployment from machine policy to app enforcement and outputs to Out-GridView again.
    .INPUTS
        String, Integer, Switch
    .OUTPUTS
        PSCustomObject
    #>
    [CmdletBinding(ConfirmImpact = "Low", SupportsShouldProcess = $True)]
    [OutputType("PSCustomObject")]
    param
    (
        [Parameter(Position = 0, HelpMessage = "The log(s) to be retrieved")]
        [ValidateSet("AlternateHandler", "AppDiscovery", "AppEnforce", "AppIntentEval", "AssetAdvisor", "CAS", "Ccm32BitLauncher", "CcmCloud",
            "CcmEval", "CcmEvalTask", "CcmExec", "CcmMessaging", "CcmNotificationAgent", "CcmRepair", "CcmRestart", "CCMSDKProvider",
            "CcmSqlCE", "CCMVDIProvider", "CertEnrollAgent", "CertificateMaintenance", "CIAgent", "CIDownloader", "CIStateStore",
            "CIStore", "CITaskMgr", "ClientIDManagerStartup", "ClientLocation", "ClientServicing", "CMBITSManager", "CmRcService",
            "CoManagementHandler", "ComplRelayAgent", "ContentTransferManager", "DataTransferService", "DCMAgent", "DCMReporting",
            "DcmWmiProvider", "DdrProvider", "DeltaDownload", "EndpointProtectionAgent", "execmgr", "ExpressionSolver",
            "ExternalEventAgent", "FileBITS", "FSPStateMessage", "InternetProxy", "InventoryAgent", "InventoryProvider",
            "LocationServices", "MaintenanceCoordinator", "ManagedProvider", "mtrmgr", "oobmgmt", "PeerDPAgent", "PolicyAgent",
            "PolicyAgentProvider", "PolicyEvaluator", "pwrmgmt", "PwrProvider", "RebootCoordinator", "ScanAgent", "Scheduler",
            "ServiceWindowManager", "SettingsAgent", "setuppolicyevaluator", "smscliui", "SoftwareCatalogUpdateEndpoint",
            "SoftwareCenterSystemTasks", "SrcUpdateMgr", "StateMessage", "StateMessageProvider", "StatusAgent", "SWMTRReportGen",
            "UpdatesDeployment", "UpdatesHandler", "UpdatesStore", "UpdateTrustedSites", "UserAffinity", "UserAffinityProvider",
            "VirtualApp", "wedmtrace", "WindowsAnalytics", "WUAHandler")]
        [string[]] $LogName = "AppEnforce",

        [Parameter(Position = 1, HelpMessage = "The path to the directory containing the logs")]
        [ValidateScript({ if (Test-Path -Path $_ -PathType "Container")
            {
                $True
            }
            else
            {
                throw "Unable to access/validate specified directory"
            }
        })]
        [string] $Path = "C:\Windows\CCM\Logs",

        [Parameter(Position = 2, HelpMessage = "The number of entries/lines to be returned.")]
        [ValidateNotNullOrEmpty()]
        [int] $Count = 20,

        [Parameter(Position = 3, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, HelpMessage = "The computer whose logs will be parsed.")]
        [alias("PSComputerName", "__SERVER", "CN", "IPAddress")]
        [string[]] $ComputerName = "localhost",

        [Parameter(HelpMessage = "Specifies that all messages should be returned")]
        [alias("All")]
        [switch] $AllMessages
    )

    BEGIN
    {
        if ($PSBoundParameters.ContainsKey("Debug"))
        {
            $DebugPreference = "Continue"
        }

        $PatternContents = if ($AllMessages)
        {
            "(.+)"
        }
        else
        {
            "(a?)sync(hronous?)"
            "(Prepared|Executing) command line"
            "App enforcement completed"
            "Application not discovered"
            "authority"
            "cache"
            "complete(d?)"
            "criteria"
            "detect(ed?)"
            "exclude"
            "exit code"
            "fail(ure|s|ed)"
            "include"
            "Install enforcement"
            "missing"
            "Performing detection of app deployment type"
            "policy"
            "Post install behavior"
            "Prepared working directory"
            "registration"
            "releas(e|ed|ing)"
            "request(ed|ing)?"
            "revok(e|ed|ing)"
            "S-1-5"
            "search"
            "set"
            "size"
            "source"
            "state"
            "status"
            "succe(eded|ss)"
            "tombstone"
            "update(d?)"
            "user logged"
            "Waiting for process"
        }
        # Convert the array to a regex pattern
        $Pattern = $PatternContents -join "|"
    }

    PROCESS
    {
        forEach ($Computer in $ComputerName)
        {
            Write-Verbose -Message "Testing for connectivity to '$Computer'"
            if (($Computer -like "localhost") -or
                ($Computer -like "127.0.0.1") -or
                ($Computer -like [Environment]::MachineName) -or
                (Test-Connection -ComputerName $Computer -Quiet -Count 2))
            {
                forEach ($Log in $LogName)
                {
                    if ($PSCmdlet.ShouldProcess($Computer, "Retrieve $Log log entries"))
                    {
                        if (($Computer -like "localhost") -or ($Computer -like "127.0.0.1"))
                        {
                            Write-Verbose -Message "Converting '$Computer' to '$([Environment]::MachineName)'"
                            $Computer = [Environment]::MachineName
                        }
                        Write-Verbose -Message "Processing '$Computer'"

                        try
                        {
                            $LogRoot = $Null
                            $LogRoot = Resolve-Path "\\$Computer\C$\Windows\CCM\Logs\" -ErrorAction "Stop"
                            $LogPaths = $Null
                            Write-Verbose -Message "Locating $Log log(s)."
                            $LogSearchSplat = @{
                                Path = $LogRoot
                                Filter = "$Log*.log"
                                File = $True
                            }
                            $LogPaths = Get-ChildItem @LogSearchSplat  | Select-Object -ExpandProperty "FullName"
                        }
                        catch
                        {
                            $PSCmdlet.ThrowTerminatingError($_)
                        }

                        forEach ($LogPath in $LogPaths)
                        {
                            if (Test-Path -Path $LogPath -ErrorAction "Stop")
                            {
                                try
                                {
                                    Write-Verbose -Message "Defining parameters for log read."
                                    $Parameters = @{
                                        Path        = $LogPath
                                        Tail        = 1000
                                        ErrorAction = "Stop"
                                    }

                                    Write-Verbose -Message "Reading log ($LogPath)."
                                    $LogContents = Get-Content @Parameters |
                                        Where-Object { $_ -match $Pattern } |
                                        Select-Object -Last $Count
                                }
                                catch [System.UnauthorizedAccessException]
                                {
                                    Write-Warning -Message "Unable due to retrieve details to an 'Unauthorized Access' exception. Ensure you have the required permissions."
                                    $PSCmdlet.ThrowTerminatingError($_)
                                }
                                catch
                                {
                                    $PSCmdlet.ThrowTerminatingError($_)
                                }

                                forEach ($LogEntry in $LogContents)
                                {
                                    Write-Debug -Message "Processing log entry: '$LogEntry'"
                                    try
                                    {
                                        Write-Debug -Message "Processing message property."
                                        [string] $Message = ($LogEntry | Select-String -Pattern "\[LOG\[((.| )+)\]LOG\]").Matches.Value
                                        # Identifies the message sections of each line using the [LOG[] tags and removes them for us.
                                        if ($Log -like "AppIntentEval")
                                        {
                                            Write-Verbose -Message "Parsing AppIntentEval message."
                                            $Message = $Message -replace ":- |, ", "`n"
                                            # Lazy reformatting to key:value statements instead of in a line.
                                        }
                                        $Message = ($Message -replace "\[LOG\[|\]LOG\]").Trim()
                                    }
                                    catch
                                    {
                                        $PSCmdlet.ThrowTerminatingError($_)
                                    }

                                    if (-not ($Message))
                                    {
                                        Write-Verbose -Message "Unable to read message - skipping to next."
                                        Continue
                                    }

                                    try
                                    {
                                        Write-Debug -Message "Processing metadata block."
                                        [string] $Metadata = ((($LogEntry | Select-String -Pattern "<time((.| )+)>").Matches.Value -replace "<|>") -split " ")
                                        # Identifies and isolates the metadata section
                                        # Includes the time and date which we want, but also other entries which we'll need to get rid of.
                                    }
                                    catch
                                    {
                                        $PSCmdlet.ThrowTerminatingError($_)
                                    }


                                    try
                                    {
                                        Write-Debug -Message "Processing TimeStub block."
                                        [string] $TimeStub = ((($Metadata -split " ")[0] -replace 'time|=|"') -split "\.")[0]
                                        # To find the time, we remove 'time', '=', and '"'
                                        # Split the remainder in two based on '.' and keep the first part.
                                        # This is a bit awkward but the casting is tricky without the split.
                                    }
                                    catch
                                    {
                                        $PSCmdlet.ThrowTerminatingError($_)
                                    }

                                    try
                                    {
                                        Write-Debug -Message "Processing DateStub block."
                                        [string] $DateStub = ((($Metadata -split " ")[1] -replace 'date|=|"'))
                                        # Finding the date is similar but simpler.
                                        # We only need to remove 'date', '=', and '"'.
                                    }
                                    catch
                                    {
                                        $PSCmdlet.ThrowTerminatingError($_)
                                    }


                                    try
                                    {
                                        Write-Debug -Message "Generating timestamp."
                                        [datetime] $TimeStamp = "$DateStub $TimeStub"
                                        # At the end we add the two stubs together, and cast them as a [datetime] object
                                    }
                                    catch
                                    {
                                        $PSCmdlet.ThrowTerminatingError($_)
                                    }

                                    [PSCustomObject]@{
                                        ComputerName = $Computer
                                        Source       = $Log
                                        Timestamp    = $TimeStamp
                                        Message      = $Message
                                        Path         = $LogPath
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    END
    {
    }
}