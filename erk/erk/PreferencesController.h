//
//  PreferencesController.h
//  erk
//
//  Created by Vernon Thommeret on 8/13/11.
//  Copyright 2011 Allergic Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PreferencesServerController;

@interface PreferencesController : NSObject <NSTableViewDelegate> {
    NSWindow *_window;
    NSTableView *_servers;
    NSTextField *_address;
    
    NSManagedObjectContext *_managedObjectContext;
}

@property (nonatomic, retain) IBOutlet NSWindow *window;
@property (nonatomic, retain) IBOutlet NSTableView *servers;
@property (nonatomic, retain) IBOutlet NSTextField *address;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)show;

- (IBAction)addServer:(id)sender;
- (IBAction)removeServer:(id)sender;
- (IBAction)help:(id)sender;

@end
