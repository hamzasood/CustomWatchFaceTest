//
//  SupportingHooks.m
//  CustomWatchFaceTest
//
//  Created by Hamza Sood on 14/08/2015.
//  Copyright © 2015 Hamza Sood. All rights reserved.
//

#import "Hooking.h"
#import "OnozOmgFace.h"
#import "OnozOmgFaceView.h"

/*
 Extension of NTKFaceStyle.
 Each watch face has a style number which represents the type of face (utility, timelapse, atronomy etc.).
 The default faces occupy 0-15. Starting at 100 gives us a very comfortable gap to minimise chance of overwriting an existing face.
*/
#define CustomFaceStyleOnozOmg (NTKFaceStyle)100

Constructor(SupportingHooksInit) {
    
    /* 
     Hook +[NTKFace _faceClassForStyle:] to return our custom face class when needed.
    */
    HookClassMethod(Class, NTKFace, @selector(_faceClassForStyle:), ArgList(NTKFaceStyle faceStyle), {
        return (faceStyle == CustomFaceStyleOnozOmg ? [OnozOmgFace class] : Orig(faceStyle));
    });
    
    /* 
     Hook -[NTKFaceViewController loadView] to create our custom NTKFaceView subclass when needed.
    */
    HookInstanceMethod(void, NTKFaceViewController, @selector(loadView), NoArguments, {
        Orig();
        if (self.face.faceStyle == CustomFaceStyleOnozOmg) {
            [self.faceView removeFromSuperview];
            SetIvar(self, _faceView, nil);
            
            OnozOmgFaceView *customFaceView = [[OnozOmgFaceView alloc]init];
            [customFaceView setDelegate:self];
            [customFaceView setFaceStyle:self.face.faceStyle];
            [self.view addSubview:customFaceView];
            SetIvar(self, _faceView, customFaceView);
        }
    });
    
    /* 
     Hook -[NTKFaceLibrary _loadPotentialFaces] to add our face to the list of potential faces.
     Potential faces are all the possible faces a user could pick.
    */
    HookInstanceMethod(void, NTKFaceLibrary, @selector(_loadPotentialFaces), NoArguments, {
        Orig();
        if ([self potentialFaceForStyle:CustomFaceStyleOnozOmg] == nil) {
            NTKFace *myCustomFace = [NTKFace defaultFaceOfStyle:CustomFaceStyleOnozOmg];
            [self _setPotentialFace:myCustomFace];
            [self _dirtyPotentialFaceStyle:CustomFaceStyleOnozOmg];
        }
    });
    
    /*
     Hook -[NTKFaceLibrary reloadAddableFaceStyles] to have our face show up in the add list.
     We only want it to show up if we haven't already added it, or if it's editable (since then we can add it multiple times with different configurations)
    */
    HookInstanceMethod(void, NTKFaceLibrary, @selector(reloadAddableFaceStyles), NoArguments, {
        Orig();
        NTKFace *anyInstanceOfMyCustomFaceInTheFaceLibrary = [self _anyLibraryFaceOfStyle:CustomFaceStyleOnozOmg];
        if (anyInstanceOfMyCustomFaceInTheFaceLibrary == nil || anyInstanceOfMyCustomFaceInTheFaceLibrary.isEditable)
            [GetIvar(self, _addableFaceStyles) addObject:@(CustomFaceStyleOnozOmg)];
    });
    
    /* 
     Hook -[NSBundle localizedStringForKey:value:table:] to return the title of our custom watch face when needed.
    */
    HookInstanceMethod(NSString *, NSBundle, @selector(localizedStringForKey:value:table:), ArgList(NSString *key, NSString *value, NSString *tableName), {
        return ([key isEqualToString:[NSString stringWithFormat:@"FACE_STYLE_%i", CustomFaceStyleOnozOmg]] ? @"Onoz Omg" : Orig(key, value, tableName));
    });
    
}
