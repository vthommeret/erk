//
//  PreferencesController.m
//  erk
//
//  Created by Vernon Thommeret on 8/13/11.
//  Copyright 2011 Allergic Studios. All rights reserved.
//

#import "PreferencesController.h"
#import "erkAppDelegate.h"

#import "Server.h"
#import "AlertWord.h"

@implementation PreferencesController

@synthesize window = _window;
@synthesize servers = _servers;
@synthesize address = _address;

@synthesize managedObjectContext = _managedObjectContext;

- (id)init {
    if ((self = [super init])) {
        erkAppDelegate *appDelegate = (erkAppDelegate *) [NSApplication sharedApplication].delegate;
        _managedObjectContext = appDelegate.managedObjectContext;
        
        [NSBundle loadNibNamed:@"Preferences" owner:self];
    }
    return self;
}

- (void)dealloc {
    [_window release];
    [_servers release];
    [_address release];
    
    [_managedObjectContext release];
    
    [super dealloc];
}

- (void)awakeFromNib {
    _window.delegate = self;
    _servers.delegate = self;
}

- (void)show {
    [_window makeFirstResponder:_address];
    
    [_window center];
    [_window makeKeyAndOrderFront:nil];
}

- (IBAction)help:(id)sender {
    NSLog(@"not implemented");
}

#pragma mark -
#pragma NSWindowDelegate methods

- (void)windowWillClose:(NSNotification *)notification {
    NSError *error = nil;
    if (![_managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    NSLog(@"saving");
}

#pragma mark -
#pragma NSTableViewDelegate methods

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSLog(@"changing");
}

@end
