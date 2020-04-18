# Ensure that the tests won't be polluted with any unexpected versions.
if (Get-Module -Name "PSGubbins")
{
    Write-Verbose -Message "Removing pre-imported module instance."
    Remove-Module -Name "PSGubbins"
}

Write-Verbose -Message "Importing module."
Import-Module -Name $ENV:BHPSModuleManifest
InModuleScope -ModuleName "PSGubbins" {

    Describe "Module Manifest Tests for 'PSGubbins'" -Tag "Build", "Module" {

        BeforeAll {

            [PSCustomObject] $ModuleManifest = (Import-PowerShellDataFile -Path $ENV:BHPSModuleManifest)
            [void] $ModuleManifest # So I don't have to see false the Problems in vscode.
        }

        It "Has a module description" {

            $ModuleManifest.Description | Should -Not -BeNullOrEmpty
        }

        It "Has exported functions" {

            $ModuleManifest.FunctionsToExport | Should -Not -BeNullOrEmpty
        }

        It "Has exported aliases" {

            $ModuleManifest.AliasesToExport | Should -Not -BeNullOrEmpty
        }

        It "Has no required modules" {

            $ModuleManifest.RequiredModules | Should -BeNullOrEmpty
        }

        It "Has a company name of 'N/A'" {

            $ModuleManifest.CompanyName | Should -Not -BeNullOrEmpty
            $ModuleManifest.CompanyName | Should -Be "N/A"
        }

        It "Has a valid GUID" {

            $ModuleManifest.Guid | Should -Not -BeNullOrEmpty
            $ModuleManifest.Guid | Should -Not -Be "00000000-0000-0000-0000-000000000000"
        }
    }
}
