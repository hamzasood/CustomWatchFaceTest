//
//  OnozOmgFaceView.m
//  CustomWatchFaceTest
//
//  Created by Hamza Sood on 17/08/2015.
//  Copyright © 2015 Hamza Sood. All rights reserved.
//

#import "OnozOmgFaceView.h"
#import "OnozOmgFace.h"
#import "OnozOmgEditingGuideView.h"
#import "OnozOmgAnimationImagesManager.h"
#import "Hooking.h"

#define kPulsingAnimationIdentifier @"BackgroundColorPulsingAnimation"

@implementation OnozOmgFaceView

/*
 Called when the system is about to replace the snapshot of our face with the actual face view.
 This is where most UI elements should be created.
 NTKBackgroundImageFaceView already uses this to create the time in the top right corner.
*/
- (void)_loadSnapshotContentViews {
    [super _loadSnapshotContentViews];
    [self _createAnimationImageViewIfNeeded];
}

/*
 This is called when the foreground container view needs to layout its contents.
 After calling super, the time label will have been positioned. So we can use that to layout the image view.
*/
- (void)_layoutForegroundContainerView {
    [super _layoutForegroundContainerView];
    [_animationImageView setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.width * 3.0/5.0)];
    [_animationImageView setCenter:CGPointMake(self.center.x,
                                               CGRectGetHeight(self.bounds) - CGRectGetMaxY(self.timeLabel.frame))];
}

/*
 Called when the "frozen" property is changed (screen dimming, notifications etc.).
 We can use this to appropriately start and stop animations.
*/
- (void)_applyFrozen {
    [super _applyFrozen];
    
    // The NTKFaceView being edited gets unfrozen for editing before its editing property is set.
    // We don't want to unfreeze for editing, so we can check the isFaceEditing property of the library view controller.
    // We need to use a Carousel class to access the library view controller, so we need to use ObjC runtime functions.
    id clockVC = [GetClass(NCClockViewController) performSelector:@selector(sharedClockViewController)];
    NTKFaceLibraryViewController *libraryVC = GetIvar(clockVC, _libraryViewController);
    
    if (self.isFrozen || self.editing || libraryVC.isFaceEditing) {
        [self _stopPulsingAnimation];
        [self _stopImageAnimation];
    }
    else {
        [self _startPulsingAnimation];
        [self _startImageAnimation];
    }
}

/*
 Called when our face has been replaced with a snapshot.
 This is where things we created in _loadSnapshotContentViews should be destroyed.
*/
- (void)_unloadSnapshotContentViews {
    [self _destroyAnimationImageViewIfNeeded];
    [super _unloadSnapshotContentViews];
}




#pragma mark - Image Animation

- (void)_createAnimationImageViewIfNeeded {
    if (_animationImageView == nil) {
        NSArray *animationImages = OnozOmgAnimationImagesManager.sharedAnimationImagesManager.animationImages;
        _animationImageView = [[UIImageView alloc]initWithImage:animationImages[0]];
        [_animationImageView setAnimationImages:animationImages];
        [_animationImageView setAnimationDuration:1.0];
        [self addSubview:_animationImageView];
    }
}

- (void)_startImageAnimation {
    [_animationImageView startAnimating];
}

- (void)_stopImageAnimation {
    if (_animationImageView.isAnimating) {
        _animationEndCrossfadeView = [[UIView alloc]initWithFrame:_animationImageView.frame];
        [_animationEndCrossfadeView.layer setContents:[_animationImageView.layer.presentationLayer contents]];
        [self addSubview:_animationEndCrossfadeView];
        
        [UIView animateWithDuration:0.3 animations:^{
            [_animationEndCrossfadeView setAlpha:0.0];
        } completion:^(BOOL finished) {
            [_animationEndCrossfadeView removeFromSuperview];
            _animationEndCrossfadeView = nil;
        }];
        
        [_animationImageView stopAnimating];
    }
}

- (void)_destroyAnimationImageViewIfNeeded {
    if (_animationImageView != nil) {
        [_animationImageView removeFromSuperview];
        _animationImageView = nil;
    }
    [OnozOmgAnimationImagesManager.sharedAnimationImagesManager discardImages];
}




#pragma mark - Pulsing Animation

- (void)_startPulsingAnimation {
    CABasicAnimation *pulsingAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    [pulsingAnimation setDuration:0.75];
    [pulsingAnimation setAutoreverses:true];
    [pulsingAnimation setRepeatCount:FLT_MAX];
    [pulsingAnimation setFromValue:(id)_firstColor.CGColor];
    [pulsingAnimation setToValue:(id)_secondColor.CGColor];
    [self.layer addAnimation:pulsingAnimation forKey:kPulsingAnimationIdentifier];
}

