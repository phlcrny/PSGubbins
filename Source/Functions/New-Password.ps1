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