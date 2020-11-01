# This PSM1 compiled with psake 2020/11/01 20:28:21

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
        [string[]] $FirstDictionary = @('Adorable', 'Adventurous', 'Aggressive', 'Agreeable', 'Alert', 'Alive', 'Amused', 'Angry', 'Annoyed', 'Annoying', 'Anxious',
            'Arrogant', 'Ashamed', 'Attractive', 'Average', 'Awesome', 'Awful', 'Bad', 'Basic', 'Beautiful', 'Better', 'Bewildered', 'Bitter', 'Black', 'Bloody',
            'Blue', 'Blue-eyed', 'Blushing', 'Bored', 'Brainy', 'Brave', 'Breakable', 'Bright', 'Busy', 'Calm', 'Careful', 'Cautious', 'Charming', 'Cheerful',
            'Clean', 'Clear', 'Clever', 'Cloudy', 'Clumsy', 'Colorful', 'Combative', 'Comfortable', 'Concerned', 'Condemned', 'Confused', 'Cooperative', 'Correct',
            'Courageous', 'Crazy', 'Creepy', 'Crowded', 'Cruel', 'Curious', 'Cute', 'Dangerous', 'Dark', 'Dead', 'Defeated', 'Defiant', 'Delightful', 'Depressed',
            'Determined', 'Different', 'Difficult', 'Disgusted', 'Distinct', 'Disturbed', 'Divine', 'Dizzy', 'Doubtful', 'Drab', 'Dull', 'Eager', 'Easy', 'Elated',
            'Elegant', 'Embarrassed', 'Enchanting', 'Encouraging', 'Energetic', 'Enraged', 'Enthusiastic', 'Envious', 'Evil', 'Excited', 'Expensive', 'Exuberant',
            'Fair', 'Faithful', 'Famous', 'Fancy', 'Fantastic', 'Fast', 'Fat', 'Fierce', 'Filthy', 'Fine', 'Foolish', 'Fragile', 'Frail', 'Frantic', 'Friendly',
            'Frightened', 'Funny', 'Gentle', 'Gifted', 'Glamorous', 'Gleaming', 'Glorious', 'Good', 'Gorgeous', 'Graceful', 'Great', 'Grieving', 'Grotesque',
            'Grumpy', 'Guilty', 'Handsome', 'Handy', 'Happy', 'Healthy', 'Helpful', 'Helpless', 'Hilarious', 'Homeless', 'Homely', 'Horrible', 'Huge', 'Hungry',
            'Hurt', 'Ill', 'Important', 'Impossible', 'Inexpensive', 'Innocent', 'Inquisitive', 'Intelligent', 'Irritated', 'Itchy', 'Jealous', 'Jittery', 'Jolly',
            'Joyous', 'Just', 'Kind', 'Lazy', 'Light', 'Lively', 'Lonely', 'Long', 'Lovely', 'Lucky', 'Magnificent', 'Massive', 'Misty', 'Modern', 'Moral', 'Morose',
            'Motionless', 'Muddy', 'Mushy', 'Mysterious', 'Nasty', 'Naughty', 'Nervous', 'Nice', 'Nutty', 'Obedient', 'Obnoxious', 'Odd', 'Open', 'Outrageous',
            'Outstanding', 'Panicky', 'Perfect', 'Plain', 'Pleasant', 'Poised', 'Poor', 'Powerful', 'Precious', 'Prickly', 'Proud', 'Psyched', 'Putrid', 'Puzzled',
            'Quaint', 'Rapid', 'Real', 'Relieved', 'Repulsive', 'Resourceful', 'Rich', 'Righteous', 'Sad', 'Scary', 'Selfish', 'Shiny', 'Shy', 'Silly', 'Sinful',
            'Sleepy', 'Smart', 'Smiling', 'Smoggy', 'Sore', 'Sparkling', 'Splendid', 'Spotless', 'Stormy', 'Strange', 'Strong', 'Stupid', 'Successful', 'Super',
            'Talented', 'Tame', 'Tasty', 'Tender', 'Tense', 'Terrible', 'Thankful', 'Thoughtful', 'Thoughtless', 'Tiny', 'Tired', 'Tough', 'Troubled', 'Ugliest',
            'Ugly', 'Uninterested', 'Unsightly', 'Unusual', 'Upright', 'Upset', 'Uptight', 'Vast', 'Vengeful', 'Vexed', 'Victorious', 'Violent', 'Vivacious',
            'Wandering', 'Weary', 'Wicked', 'Wild', 'Witty','Worried', 'Worrisome', 'Wrathful', 'Wrong', 'Zany', 'Zealous'),

        [Parameter(Mandatory = $False, HelpMessage = "The second group of words to be used when generating the password - animal names by default")]
        [string[]] $SecondDictionary = @('Alligators', 'Apes', 'Baboons', 'Badgers', 'Beavers', 'Cats', 'Cheetahs', 'Chipmunks', 'Coyotes', 'Crocodiles', 'Crocs',
            'Dinosaurs', 'Dogs', 'Dolphins', 'Ducks', 'Ferrets', 'Fish', 'Fleas', 'Foxes', 'Gators', 'Geese', 'Giraffes', 'Goats', 'Hares', 'Honey Badgers', 'Horses',
            'Leopards', 'Lions', 'Meerkats', 'Mice', 'Monkeys', 'Moose', 'Pandas', 'Penguins', 'Rabbits', 'Raccoons', 'Rats', 'Reindeer', 'Sharks', 'Sheep',
            'Squirrels', 'Swans', 'Tigers', 'Tortoises', 'Turtles', 'Weasels', 'Wolves', 'Zebras'),

        [Parameter(Mandatory = $False, HelpMessage = "The third group of words to be used when generating the password - modifiers by default")]
        [string[]] $ExtraDictionary = @("Abhorrently", "Abnormally", "Absurdly", "Acceptably", "Accordingly", "Adorably", "Amazingly", "Artfully", "Creatively",
            "Extremely", "Incredibly", "Infinitely", "Mad", "Moderately", "Particularly", "Pleasingly", "Proper", "Really", "Reasonably", "Somewhat", "Strikingly",
            "Sufficiently", "Super", "Supremely", "Totally", "Tremendously", "Truly", "Very", "Well", "Wicked")
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
