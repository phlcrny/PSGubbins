# Ensure that the tests won't be polluted with any unexpected versions.
if (Get-Module -Name "PSGubbins")
{
    Write-Verbose -Message "Removing pre-imported module instance."
    Remove-Module -Name "PSGubbins"
}

Write-Verbose -Message "Importing module."
Import-Module -Name $ENV:BHPSModuleManifest
InModuleScope -ModuleName "PSGubbins" {

    Describe "Help tests for 'PSGubbins'" -Tags "Build", "Help" {

        BeforeAll {

            [PSCustomObject] $ModuleManifest = (Import-PowerShellDataFile -Path $ENV:BHPSModuleManifest)
            $Functions = $ModuleManifest.FunctionsToExport
            $HelpFiles = forEach ($Function in $Functions)
            {
                Get-Help -Name $Function -Full
            }
            [void] ($HelpFiles, $ModuleManifest) # For the vscode 'Problems'
        }

        forEach ($FunctionHelp in $HelpFiles)
        {
            Context $FunctionHelp.Name {

                Context  "Help - Structure" {

                    It "Has a Synopsis section." {
                        $FunctionHelp.Synopsis | Should -Not -BeNullOrEmpty
                    }

                    It "Has a Description section." {
                        $FunctionHelp.Description | Should -Not -BeNullOrEmpty
                    }

                    It "Has an Example section." {
                        $FunctionHelp.Examples | Should -Not -BeNullOrEmpty
                    }

                    It "Has an Inputs section section." {
                        $FunctionHelp.inputTypes | Should -Not -BeNullOrEmpty
                    }

                    It "Has an Outputs section section." {
                        $FunctionHelp.returnValues | Should -Not -BeNullOrEmpty
                    }
                }

                Context "Help - Contents" {

                    It "Has a Synopsis not starting with 'TBC'" {
                        $FunctionHelp.Synopsis | Should -Not -Match "TBC -"
                    }

                    It "Has a Description not starting with 'TBC'" {
                        $FunctionHelp.Description | Should -Not -Match "TBC -"
                    }

                    It "Has an Example not starting with 'TBC'" {
                        $FunctionHelp.Examples | Should -Not -Match "TBC -"
                    }

                    It "Has an Inputs section not starting with 'TBC'" {
                        $FunctionHelp.inputTypes | Should -Not -Match "TBC -"
                    }

                    It "Has an Outputs section not starting with 'TBC'" {
                        $FunctionHelp.returnValues | Should -Not -Match "TBC -"
                    }
                }
            }
        }
    }
}
