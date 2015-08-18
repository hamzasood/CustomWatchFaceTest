# CustomWatchFaceTest
Custom watch faces on Apple Watch.

To install you'll need to get Carousel to load the dylib.

I've tried my best to comment most aspects of the code. Here's a quick overview of some the more important files (check the files for more in depth comments):

    * The list of supported faces are hardcoded, so SupportingHooks.m hooks methods Carousel uses to load the supported watch faces.
    * OnozOmgFace is an NTKFace subclass which sets how aspects of the peace works (customisation in this case).
    * OnozOmgFaceView is a UIView subclass which contains the visual elements that are actually displayed.
