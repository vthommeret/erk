//
//  erkAppDelegate.m
//  erk
//
//  Created by Vernon Thommeret on 7/3/11.
//  Copyright 2011 Allergic Studios. All rights reserved.
//

#import "erkAppDelegate.h"

#import "ServerController.h"

#import "ChannelList.h"
#import "MessageList.h"
#import "UserList.h"
#import "PreferencesController.h"

#import "Server.h"
#import "Channel.h"
#import "AlertWord.h"

#import "NSInvocation+ForwardedConstruction.h"
#import "NSData+Base64.h"

@implementation erkAppDelegate

@synthesize mainView = _mainView;

@synthesize activeServerController = _activeServerController;

@synthesize serverData = _serverData;

@synthesize mediumFont = _helvetica15;
@synthesize mediumBoldFont = _helveticaBold15;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (id)init {
    if ((self = [super init])) {
        NSManagedObjectContext *context = [self managedObjectContext];
        
        NSFetchRequest *serverFetchRequest = [[NSFetchRequest alloc] init];
        
        [serverFetchRequest setEntity:[Server entityDescriptionInContext:context]];
        NSArray *servers = [context executeFetchRequest:serverFetchRequest error:nil];
        
        [serverFetchRequest release];
        
        _serverControllers = [[NSMutableArray alloc] initWithCapacity:servers.count];
        
        for (Server *server in servers) {
            ServerController *serverController = [[ServerController alloc] initWithServer:server appDelegate:self];
            
            [_serverControllers addObject:serverController];
            _activeServerController = serverController;
            
            [serverController release];
            
            _unreadAlerts = 0;
            
            break; // Only support one server for now.
        }
        
        // fonts
        
        self.mediumFont = [TUIFont fontWithName:@"HelveticaNeue" size:15];
		self.mediumBoldFont = [TUIFont fontWithName:@"HelveticaNeue-Bold" size:15];
    }
    return self;
}

- (void)dealloc
{
    [_window release];
    [_mainView release];
    [_preferences release];
    
    [_serverControllers release];
    
    [_serverData release];
    
    [_highlightWords release];
    
    [_helvetica15 release];
    [_helveticaBold15 release];
    
    [_managedObjectContext release];
    [_managedObjectModel release];
    [_persistentStoreCoordinator release];
    
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    CGRect bounds = CGRectMake(0, 0, 700, 450);
    
    _window = [[NSWindow alloc] initWithContentRect:bounds 
                                        styleMask:NSTitledWindowMask | NSClosableWindowMask | NSResizableWindowMask 
                                          backing:NSBackingStoreBuffered 
                                            defer:NO];
    [_window setMinSize:NSMakeSize(500, 350)];
    [_window center];
    
    TUINSView *tuiContainer = [[TUINSView alloc] initWithFrame:bounds];
    [_window setContentView:tuiContainer];
    [tuiContainer release];
    
    MainView *mainView = [[MainView alloc] initWithFrame:bounds];
    tuiContainer.rootView = mainView;
    
    self.mainView = mainView;
    [mainView release];
    
    for (ServerController *serverController in _serverControllers) {
        [serverController connect];
    }
    
    [_window makeKeyAndOrderFront:nil];
    
    // Preferences
    
    _preferences = [[PreferencesController alloc] init];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
//    NSMutableDictionary *channelData = [_serverData objectForKey:_currentChannel];
//    
//    [self decrementUnreadAlerts:[[channelData objectForKey:@"unreadAlerts"] intValue]];
//    
//    [channelData setValue:[NSNumber numberWithInt:0] forKey:@"unreadAlerts"];
//    [self.mainView.channelList reloadData];
}

- (IBAction)showPreferences:(id)sender {
    [_preferences show];
}

- (void)updateWindowTitle {
    NSMutableDictionary *channelData = [_activeServerController activeChannelData];
    NSString *topic = [channelData objectForKey:@"topic"];
    
    NSString *title;
    
    NSString *activeChannelName = [_activeServerController activeChannelName];
    
    if (topic == nil || [topic isEqualToString:@""]) {
        title = [NSString stringWithFormat:@"%@", activeChannelName];
    } else {
        title = [NSString stringWithFormat:@"%@ — %@", activeChannelName, topic];
    }
    
    [_window setTitle:title];
}

#pragma mark -
#pragma mark Public methods

- (void)sendCommand:(NSString *)command {
    [_activeServerController readCommand:command];
}

