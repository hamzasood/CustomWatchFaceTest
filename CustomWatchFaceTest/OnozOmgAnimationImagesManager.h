//
//  OnozOmgAnimationImagesManager.h
//  CustomWatchFaceTest
//
//  Created by Hamza Sood on 18/08/2015.
//  Copyright © 2015 Hamza Sood. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OnozOmgAnimationImagesManager : NSObject

+ (instancetype)sharedAnimationImagesManager;

- (NSArray<UIImage *> *)animationImages;
- (UIImage *)imageAtIndex:(NSUInteger)index;

- (void)discardImages;

@end