- (void)_stopPulsingAnimation {
    [self.layer setBackgroundColor:[(CALayer *)self.layer.presentationLayer backgroundColor]];
    [self.layer removeAllAnimations];
    
    CABasicAnimation *backToFirstColorAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    [backToFirstColorAnimation setDuration:0.3];
    [backToFirstColorAnimation setFromValue:(id)self.layer.backgroundColor];
    [backToFirstColorAnimation setToValue:(id)_firstColor.CGColor];
    [self.layer addAnimation:backToFirstColorAnimation forKey:@"BackToFirstColorAnim"];
    
    [self.layer setBackgroundColor:_firstColor.CGColor];
}




#pragma mark - Edit Mode

/*
 Called as the face is about to go into edit mode.
 We can use this oppurtinity to create the editing guide view and place it in the view heirachy.
*/
- (void)_prepareForEditing {
    [super _prepareForEditing];
    _editingGuideView = [[OnozOmgEditingGuideView alloc]initWithFrame:self.bounds];
    [_editingGuideView setTopColor:_firstColor];
    [_editingGuideView setBottomColor:_secondColor];
    [_editingGuideView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [_editingGuideView setAlpha:0.0];
    [self addSubview:_editingGuideView];
}

/*
 Called multiple times during the transition between different edit modes (-1 = not editing).
 We can use this to drive the reveal animation for the editing guide.
*/
- (void)_configureForTransitionFraction:(CGFloat)fraction fromEditMode:(NSInteger)fromEditMode toEditMode:(NSInteger)toEditMode {
    [super _configureForTransitionFraction:fraction fromEditMode:fromEditMode toEditMode:toEditMode];
    if (fromEditMode == -1)
        [_editingGuideView setAlpha:fraction];
    else if (toEditMode == -1)
        [_editingGuideView setAlpha:(1.0 - fraction)];
}

/*
 Called by NTKBackgroundImageFaceView as it transitions to and from edit mode.
 We don't want to see the time at all in edit mode, so we return 0 if the edit mode isn't -1 (i.e. if we're actually editing)
*/
- (CGFloat)_timeLabelAlphaForEditMode:(NSInteger)editMode {
    return (editMode != -1 ? 0.0 : 1.0);
}

/*
 The frame of the outline shown around what's currently being edited.
 We want the first edit mode to outline the top half of the screen and the second edit mode to highlight the bottom half.
*/
- (CGRect)_keylineFrameForCustomEditMode:(NSInteger)editMode {
    CGFloat keylineY = (editMode == kOnozOmgEditModeFirstColor ? 0 : self.bounds.size.height/2);
    return CGRectMake(0, keylineY, self.bounds.size.width, self.bounds.size.height/2);
}

/*
 Called multiple times as the crown is moving between different options.
 We want to interpolate between the different options and set the appropriate color in the editing guide.
*/
- (void)_applyTransitionFraction:(CGFloat)fraction fromOption:(NTKEditOption *)fromOption toOption:(NTKEditOption *)toOption forCustomEditMode:(NSInteger)editMode {
    NTKFaceColorScheme *fromColorScheme = [NTKFaceColorScheme colorSchemeWithFaceColor:[(NTKFaceColorEditOption *)fromOption faceColor]
                                                                                 units:NTKFaceColorSchemeUnitForeground];
    NTKFaceColorScheme *toColorScheme = [NTKFaceColorScheme colorSchemeWithFaceColor:[(NTKFaceColorEditOption *)toOption faceColor]
                                                                               units:NTKFaceColorSchemeUnitForeground];
    NTKFaceColorScheme *transitionColorScheme = [NTKFaceColorScheme interpolationFrom:fromColorScheme to:toColorScheme fraction:fraction];
    
    if (editMode == kOnozOmgEditModeFirstColor)
        [_editingGuideView setTopColor:transitionColorScheme.foregroundColor];
    else
        [_editingGuideView setBottomColor:transitionColorScheme.foregroundColor];
}

/*
 Called once the option has actually changed, as opposed to scrolling through intermediary states.
 This is where we actually set the colors.
*/
- (void)_applyOption:(NTKEditOption *)option forCustomEditMode:(NSInteger)editMode {
    NTKFaceColorScheme *colorScheme = [NTKFaceColorScheme colorSchemeWithFaceColor:[(NTKFaceColorEditOption *)option faceColor]
                                                                             units:NTKFaceColorSchemeUnitForeground];
    if (editMode == kOnozOmgEditModeFirstColor) {
        _firstColor = colorScheme.foregroundColor;
        [self setBackgroundColor:_firstColor];
    }
    else {
        _secondColor = colorScheme.foregroundColor;
    }
}

/*
 Called after the face has left editing mode.
 We can use this oppurtunity to destroy the editing guide.
*/
- (void)_cleanupAfterEditing {
    [_editingGuideView removeFromSuperview];
    _editingGuideView = nil;
    [super _cleanupAfterEditing];
}

@end