- (NSInteger)countChannels {
    return [_activeServerController countChannels];
}

- (NSString *)channelNameForRow:(NSInteger)row {
    return [_activeServerController channelNameForRow:row];
}

- (NSMutableDictionary *)channelDataForName:(NSString *)name {
    return [_activeServerController channelDataForName:name];
}

- (void)setCurrentChannelForRow:(NSInteger)row {
//    _currentChannel = [self channelNameForRow:row];
//    
//    NSMutableDictionary *channelData = [_activeServerController activeChannelData];
//    
//    [self decrementUnreadAlerts:[[channelData objectForKey:@"unreadAlerts"] intValue]];
//    
//    [channelData setValue:[NSNumber numberWithInt:0] forKey:@"unreadMessages"];
//    [channelData setValue:[NSNumber numberWithInt:0] forKey:@"unreadAlerts"];
//    
//    [self.mainView.channelList reloadData];
//    [self.mainView.messageList reloadData];
//    [self.mainView.userList reloadData];
//    
//    [self updateWindowTitle];
}

- (NSInteger)countUsers {
    if ([_activeServerController activeChannelName] != nil) {
        return [[[_activeServerController activeChannelData] objectForKey:@"users"] count];
    }
    return 0;
}

- (void)sortUsers {
    NSString *activeChannelName = [_activeServerController activeChannelName];
    
    if (activeChannelName != nil) {
        NSString *currentNick = [self nick];
        NSMutableDictionary *channelData = [_serverData objectForKey:activeChannelName];
        
        NSMutableArray *users = [channelData objectForKey:@"users"];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"description" ascending:YES];
        NSMutableArray *sortedUsers = [[users sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]] mutableCopy];
        [sortDescriptor release];
        
        [sortedUsers removeObject:currentNick];
        [sortedUsers insertObject:currentNick atIndex:0];
        
        [channelData setObject:sortedUsers forKey:@"users"];
        [sortedUsers release];
    }
}

- (NSString *)userForRow:(NSInteger)row {
    return [[[_activeServerController activeChannelData] objectForKey:@"users"] objectAtIndex:row];
}

- (NSInteger)countMessages {
    if ([_activeServerController activeChannelName] != nil) {
        return [[[_activeServerController activeChannelData] objectForKey:@"messages"] count];
    }
    return 0;
}

- (OldMessage *)messageForRow:(NSInteger)row {
    return [[[_activeServerController activeChannelData] objectForKey:@"messages"] objectAtIndex:row];
}

// TODO: per Objective-C convention "get" should only be used for getting things into a pointer.
- (NSString *)nick {
    return [_activeServerController nick];
}

- (NSString *)getCurrentChannel {
    return [_activeServerController activeChannelName];
}

- (NSArray *)highlightWords {
    return _highlightWords;
}

#pragma mark -
#pragma mark IrcConnectionDelegate methods

// These should probably move into a separate class at some point.

//- (void)didPart:(NSString *)channel byUser:(NSString *)user {
//    if ([_serverData objectForKey:channel] != nil) {
//        NSMutableDictionary *channelData = [_serverData objectForKey:channel];
//        
//        NSMutableArray *users = [channelData objectForKey:@"users"];
//        [users removeObject:user];
//        
//        NSMutableArray *messages = [channelData objectForKey:@"messages"];
//        
//        PartMessage *message = [[PartMessage alloc] initWithUser:user time:[NSDate date]];
//        [messages addObject:message];
//        [message release];
//        
//        if ([channel isEqualToString:_currentChannel]) {
//            [self.mainView.messageList reloadData];
//            [self.mainView.userList reloadData];
//        }
//    }
//}

//- (void)didTopic:(NSString *)topic onChannel:(NSString *)channel fromUser:(NSString *)user {
//    NSMutableDictionary *channelData = [_serverData objectForKey:channel];
//    
//    NSMutableArray *messages = [channelData objectForKey:@"messages"];
//    
//    TopicMessage *message = [[TopicMessage alloc] initWithTopic:topic user:user time:[NSDate date]];
//    [messages addObject:message];
//    [message release];
//    
//    [channelData setObject:topic forKey:@"topic"];
//    
//    if ([channel isEqual:_currentChannel]) {
//        [self.mainView.messageList reloadData];
//        [self updateWindowTitle];
//    }
//}

