//
//  PreferencesController.m
//  erk
//
//  Created by Vernon Thommeret on 8/13/11.
//  Copyright 2011 Allergic Studios. All rights reserved.
//

#import "PreferencesController.h"
#import "erkAppDelegate.h"

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
    [_servers setDelegate:self];
}

- (void)show {
    [_window makeFirstResponder:_address];
    
    [_window makeKeyAndOrderFront:nil];
    [_window center];
}

- (IBAction)addServer:(id)sender {
    NSLog(@"add server");
}

- (IBAction)removeServer:(id)sender {
    NSLog(@"remove server");
}

- (IBAction)help:(id)sender {
    NSLog(@"not implemented");
}

#pragma mark -
#pragma NSTableViewDelegate methods

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSLog(@"changing");
}

@end
