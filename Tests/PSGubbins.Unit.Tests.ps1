# Ensure that the tests won't be polluted with any unexpected versions.
if (Get-Module -Name "PSGubbins")
{
    Write-Verbose -Message "Removing pre-imported module instance."
    Remove-Module -Name "PSGubbins"
}

Write-Verbose -Message "Importing module."
Import-Module -Name $ENV:BHPSModuleManifest
InModuleScope -ModuleName "PSGubbins" {

    Describe "Unit tests for 'Get-Cpl'" {

        Context "Input" {

            Context "Passing parameter validation" -Tag "ExpectedPass" {

                BeforeAll {

                    [void] (New-Item -Path "TestDrive:\ExistingFolder" -ItemType "Directory")
                    Get-ChildItem -Path "C:\Windows\System32\*.cpl" |
                        Select-Object -First 5 |
                        Copy-Item -Destination "TestDrive:\ExistingFolder"
                }

                It "Should accept a named parameter string to an accessible folder" {

                    { Get-Cpl -Path "TestDrive:\ExistingFolder" } | Should -Not -Throw
                }

                It "Should accept a positional parameter string to an accessible folder" {

                    { Get-Cpl "TestDrive:\ExistingFolder" } | Should -Not -Throw
                }

                It "Should accept a pipeline value string to an accessible folder" {

                    { "TestDrive:\ExistingFolder" | Get-Cpl } | Should -Not -Throw
                }

                It "Should accept a named string property from a pipeline value to an accessible folder" {

                    [PSCustomObject]@{Path = "TestDrive:\ExistingFolder"} | Get-Cpl
                    [PSCustomObject]@{FullName = "TestDrive:\ExistingFolder"} | Get-Cpl
                    [PSCustomObject]@{FilePath = "TestDrive:\ExistingFolder"} | Get-Cpl
                }

                It "Should accept no input parameters" {

                    { Get-Cpl } | Should -Not -Throw
                }

                It "Should accept the alias 'Get-ControlPanelApplet'" {

                    { Get-ControlPanelApplet -Path "TestDrive:\ExistingFolder" }
                }
            }

            Context "Failing parameter validation" -Tag "ExpectedFail" {

                BeforeAll {

                    [void] ( New-Item -Path "TestDrive:\ExistingFolder1" -ItemType "Directory" )
                    [void] ( New-Item -Path "TestDrive:\ExistingFolder2" -ItemType "Directory" )
                }

                It "Should not accept a named parameter string to a non-existent folder" {

                    { Get-Cpl -Path "TestDrive:\FakeFolder1\FakeFolder2\FakeFolder3" } | Should -Throw
                }

                It "Should not accept an integer as a named parameter" {

                    { Get-Cpl -Path ([int] 1) } | Should -Throw
                }

                It "Should not accept multiple strings" {

                    { Get-Cpl -Path "TestDrive:\ExistingFolder1", "TestDrive:\ExistingFolder2" } | Should -Throw
                }
            }
        }

        Context "Execution" {

            BeforeAll {

                [void] (New-Item -Path "TestDrive:\ExistingFolder" -ItemType "Directory")
                Get-ChildItem -Path "C:\Windows\System32\*.cpl" |
                    Select-Object -First 5 |
                    Copy-Item -Destination "TestDrive:\ExistingFolder"
            }

            It "Should only perform one search for each path" {

                Mock Get-ChildItem -MockWith {

                    $True
                }

                Get-Cpl -Path "TestDrive:\ExistingFolder"

                Assert-MockCalled Get-ChildItem -Exactly 1 -Scope "It"
            }
        }

        Context "Output" {

            BeforeAll {

                [void] (New-Item -Path "TestDrive:\ExistingFolder" -ItemType "Directory")
                Get-ChildItem -Path "C:\Windows\System32\*.cpl" |
                    Select-Object -First 5 |
                    Copy-Item -Destination "TestDrive:\ExistingFolder"

                $Results = @(Get-Cpl -Path "TestDrive:\ExistingFolder")
            }

            It "Should output a PSCustomObject" {

                $Results[0].PSObject.TypeNames | Should -Contain "System.Management.Automation.PSCustomObject"
            }

            It "Should have three properties" {

                $Results[0].PSObject.Properties.Name.Count | Should -Be 3
            }
        }
    }
}