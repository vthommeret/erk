//
//  PreferencesController.h
//  erk
//
//  Created by Vernon Thommeret on 8/13/11.
//  Copyright 2011 Allergic Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PreferencesController : NSObject {
    NSWindow *_window;
}

@property (nonatomic, retain) IBOutlet NSWindow *window;

- (void)show;

@end
