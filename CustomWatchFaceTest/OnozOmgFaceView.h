//
//  OnozOmgFaceView.h
//  CustomWatchFaceTest
//
//  Created by Hamza Sood on 17/08/2015.
//  Copyright © 2015 Hamza Sood. All rights reserved.
//

#import <NanoTimeKit/NanoTimeKit.h>

@class OnozOmgEditingGuideView;

/*
 This is where all visual things relating to our custom face happen.
 It's indirectly a subclass of UIView (OnozOmgFaceView -> NTKBackgroundImageFaceView -> NTKDigitalFaceView -> NTKFaceView -> UIView) which is displayed by an NTKFaceViewController.
 
 Starting with NTKBackgroundImageFaceView gives a few useful behaviours:
    * A time label in the top right
    * A vignette animation when zooming in from the home screen (NTKFaceView has methods to further customize this)
    * A rounded rect keyline view for each editing page
 
 Making changes here can lead to visual inconsistencies with old cached snapshots.
 So after making visual changes it's best to set "RegenerateAllSnapshots" in "com.apple.NanoTimeKit.face" preferences (check takes place in NTKDebugRegenerateAllSnapshots). 
*/

@interface OnozOmgFaceView : NTKBackgroundImageFaceView {
    UIColor *_firstColor;
    UIColor *_secondColor;
    
    UIImageView *_animationImageView;
    UIView *_animationEndCrossfadeView;
    
    OnozOmgEditingGuideView *_editingGuideView;
}

@end
