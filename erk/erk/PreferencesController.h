//
//  PreferencesController.h
//  erk
//
//  Created by Vernon Thommeret on 8/13/11.
//  Copyright 2011 Allergic Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TUIKit.h"

@interface PreferencesController : NSObject {
    NSPanel *_panel;
    TUIView *_view;
}

@property (nonatomic, retain) NSPanel *panel;

@end