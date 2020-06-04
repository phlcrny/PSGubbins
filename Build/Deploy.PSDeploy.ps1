Deploy Module {
    By PSGalleryModule {
        FromSource $ENV:BHBuildOutput
        To PSGallery
        WithOptions @{
            ApiKey = $ENV:PSGalleryToken
        }
    }
}