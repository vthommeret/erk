//
//  erkAppDelegate.m
//  erk
//
//  Created by Vernon Thommeret on 7/3/11.
//  Copyright 2011 Allergic Studios. All rights reserved.
//

#import "erkAppDelegate.h"

#import "MainView.h"
#import "ChannelList.h"
#import "MessageList.h"
#import "UserList.h"

#import "Message.h"

@implementation erkAppDelegate

@synthesize mainView = _mainView;

@synthesize serverData = _serverData;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (id)init {
    if ((self = [super init])) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSString *host = [defaults stringForKey:@"host"];
        NSInteger port = [defaults integerForKey:@"port"];
        NSString *nick = [defaults stringForKey:@"nick"];
        NSString *user = [defaults stringForKey:@"user"];
        NSString *name = [defaults stringForKey:@"name"];
        NSString *serverPass = [defaults stringForKey:@"serverPass"];
        
        if (host && port && nick && user && name && serverPass) {
            _server = [[IrcServer alloc] initWithHost:host port:port
                                                 nick:nick user:user
                                                 name:name
                                           serverPass:serverPass
                                             delegate:self];
            
            NSMutableDictionary *serverData = [[NSMutableDictionary alloc] initWithCapacity:10];
            self.serverData = serverData;
            [serverData release];            
        }
    }
    return self;
}

- (void)dealloc
{
    [_window release];
    [_mainView release];
    
    [_server release];
    [_serverData release];
    
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
    
    [_server connect];
    
    [_window makeKeyAndOrderFront:nil];
}

#pragma mark -
#pragma mark Public methods

- (void)doCommand:(NSString *)command {
    if (_server.connected) {
        [_server readCommand:command fromChannel:_currentChannel];
    }
}

- (NSInteger)countChannels {
    return [_serverData count];
}

- (NSString *)channelNameForRow:(NSInteger)row {
    return [[_serverData allKeys] objectAtIndex:row];
}

- (void)setCurrentChannelForRow:(NSInteger)row {
    _currentChannel = [self channelNameForRow:row];
    [self.mainView.messageList.tableView reloadData];
    [self.mainView.userList.tableView reloadData];
}

- (NSInteger)countUsers {
    if (_currentChannel != nil) {
        return [[[_serverData objectForKey:_currentChannel] objectForKey:@"users"] count];
    }
    return 0;
}

- (NSString *)userForRow:(NSInteger)row {
    return [[[_serverData objectForKey:_currentChannel] objectForKey:@"users"] objectAtIndex:row];
}

- (NSInteger)countMessages {
    if (_currentChannel != nil) {
        return [[[_serverData objectForKey:_currentChannel] objectForKey:@"messages"] count];
    }
    return 0;
}

- (NSString *)messageBodyForRow:(NSInteger)row {
    return [[[[_serverData objectForKey:_currentChannel] objectForKey:@"messages"] objectAtIndex:row] description];
}

#pragma mark -
#pragma mark IrcServerDelegate methods

// These should probably move into a separate class at some point.

- (void)didConnect {
    [_server join:@"#vernon"];
}

- (void)didJoin:(NSString *)channel byUser:(NSString *)user {
    if ([_serverData objectForKey:channel] == nil) { // I joined
        [self loadChannel:channel];
        [self.mainView.channelList.tableView reloadData];
        _currentChannel = channel;
    } // else someone else joined
}

- (void)didSay:(NSString *)text to:(NSString *)recipient fromUser:(NSString *)sender {
    NSString *channel;
    
    if ([recipient isEqual:[_server getNick]]) { // private message
        channel = sender;
    } else { // channel message
        channel = recipient;
    }
    
    NSMutableDictionary *channelData = [_serverData objectForKey:channel];
    if (channelData == nil) {
        channelData = [self loadChannel:channel];
        [[channelData objectForKey:@"users"] addObjectsFromArray:[NSArray arrayWithObjects:sender, recipient, nil]];
    }

    NSMutableArray *messages = [channelData objectForKey:@"messages"];
    
    Message *message = [[Message alloc] initWithText:text user:sender time:[NSDate date]];
    [messages addObject:message];
    [message release];
    
    if ([channel isEqual:_currentChannel]) {
        [self.mainView.messageList.tableView reloadData];
    } else {
        NSNumber *unread = [channelData objectForKey:@"unread"];
        [channelData setObject:[NSNumber numberWithInt:([unread intValue] + 1)] forKey:@"unread"];
        [self.mainView.channelList.tableView reloadData];
    }
}

- (void)didTopic:(NSString *)topic onChannel:(NSString *)channel fromUser:(NSString *)user {
    NSMutableArray *messages = [[_serverData objectForKey:channel] objectForKey:@"messages"];
    
    TopicMessage *message = [[TopicMessage alloc] initWithText:topic user:user time:[NSDate date]];
    [messages addObject:message];
    [message release];
    
    if ([channel isEqual:_currentChannel]) {
        [self.mainView.messageList.tableView reloadData];
    }
}

- (void)didNames:(NSArray *)names forChannel:(NSString *)channel {
    NSMutableArray *users = [[_serverData objectForKey:channel] objectForKey:@"users"];
    
    [users addObjectsFromArray:names];
    
    if ([channel isEqual:_currentChannel]) {
        [self.mainView.userList.tableView reloadData];
    }
}

#pragma mark -
#pragma mark Private methods

- (NSMutableDictionary *)loadChannel:(NSString *)channel {
    NSMutableArray *messages = [[NSMutableArray alloc] initWithCapacity:10];
    NSMutableArray *users = [[NSMutableArray alloc] initWithCapacity:10];
    
    NSMutableDictionary *channelData = [NSMutableDictionary dictionaryWithObjectsAndKeys:messages, @"messages",
                                        users, @"users",
                                        [NSNumber numberWithInt:0], @"unread", nil];
    [messages release];
    [users release];
    
    [_serverData setObject:channelData forKey:channel];
    
    return channelData;
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
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
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
