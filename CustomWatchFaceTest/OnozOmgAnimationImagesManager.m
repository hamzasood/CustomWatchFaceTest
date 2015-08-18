//
//  OnozOmgAnimationImagesManager.m
//  CustomWatchFaceTest
//
//  Created by Hamza Sood on 18/08/2015.
//  Copyright © 2015 Hamza Sood. All rights reserved.
//

#import "OnozOmgAnimationImagesManager.h"
#include <mach-o/dyld.h>
#import <mach-o/getsect.h>

#define kImageCount 24

@implementation OnozOmgAnimationImagesManager {
    NSArray<UIImage *> *_animationImages;
}

+ (instancetype)sharedAnimationImagesManager {
    static id sharedAnimationImagesManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAnimationImagesManager = [[self alloc]init];
    });
    return sharedAnimationImagesManager;
}

/*
 To avoid needing to find somewhere for the animation image files, they're embedded right into the dylib.
 Check the "Other Linker Flags" build settings to see where that's done.
*/
- (void)_createImagesIfNeeded {
    if (_animationImages == nil) {
        
        // Just in case a 64-bit Apple Watch happens
#ifndef __LP64__
        const struct mach_header *ourHeader = NULL;
#else
        const struct mach_header_64 *ourHeader = NULL;
#endif
        
        // Search all loaded images for our header.
        for (int i = 0; i < _dyld_image_count(); i++) {
            if (strstr(_dyld_get_image_name(i), "CustomWatchFaceTest.dylib") != NULL) {
                ourHeader = _dyld_get_image_header(i);
                break;
            }
        }
        
        NSMutableArray *tempImagesArray = [[NSMutableArray alloc]initWithCapacity:kImageCount];
        for (int i = 1; i <= kImageCount; i++) {
            char sectionName[10];
            sprintf(sectionName, "img%i", i);
            
            unsigned long sectionDataLength;
            uint8_t *sectionDataBytes = getsectiondata(ourHeader, "__ANIMATION", sectionName, &sectionDataLength);
            
            NSData *sectionData = [NSData dataWithBytes:sectionDataBytes length:sectionDataLength];
            [tempImagesArray addObject:[UIImage imageWithData:sectionData]];
        }
        _animationImages = [tempImagesArray copy];
        
    }
}

- (NSArray<UIImage *> *)animationImages {
    [self _createImagesIfNeeded];
    return _animationImages;
}

- (UIImage *)imageAtIndex:(NSUInteger)index {
    [self _createImagesIfNeeded];
    return _animationImages[index];
}

- (void)discardImages {
    _animationImages = nil;
}

@end
