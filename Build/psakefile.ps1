properties {
    $Settings = @{
        ModuleName         = $ENV:BHProjectName
        ModuleManifest     = Import-PowerShellDataFile -Path $ENV:BHPSModuleManifest
        ModuleManifestPath = $ENV:BHPSModuleManifest
        ModulePSMPath      = $ENV:BHPSModuleManifest -replace "psd1$", "psm1"
        BuildFolder        = Join-Path -Path $ENV:BHProjectPath -ChildPath "Build"
        SourceFolder       = Join-Path -Path $ENV:BHProjectPath -ChildPath "Source"
        ReleaseFolder      = $ENV:BHBuildOutput
        TestsFolder        = Join-Path -Path $ENV:BHProjectPath -ChildPath "Tests"
        TestResults        = Join-Path -Path $ENV:BHProjectPath -ChildPath "pester_results.xml"
        ReadMe             = Join-Path -Path $ENV:BHProjectPath -ChildPath "readme.md"
        ChangeLog          = Join-Path -Path $ENV:BHProjectPath -ChildPath "changelog.md"
        JobDivider         = "`n-----------------------------------------------------------------`n"
    }
}

Task default -depends "Test"

Task "Init" -description "Initialize psake and task variables" -action {
    "Build Environment Details:"
    Get-ChildItem -Path "ENV:\BH*" | Sort-Object -Property "Name"
    $Settings.JobDivider
}

Task "Clean" -description "Clean up compiled PSM1, test results etc" -depends "Init" {
    Get-ChildItem -Path "$($ENV:BHPSModulePath)\*" -File -Exclude "*.psd1" | Remove-Item -Force

    if ($Null -eq (Get-ChildItem -Path "$($ENV:BHPSModulePath)\*" -File -Exclude "*.psd1"))
    {
        "Clean task completed" | Write-Host -ForegroundColor "Green"
        $Settings.JobDivider
    }
    else
    {
        Write-Error -Message "Clean task failed"
        exit 1
    }
}

Task "Compile" -description "Compiles the PSM1 from source" -action {
    Write-Verbose -Message "Collecting any non-function Powershell code"
    $ModuleExtras = @(Get-ChildItem -Path $Settings.SourceFolder -File -Filter "*.ps1" |
            Select-Object -ExpandProperty "FullName")

    Write-Verbose -Message "Collecting internal and public functions"
    $Functions = @( "Internal", "Functions" | ForEach-Object {
            Get-ChildItem -Path (Join-Path -Path $Settings.SourceFolder -ChildPath $_ ) -File -Filter "*.ps1" |
                Select-Object -ExpandProperty "FullName"
        } )

    Write-Verbose -Message "Combining files to compile"
    $FilesToCompile = $ModuleExtras + $Functions

    Write-Verbose -Message "Destination PSM1 is '$($Settings.ModulePSMPath)'"
    Write-Verbose -Message "Timestamping PSM1"
    "# This PSM1 compiled with psake $(Get-Date -UFormat "%Y/%m/%d %H:%M:%S")" | Set-Content -Path $Settings.ModulePSMPath -Encoding "UTF8"
    forEach ($File in $FilesToCompile)
    {
        Write-Verbose -Message "Processing '$File'."
        "`n" | Add-Content -Path $Settings.ModulePSMPath -NoNewline -Encoding "UTF8" # Adds a line-exit 1, but only one.
        $ReadFunction = Get-Content -Path $File # Read the function.
        if ($ReadFunction)
        {
            "# $(Join-Path -Path "$($Settings.ModuleName)" -ChildPath ($File -split "$($Settings.ModuleName)" | Select-Object -Last 1))" | Add-Content -Path $Settings.ModulePSMPath -Encoding "UTF8"
            # Captions each compiled file with its relative source

            $ReadFunction | Add-Content -Path $Settings.ModulePSMPath -Encoding "UTF8" # Add the function to the .psm1
            Remove-Variable -Name "ReadFunction" # House-keeping - This might not be necessary but I can't see how it would hurt.
        }
        else
        {
            Write-Error -Message "Unable to find 'ReadFunction' after reading '$File'"
        }
    }
    "Compile task completed" | Write-Host -ForegroundColor "Green"
    $Settings.JobDivider
}

Task "Stage" -description "Stages relevant files in the release folder" -action {

    $FilesToStage = @(
        $Settings.ChangeLog
        $Settings.ReadMe
    )

    forEach ($File in $FilesToStage)
    {
        $StagingSplat = @{
            Path        = $File
            Destination = $Settings.ReleaseFolder
            Force       = $True
        }

        try
        {
            Copy-Item @StagingSplat
        }
        catch
        {
            Write-Error -Message "Stage task failed"
            $Error[0] | Select-Object *
            exit 1
        }
    }

    "Stage task completed" | Write-Host -ForegroundColor "Green"
    $Settings.JobDivider
}

Task "Build" -description "Compiles and stages the module" -depends "Clean", "Compile", "Stage" {
    "Build completed" | Write-Host -ForegroundColor "Green"
    $Settings.JobDivider
}

Task "Analyse" -description "Runs PSScriptAnalyzer" -action {
    $AnalysisSplat = @{
        Path          = $Settings.ReleaseFolder
        ReportSummary = $True
        Recurse       = $True
        Verbose       = $False
    }

    $Analysis = Invoke-ScriptAnalyzer @AnalysisSplat
    $Analysis | Format-Table -AutoSize
    if (($AnalysisErrors).Count -gt 0)
    {
        Write-Error -Message "The build cannot continue until linting errors are fixed."
        exit 1
    }
    elseif (($AnalysisWarnings).Count -gt 0)
    {
        Write-Warning -Message "The build can continue, but linting warnings should be addressed."
    }
    else
    {
        "Linting passed!" | Write-Host -ForegroundColor Green
    }

    $Settings.JobDivider
}

Task "Pester" -description "Run Pester tests" {
    if (Get-Module -Name $Settings.ModuleName)
    {
        Remove-Module -Name $Settings.ModuleName
    }

    $PesterSplat = @{
        Path          = $Settings.TestsFolder
        OutputFile    = $Settings.TestResults
        OutputFormat  = "NUnitXml"
        PassThru      = $True
        WarningAction = "SilentlyContinue" # We don't need Pester's warnings about Tag placements.
    }

    $PesterResults = @(Invoke-Pester @PesterSplat)
    if ($PesterResults.FailedCount -gt 0)
    {
        Write-Error "$($PesterResults.FailedCount) test(s) failed."
        exit 1
    }
    elseif (($Null -eq $PesterResults) -or ($Null -eq $PesterResults.TotalCount))
    {
        Write-Error "No Pester results returned at all"
        exit 1
    }
    else
    {
        "Tests passed!" | Write-Host -ForegroundColor Green
    }

    $Settings.JobDivider
}

Task "Test" -description "Runs linter and tests" -depends "Build", "Analyse", "Pester" -action {
    "Test completed" | Write-Host -ForegroundColor "Green"
    $Settings.JobDivider
}