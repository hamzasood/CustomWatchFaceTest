//
//  OnozOmgFace.m
//  CustomWatchFaceTest
//
//  Created by Hamza Sood on 16/08/2015.
//  Copyright © 2015 Hamza Sood. All rights reserved.
//

#import "OnozOmgFace.h"

@implementation OnozOmgFace

/*
 Number of edit pages.
 Each page represents the different colours that are displayed.
*/
+ (NSUInteger)_numberOfCustomEditModes {
    return 2;
}

/*
 If you add a face that is already in the library, the new instance of the face will be modified to have a diferent configuration.
 This option returns which edit page will be modified to make the different configuration.
*/
+ (NSInteger)_customEditModeForUniqueConfiguration {
    return 1;
}

/*
 The default value for each edit page.
 Purple and orange work quite well.
*/
+ (NTKEditOption *)_defaultOptionForCustomEditMode:(NSInteger)editMode {
    return [NTKFaceColorEditOption optionWithFaceColor:(editMode == kOnozOmgEditModeFirstColor ?
                                                        NTKFaceColorPurple :
                                                        NTKFaceColorOrange)];
}

/*
 How many options there are per page.
*/
- (NSUInteger)_numberOfOptionsForCustomEditMode:(NSInteger)editMode {
    return [NTKFaceColorEditOption numberOfOptions];
}

/*
 Returns the option corresponding to a given index.
*/
- (NTKEditOption *)_optionAtIndex:(NSUInteger)index forCustomEditMode:(NSInteger)editMode {
    return [NTKFaceColorEditOption optionAtIndex:index];
}

/*
 Return the index of a given option.
*/
- (NSUInteger)_indexOfOption:(NTKEditOption *)option forCustomEditMode:(NSInteger)editMode {
    return [NTKFaceColorEditOption indexOfOption:(NTKFaceColorEditOption *)option];
}

/*
 Whether a given option is valid.
 In our case, any NTKFaceColorEditOption instance is valid.
*/
- (BOOL)_option:(NTKEditOption *)option isValidForCustomEditMode:(NSInteger)editMode {
    return [option isKindOfClass:[NTKFaceColorEditOption class]];
}

@end
