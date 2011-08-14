//
//  erkAppDelegate.h
//  erk
//
//  Created by Vernon Thommeret on 7/3/11.
//  Copyright 2011 Allergic Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreData/CoreData.h>
#import "TUIKit.h"
#import "IrcServer.h"

@class PreferencesController, MainView, Message;

@interface erkAppDelegate : NSObject <NSApplicationDelegate, IrcServerDelegate>
{
	NSWindow *_window;
    MainView *_mainView;
    PreferencesController *_preferences;
    
    IrcServer *_server;
    NSMutableDictionary *_serverData;
    NSString *_currentChannel;
    NSArray *_autojoinChannels;
    
    NSArray *_highlightWords;
    
    int _unreadAlerts;
    
    TUIFont *_helvetica15;
    TUIFont *_helveticaBold15;
    
    NSManagedObjectContext *_managedObjectContext;
    NSManagedObjectModel *_managedObjectModel;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
}

@property (nonatomic, retain) MainView *mainView;

@property (nonatomic, retain) NSMutableDictionary *serverData;

@property (nonatomic, retain) TUIFont *mediumFont;
@property (nonatomic, retain) TUIFont *mediumBoldFont;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (IBAction)showPreferences:(id)sender;

- (void)updateWindowTitle;

- (void)doCommand:(NSString *)command;
- (NSInteger)countChannels;
- (NSString *)channelNameForRow:(NSInteger)row;
- (NSMutableDictionary *)channelDataForName:(NSString *)name;
- (void)setCurrentChannelForRow:(NSInteger)row;
- (NSInteger)countUsers;
- (void)sortUsers;
- (NSString *)userForRow:(NSInteger)row;
- (NSInteger)countMessages;
- (Message *)messageForRow:(NSInteger)row;
- (NSString *)getNick;
- (NSString *)getCurrentChannel;
- (NSArray *)highlightWords;

- (NSMutableDictionary *)loadChannel:(NSString *)channel;
- (void)incrementUnreadAlerts;
- (void)decrementUnreadAlerts:(int)numAlerts;
- (void)clearUnreadAlerts;
- (void)setUnreadAlerts:(int)numAlerts;

- (NSString *)applicationDocumentsDirectory;

@end
