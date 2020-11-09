@{
    PSDependOptions  = @{
        DependencyType     = 'PSGalleryModule'
        Target             = '$PWD\.dependencies'
        SkipPublisherCheck = $True
        AddToPath          = $True
    }
    BuildHelpers     = '2.0.11'
    psake            = '4.9.0'
    PSScriptAnalyzer = '1.18.3'
    Pester           = '4.10.1'
}