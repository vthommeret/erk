//
//  PreferencesController.m
//  erk
//
//  Created by Vernon Thommeret on 8/13/11.
//  Copyright 2011 Allergic Studios. All rights reserved.
//

#import "PreferencesController.h"

@implementation PreferencesController

@synthesize window = _window;
@synthesize address = _address;

- (id)init {
    if ((self = [super init])) {
        [NSBundle loadNibNamed:@"Preferences" owner:self];
    }
    return self;
}

- (void)dealloc {
    [_window release];
    [super dealloc];
}

- (void)show {
    [_window makeFirstResponder:_address];
    
    [_window makeKeyAndOrderFront:nil];
    [_window center];
}

@end
