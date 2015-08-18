//
//  OnozOmgEditingGuideView.m
//  CustomWatchFaceTest
//
//  Created by Hamza Sood on 17/08/2015.
//  Copyright © 2015 Hamza Sood. All rights reserved.
//

#import "OnozOmgEditingGuideView.h"

@implementation OnozOmgEditingGuideView

/*
 Initial setup steps:
    1. Create the views and their corresponding labels
    2. Set the label text
    3. Constrain the views
*/
- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        
        // 1
        __strong UIView  **viewsToCreate[]  = { &_topView, &_bottomView };
        __strong UILabel **labelsToCreate[] = { &_topLabel, &_bottomLabel };
        for (int i = 0; i < sizeof(viewsToCreate)/sizeof(UIView**); i++) {
            UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
            [view setTranslatesAutoresizingMaskIntoConstraints:NO];
            [self addSubview:view];
            
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectZero];
            [label setTranslatesAutoresizingMaskIntoConstraints:NO];
            [view addSubview:label];
            
            NSLayoutAttribute labelAttributesToConstrain[] = { NSLayoutAttributeCenterX, NSLayoutAttributeCenterY };
            for (int j = 0; j < sizeof(labelAttributesToConstrain)/sizeof(NSLayoutAttribute); j++) {
                NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:label
                                                                              attribute:labelAttributesToConstrain[j]
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:view
                                                                              attribute:labelAttributesToConstrain[j]
                                                                             multiplier:1
                                                                               constant:0];
                [constraint setActive:YES];
            }
            
            *viewsToCreate[i] = view;
            *labelsToCreate[i] = label;
        }
        
        // 2
        [_topLabel setText:@"First Colour"];
        [_bottomLabel setText:@"Second Colour"];
        
        // 3
        NSString *constraintsToAdd[] = {
            @"H:|[_topView]|",
            @"H:|[_bottomView]|",
            @"V:|[_topView]-(0)-[_bottomView(==_topView)]|"
        };
        NSDictionary *constraintsViewsDictionary = NSDictionaryOfVariableBindings(_topView, _bottomView);
        for (int i = 0; i < sizeof(constraintsToAdd)/sizeof(NSString*); i++) {
            [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constraintsToAdd[i]
                                                                                            options:0
                                                                                            metrics:nil
                                                                                              views:constraintsViewsDictionary]];
        }
    }
    return self;
}

- (void)setTopColor:(UIColor *)color {
    [_topView setBackgroundColor:color];
}

- (void)setBottomColor:(UIColor *)color {
    [_bottomView setBackgroundColor:color];
}

@end
