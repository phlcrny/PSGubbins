@{
    PSDependOptions = @{
        DependencyType     = 'PSGalleryModule'
        Target             = '$PWD\.dependencies'
        SkipPublisherCheck = $True
        AddToPath          = $True
    }
    BuildHelpers    = '2.0.11'
    psake           = '4.9.0'
    PSDeploy        = '1.0.3'
    Pester          = '4.10.1'
}