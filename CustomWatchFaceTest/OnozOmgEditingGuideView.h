//
//  OnozOmgEditingGuideView.h
//  CustomWatchFaceTest
//
//  Created by Hamza Sood on 17/08/2015.
//  Copyright © 2015 Hamza Sood. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OnozOmgEditingGuideView : UIView {
    UIView *_topView;
    UILabel *_topLabel;
    
    UIView *_bottomView;
    UILabel *_bottomLabel;
}

/*!
 Set the color shown by the top view.
    The new color to be displayed
*/
- (void)setTopColor:(UIColor *)color;

/*!
 Set the color shown by the bottom view.
 @param color
    The new color to be displayed
 */
- (void)setBottomColor:(UIColor *)color;

@end