//- (void)didNick:(NSString *)nick fromUser:(NSString *)user {
//    if (_currentChannel != nil) {
//        NSMutableDictionary *channel = [_serverData objectForKey:_currentChannel];
//        NSMutableArray *messages = [channel objectForKey:@"messages"];
//        NSMutableArray *users = [channel objectForKey:@"users"];
//
//        [users removeObject:user];
//        if ([nick isEqual:[_server nick]]) {
//            [users insertObject:nick atIndex:0];
//        } else {
//            [users addObject:nick];            
//        }
//        
//        NickMessage *message = [[NickMessage alloc] initWithOldNick:user newNick:nick time:[NSDate date]];
//        [messages addObject:message];
//        [message release];
//        
//        [self.mainView.messageList reloadData];
//        [self.mainView.userList reloadData];
//    }
//}

//- (void)didNickInUse:(NSString *)nick {
//    if (_currentChannel != nil) {
//        NSMutableArray *messages = [[_serverData objectForKey:_currentChannel] objectForKey:@"messages"];
//
//        NickInUseMessage *message = [[NickInUseMessage alloc] initWithInUseNick:nick time:[NSDate date]];
//        [messages addObject:message];
//        [message release];
//        
//        [self.mainView.messageList reloadData];
//    }
//}

/**
 * See http://www.leeh.co.uk/draft-mitchell-irc-capabilities-02.html for the CAP command spec.
 */
//- (void)didCapWithSubcommand:(NSString *)subcommand capabilities:(NSArray *)capabilities {
//    if ([capabilities indexOfObject:@"sasl"] != NSNotFound) {
//        if ([subcommand isEqualToString:@"LS"]) {
//            [_server requestCapability:@"sasl"];
//        } else if ([subcommand isEqualToString:@"ACK"]) {
//            [_server authenticate:@"PLAIN"];
//        } else {
//            [_server cancelCapability];
//        }
//    }
//}

/**
 * Encryption bits lifted from http://colloquy.info/project/changeset/5259
 */
//- (void)didAuthenticate:(NSString *)type {
//    if ([type isEqualToString:@"+"]) {
//        NSData *nicknameData = [[self nick] dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]; 
//        
//        NSMutableData *authenticateData = [nicknameData mutableCopy]; 
//        [authenticateData appendBytes:"\0" length:1]; 
//        [authenticateData appendData:nicknameData]; 
//        [authenticateData appendBytes:"\0" length:1]; 
//        [authenticateData appendData:[[_server userPass] dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]]; 
//        
//        NSString *authString = [authenticateData base64EncodingWithLineLength:400];
//        NSArray *authStringParts = [authString componentsSeparatedByString:@"\n"];
//        
//        for (NSString *authStringPart in authStringParts) {
//            [_server authenticate:authStringPart];
//        }
//        
//        // If empty or the last string was exactly 400 bytes we need to send an empty AUTHENTICATE to indicate we're done.
//        if( !authStringParts.count || [[authStringParts lastObject] length] == 400 ) {
//            [_server authenticate:@"+"];
//        }
//    } else {
//        [_server cancelCapability];
//    }
//}

#pragma mark -
#pragma mark Private methods

- (void)incrementUnreadAlerts {
    [self setUnreadAlerts:_unreadAlerts + 1];
}

- (void)decrementUnreadAlerts:(int)numAlerts {
    [self setUnreadAlerts:_unreadAlerts - numAlerts];
}

- (void)clearUnreadAlerts {
    [self setUnreadAlerts:0];
}

- (void)setUnreadAlerts:(int)numAlerts {
    _unreadAlerts = numAlerts;
    if (_unreadAlerts > 0) {
        [NSApp dockTile].badgeLabel = [NSString stringWithFormat:@"%lu", _unreadAlerts];
    } else {
        [NSApp dockTile].badgeLabel = nil;
    }
}

#pragma mark -
#pragma mark CoreData methods

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel == nil) {
        _managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles: nil] retain];
    }
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator == nil) {
        NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSURL *storeURL = [NSURL fileURLWithPath:[dir stringByAppendingPathComponent:@"erk.sqlite"]];
        NSError *error = nil;
        
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
            [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
            NSLog(@"Unresolved Error: %@, %@", error, [error userInfo]);
            abort();
        }
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext == nil) {
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        if (coordinator != nil) {
            _managedObjectContext = [[NSManagedObjectContext alloc] init];
            [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        }
    }
    return _managedObjectContext;
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

@end
