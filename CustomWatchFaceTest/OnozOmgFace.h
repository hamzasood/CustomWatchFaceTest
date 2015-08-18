//
//  OnozOmgFace.h
//  CustomWatchFaceTest
//
//  Created by Hamza Sood on 16/08/2015.
//  Copyright © 2015 Hamza Sood. All rights reserved.
//

#import <NanoTimeKit/NanoTimeKit.h>

#define kOnozOmgEditModeFirstColor  0
#define kOnozOmgEditModeSecondColor 1

/*
 An abstract class representing different properties of our custom face.
 NTKFace subclasses don't handle any view drawing, that's all handled by subclassing NTKFaceView.
 By subclassing NTKFace, one can provide options for complication slots and define the editing behaviour.
 
 NTKFace subclasses are cached on disk using NSSecureCoding, so if you modify any of the methods after Carousel has already loaded the face at least once, be sure to delete:
    * com.apple.Carousel.NanoTimeKit Cache
    * com.apple.NanoTimeKit.face Preferences
 Otherwise some values could be inconsistent
*/
@interface OnozOmgFace : NTKFace

@end
