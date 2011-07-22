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

@class MainView;

@interface erkAppDelegate : NSObject <NSApplicationDelegate, IrcServerDelegate>
{
	NSWindow *_window;
    MainView *_mainView;
    
    IrcServer *_server;
    NSMutableDictionary *_serverData;
    NSString *_currentChannel;
    
    NSManagedObjectContext *_managedObjectContext;
    NSManagedObjectModel *_managedObjectModel;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
}

@property (nonatomic, retain) MainView *mainView;

@property (nonatomic, retain) NSMutableDictionary *serverData;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)doCommand:(NSString *)command;
- (NSInteger)countChannels;
- (NSString *)channelNameForRow:(NSInteger)row;
- (void)setCurrentChannelForRow:(NSInteger)row;
- (NSInteger)countUsers;
- (NSString *)userForRow:(NSInteger)row;
- (NSInteger)countMessages;
- (NSString *)messageBodyForRow:(NSInteger)row;

- (NSMutableDictionary *)loadChannel:(NSString *)channel;

- (NSString *)applicationDocumentsDirectory;

@end
