//
//  PreferencesController.m
//  erk
//
//  Created by Vernon Thommeret on 8/13/11.
//  Copyright 2011 Allergic Studios. All rights reserved.
//

#import "PreferencesController.h"
#import "PreferencesView.h"

@implementation PreferencesController

@synthesize panel = _panel;

- (id)init {
    if ((self = [super init])) {
        CGRect bounds = CGRectMake(0, 0, 500, 300);
        
        _panel = [[NSPanel alloc] initWithContentRect:bounds
                                            styleMask:NSDocModalWindowMask
                                              backing:NSBackingStoreBuffered
                                                defer:NO];
        
        TUINSView *tuiContainer = [[TUINSView alloc] initWithFrame:bounds];
        [_panel setContentView:tuiContainer];
        [tuiContainer release];
        
        _view = [[PreferencesView alloc] initWithFrame:bounds];
        tuiContainer.rootView = _view;
    }
    return self;
}

- (void)dealloc {
    [_panel release];
    [_view release];
    [super dealloc];
}

@end
