# This PSM1 compiled with psake 2020/06/04 22:22:24

# PSGubbins\Source\Functions\Get-CCMLog.ps1
function Get-CCMLog
{
    <#
    .SYNOPSIS
        Retrieves entries from Configuration Manager's logs.
    .DESCRIPTION
        Retrieves entries from Configuration Manager's log files (defaulting to the last 2000 lines per file) from a local or remote computer and filters using pre-set patterns.
    .PARAMETER LogName
        The name of the log to be retrieved.
    .PARAMETER Path
        The directory the logs are stored in. UNC path's are assumed for use against remote machine but conversion from local drives is attempted.
    .PARAMETER ComputerName
        The computer(s) whose logs will queried.
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
        [alias("Name")]
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
        [string] $Path = "C:\Windows\CCM\Logs",

        [Parameter(Position = 3, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, HelpMessage = "The computer whose logs will be parsed")]
        [alias("PSComputerName", "__SERVER", "CN", "IPAddress")]
        [string[]] $ComputerName = "localhost",

        [Parameter(HelpMessage = "Returns all log entries rather than using the default pattern-matching for filtering")]
        [alias("NoPattern")]
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
            if (($Computer -like "localhost") -or ($Computer -like "127.0.0.1"))
            {
                Write-Verbose -Message "Converting localhost to hostname"
                $Computer = [Environment]::MachineName
            }
            Write-Verbose -Message "Processing '$Computer'"

            try
            {
                $LogRoot = $Null
                if ($Null -ne $Path)
                {
                    $JoinSplat = @{
                        Path        = "\\$Computer\"
                        ChildPath   = ($Path -replace ":", "$")
                        ErrorAction = "Stop"
                    }

                    $UNCPath = Join-Path @JoinSplat
                    if (Test-Path -Path $UNCPath -ErrorAction "Stop")
                    {
                        $LogRoot = Resolve-Path -Path $UNCPath -ErrorAction "Stop"
                    }
                }
                else
                {
                    $LogRoot = Resolve-Path "\\$Computer\C$\Windows\CCM\Logs\" -ErrorAction "Stop"
                }

                if ($LogRoot -match "^Microsoft.Powershell")
                {
                    $LogRoot = $LogRoot -Split "::" | Select-Object -Last 1
                }
            }
            catch
            {
                Write-Warning -Message "Problems were encountered resolving '$LogRoot'"
                $PSCmdlet.ThrowTerminatingError($_)
            }

            if (-not (Test-Path -Path $LogRoot))
            {
                Write-Warning -Message "Unable to resolve/access '$LogRoot'"
                Continue
            }

            Write-Verbose -Message "Testing for connectivity to '$Computer'"
            if (($Computer -eq [Environment]::MachineName) -or
                (Test-Connection -ComputerName $Computer -Quiet -Count 2))
            {
                forEach ($Log in $LogName)
                {
                    if ($PSCmdlet.ShouldProcess($LogRoot, "Retrieve '$Log' log entries"))
                    {
                        try
                        {
                            Write-Verbose -Message "Locating '$Log' log(s)."
                            $LogSearchSplat = $Null
                            $LogSearchSplat = @{
                                Path   = $LogRoot
                                Filter = "$Log*.log"
                                File   = $True
                            }

                            $LogPaths = $Null
                            $LogPaths = @(Get-ChildItem @LogSearchSplat  | Select-Object -ExpandProperty "FullName")
                            Write-Verbose -Message "'$($LogPaths.Count)' '$Log' logs found."
                        }
                        catch
                        {
                            Write-Warning -Message "Problems were encountered '$Log' logs from '$LogRoot'"
                            $PSCmdlet.ThrowTerminatingError($_)
                        }

                        forEach ($LogPath in $LogPaths)
                        {
                            if (Test-Path -Path $LogPath -ErrorAction "Stop")
                            {
                                try
                                {
                                    $Parameters = @{
                                        Path        = $LogPath
                                        Tail        = 2000     # I'm reluctant to read the entirety of the files by default and this seems likely to read most logs.
                                        ErrorAction = "Stop"
                                    }

                                    Write-Verbose -Message "Reading log ($LogPath)."
                                    $LogContents = Get-Content @Parameters |
                                        Where-Object { $_ -match $Pattern }
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
                                            Write-Debug -Message "Parsing AppIntentEval message."
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
                                        Write-Verbose -Message "Unable to read blank message - skipping to next."
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

# PSGubbins\Source\Functions\Get-Cpl.ps1
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

# PSGubbins\Source\Functions\Get-Msc.ps1
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

# PSGubbins\Source\Functions\New-Password.ps1
function New-Password
{
    <#
    .SYNOPSIS
        Creates one or more password/passphrase from custom or pre-defined lists of words.
    .DESCRIPTION
        Creates one or more password/passphrase from custom or pre-defined lists of words, with the option of specifying minimum or maximum lengths.
    .PARAMETER Count
        The number of passwords to generate.
    .PARAMETER Long
        Determines whether longer passwords will be generated by using a third list of words.
    .PARAMETER MinimumLength
        Determines the minimum accepted length of the generated password(s).
    .PARAMETER MaximumLength
        Determines the maximum accepted length of the generated password(s).
    .PARAMETER FirstDictionary
        The first group of words to be used when generating the password.
    .PARAMETER SecondDictionary
        The second group of words to be used when generating the password.
    .PARAMETER ExtraDictionary
        The third group of words to be used when generating the password.
    .EXAMPLE
        New-Password

        Generates a new password.
    .EXAMPLE
        New-Password -Count 10 -Long

        Generates 10 long passwords.
    .EXAMPLE
        New-Password -Count 10 -MinimumLength 16

        Generates 10 passwords at least 16 characters long.
    .INPUTS
        String, Integer
    .OUTPUTS
        String
    #>
    [CmdletBinding(ConfirmImpact = "Low", SupportsShouldProcess = $False)]
    [Alias("New-Passphrase")]
    [OutputType([String])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions",
        "",
        Justification = "This does generate something new but it does not change state.")]
    param
    (
        [Parameter(Mandatory = $False, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, HelpMessage = "The number of passwords to generate")]
        [Alias('Number')]
        [int] $Count = 1,

        [Parameter(Mandatory = $False, HelpMessage = "Determines the complexity of the password")]
        [Alias('Extended', 'Complex')]
        [switch] $Long = $False,

        [Parameter(Mandatory = $False, HelpMessage = "Determines the minimum accepted length of the password")]
        [int] $MinimumLength = $Null,

        [Parameter(Mandatory = $False, HelpMessage = "Determines the maximum accepted length of the password")]
        [int] $MaximumLength = $Null,

        [Parameter(Mandatory = $False, HelpMessage = "The first group of words to be used when generating the password - adjectives by default")]
        [string[]] $FirstDictionary = @("Angry", "Annoying", "Awesome", "Basic", "Bitter", "Clever", "Correct",
            "Divine", "Enraged", "Fast", "Fat", "Great", "Guilty", "Handy", "Huge", "Intelligent", "Irritated",
            "Just", "Massive", "Moral", "Morose", "Psyched", "Rapid", "Resourceful", "Righteous", "Sad", "Scary",
            "Sinful", "Smart", "Strong", "Tiny", "Upright", "Vengeful", "Vexed", "Violent", "Wrathful"),

        [Parameter(Mandatory = $False, HelpMessage = "The second group of words to be used when generating the password - animal names by default")]
        [string[]] $SecondDictionary = @("Alligators", "Apes", "Baboons", "Badgers", "Beavers", "Cats",
            "Chipmunks", "Coyotes", "Crocodiles", "Dinsoaurs", "Dogs", "Dolphins", "Ducks", "Ferrets", "Fish",
            "Fleas", "Foxes", "Geese", "Giraffes", "Hares", "Honey Badgers", "Horses", "Leopards", "Lions",
            "Meerkats", "Mice", "Monkeys", "Rabbits", "Raccoons", "Rats", "Sharks", "Squirrels", "Swans",
            "Tigers", "Tortoises", "Turtles", "Weasels", "Wolves", "Zebras"),

        [Parameter(Mandatory = $False, HelpMessage = "The third group of words to be used when generating the password - modifiers by default")]
        [string[]] $ExtraDictionary = @("Abhorrently", "Abnormally", "Absurdly", "Acceptably", "Accordingly",
            "Adorably", "Amazingly", "Artfully", "Creatively", "Extremely", "Incredibly", "Infinitely", "Mad",
            "Moderately", "Particularly", "Pleasingly", "Proper", "Really", "Reasonably", "Somewhat",
            "Strikingly", "Sufficiently", "Super", "Supremely", "Totally", "Tremendously", "Truly", "Very",
            "Well", "Wicked")
    )

    BEGIN
    {
        if ($PSBoundParameters.ContainsKey("Debug"))
        {
            $DebugPreference = "Continue"
        }
        Write-Debug -Message "BEGIN Block"

        if ($Long)
        {
            Write-Verbose -Message "The 'Long' parameter has been used. All dictionaries will be used when generating the password(s)."
        }
        if ($MinimumLength)
        {
            Write-Verbose -Message "The minimum allowed length has been set as $MinimumLength."
        }
        if ($MaximumLength)
        {
            Write-Verbose -Message "The maximum allowed length has been set as $MaximumLength."
        }
    }

    PROCESS
    {
        Write-Debug -Message "PROCESS Block"
        for ($i = 0; $i -lt $Count)
        {
            $Random = (Get-Random -Minimum 1 -Maximum 10000)
            # Define the separator to appear between words.
            if ($Random % 2 -eq 0)
            {
                [string] $Separator = "-"
            }
            else
            {
                [string] $Separator = "_"
            }

            if (($Long -eq $True) -or ($Random -ge 4999))
            {
                $RequiredDictionaries = @($ExtraDictionary, $FirstDictionary, $SecondDictionary)
                Write-Verbose -Message "Creating 'long' password."
            }
            else
            {
                $RequiredDictionaries = @($FirstDictionary, $SecondDictionary)
            }

            # Start generating the actual password.
            try
            {
                $PassPhrase = $Null
                Write-Debug -Message "Generating number to start password."
                [string] $PassPhrase = Get-Random -Minimum 2 -Maximum 999 -ErrorAction "Stop"
                [string] $Password = $PassPhrase + $Separator
            }
            catch
            {
                $PSCmdlet.ThrowTerminatingError($_)
            }

            # Start adding words!
            forEach ($Dictionary in $RequiredDictionaries)
            {
                $PassPhrase = $Null
                try
                {
                    Write-Verbose -Message "Retrieving word."
                    $DictionaryLength = ($Dictionary).Length
                    $PassPhrase = $Dictionary[(Get-Random -Minimum 0 -Maximum $DictionaryLength -ErrorAction "Stop")]

                    Write-Debug -Message "Determining case."
                    [string] $PassPhrase = if ((Get-Random -Minimum 0 -Maximum 10) -ge 5)
                    {
                        $PassPhrase.ToUpper()
                    }
                    else
                    {
                        $PassPhrase.ToLower()
                    }

                    Write-Debug -Message "Adding word ($PassPhrase) to password."
                    [string] $Password += $PassPhrase + $Separator
                }
                catch
                {
                    $PSCmdlet.ThrowTerminatingError($_)
                }
            }

            if ($Null -ne $Password)
            {
                Write-Debug -Message "Cleaning up final separator."
                $Password = $Password -replace "$Separator$", ""
                # Removes final 'separator' added to the end of the password.

                if ((-not ($MinimumLength)) -and (-not ($MaximumLength)))
                {
                    # If we're not checking the length, tick over the counter and output the password.
                    Write-Debug -Message "No length validation required."
                    $i ++
                    $Password
                }
                else
                {
                    if (($MinimumLength) -and
                        (-not ($MaximumLength)))
                    {
                        Write-Debug -Message "Validating against minimum length only."
                        if ($Password.Length -ge $MinimumLength)
                        {
                            Write-Verbose -Message "The password is $($Password.Length) characters long."
                            $i ++
                            $Password
                        }
                    }
                    elseif (($MaximumLength) -and
                        (-not ($MinimumLength)))
                    {
                        Write-Debug -Message "Validating against maximum length only."
                        if ($Password.Length -le $MaximumLength)
                        {
                            Write-Verbose -Message "The password is $($Password.Length) characters long."
                            $i ++
                            $Password
                        }
                    }
                    elseif (($MinimumLength) -and
                        ($MaximumLength))
                    {
                        Write-Debug -Message "Validating against minimum and maximum length."
                        if (($Password.Length -ge $MinimumLength) -and
                            ($Password.Length -le $MaximumLength))
                        {
                            Write-Verbose -Message "The password is $($Password.Length) characters long."
                            $i ++
                            $Password
                        }
                    }
                }
            }
            else
            {
                Write-Warning -Message "No password was generated - that shouldn't have happened!"
            }
        }
    }

    END
    {
        Write-Debug -Message "END Block"
    }
}

# PSGubbins\Source\Functions\New-RDPSession.ps1
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
