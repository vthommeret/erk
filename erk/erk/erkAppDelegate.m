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
        NSArray *autojoinChannels = [defaults arrayForKey:@"autojoinChannels"];
        
        if (host && port && nick && user && name && serverPass) {
            _server = [[IrcServer alloc] initWithHost:host port:port
                                                 nick:nick user:user
                                                 name:name
                                           serverPass:serverPass
                                             delegate:self];
            
            _autojoinChannels = [autojoinChannels retain];
            
            NSMutableDictionary *serverData = [[NSMutableDictionary alloc] initWithCapacity:10];
            self.serverData = serverData;
            [serverData release];
        }
        
        _unreadAlerts = 0;
    }
    return self;
}

- (void)dealloc
{
    [_window release];
    [_mainView release];
    
    [_server release];
    [_serverData release];
    [_autojoinChannels release];
    
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

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    NSMutableDictionary *channelData = [_serverData objectForKey:_currentChannel];
    
    [self decrementUnreadAlerts:[[channelData objectForKey:@"unreadAlerts"] intValue]];
    
    [channelData setValue:[NSNumber numberWithInt:0] forKey:@"unreadAlerts"];
    [self.mainView.channelList reloadData];
}

- (void)updateWindowTitle {
    NSMutableDictionary *channelData = [_serverData objectForKey:_currentChannel];
    NSString *topic = [channelData objectForKey:@"topic"];
    
    NSString *title;
    
    if (topic == nil || [topic isEqualToString:@""]) {
        title = [NSString stringWithFormat:@"%@", _currentChannel];
    } else {
        title = [NSString stringWithFormat:@"%@ — %@", _currentChannel, topic];
    }
    
    [_window performSelectorOnMainThread:@selector(setTitle:) withObject:title waitUntilDone:NO];
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

- (NSMutableDictionary *)channelDataForName:(NSString *)name {
    return [_serverData objectForKey:name];
}

- (void)setCurrentChannelForRow:(NSInteger)row {
    _currentChannel = [self channelNameForRow:row];
    
    NSMutableDictionary *channelData = [_serverData objectForKey:_currentChannel];
    
    [self decrementUnreadAlerts:[[channelData objectForKey:@"unreadAlerts"] intValue]];
    
    [channelData setValue:[NSNumber numberWithInt:0] forKey:@"unreadMessages"];
    [channelData setValue:[NSNumber numberWithInt:0] forKey:@"unreadAlerts"];
    
    [self.mainView.channelList reloadData];
    [self.mainView.messageList reloadData];
    [self.mainView.userList reloadData];
    
    [self updateWindowTitle];
}

- (NSInteger)countUsers {
    if (_currentChannel != nil) {
        return [[[_serverData objectForKey:_currentChannel] objectForKey:@"users"] count];
    }
    return 0;
}

- (void)sortUsers {
    if (_currentChannel != nil) {
        NSString *currentNick = [self getNick];
        NSMutableDictionary *channelData = [_serverData objectForKey:_currentChannel];
        
        NSMutableArray *users = [channelData objectForKey:@"users"];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"description" ascending:YES];
        NSMutableArray *sortedUsers = [[users sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]] mutableCopy];
        [sortDescriptor release];
        
        [sortedUsers removeObject:currentNick];
        [sortedUsers insertObject:currentNick atIndex:0];
        
        [channelData setObject:sortedUsers forKey:@"users"];
    }
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

- (Message *)messageForRow:(NSInteger)row {
    return [[[_serverData objectForKey:_currentChannel] objectForKey:@"messages"] objectAtIndex:row];
}

- (NSString *)getNick {
    return [_server getNick];
}

#pragma mark -
#pragma mark IrcServerDelegate methods

// These should probably move into a separate class at some point.

- (void)didConnect {
    [_server join:@"#vernon"];
    
    for (NSString *channel in _autojoinChannels) {
        [_server join:channel];
    }
}

- (void)didJoin:(NSString *)channel byUser:(NSString *)user {
    if ([_serverData objectForKey:channel] == nil) { // I joined
        [self loadChannel:channel];
        [self.mainView.channelList reloadData];
        _currentChannel = channel;
        [self.mainView.messageList reloadData];
        
        NSUInteger row = [[_serverData allKeys] indexOfObject:channel];
        TUIFastIndexPath *indexPath = [TUIFastIndexPath indexPathForRow:row inSection:0];
        
        [self.mainView.channelList selectRowAtIndexPath:indexPath];
        
        [self updateWindowTitle];
    } else {
        NSMutableDictionary *channelData = [_serverData objectForKey:channel];
        
        NSMutableArray *users = [channelData objectForKey:@"users"];
        [users addObject:user];
        
        NSMutableArray *messages = [channelData objectForKey:@"messages"];
        
        JoinMessage *message = [[JoinMessage alloc] initWithUser:user time:[NSDate date]];
        [messages addObject:message];
        [message release];
        
        if ([channel isEqualToString:_currentChannel]) {
            [self.mainView.messageList reloadData];
            [self.mainView.userList reloadData];
        }
    }
}

- (void)didPart:(NSString *)channel byUser:(NSString *)user {
    if ([_serverData objectForKey:channel] == nil) { // I joined
        // do something
    } else {
        NSMutableDictionary *channelData = [_serverData objectForKey:channel];
        
        NSMutableArray *users = [channelData objectForKey:@"users"];
        [users removeObject:user];
        
        NSMutableArray *messages = [channelData objectForKey:@"messages"];
        
        PartMessage *message = [[PartMessage alloc] initWithUser:user time:[NSDate date]];
        [messages addObject:message];
        [message release];
        
        if ([channel isEqualToString:_currentChannel]) {
            [self.mainView.messageList reloadData];
            [self.mainView.userList reloadData];
        }
    }
}

- (void)didSay:(NSString *)text to:(NSString *)recipient fromUser:(NSString *)sender {
    NSString *channel;
    NSString *currentNick = [self getNick];
    
    if ([recipient isEqual:currentNick]) { // private message
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
    
    UserMessage *message = [[UserMessage alloc] initWithText:text user:sender time:[NSDate date]];
    [messages addObject:message];
    [message release];
    
    if ([channel isEqualToString:_currentChannel]) {
        [self.mainView.messageList reloadData];
    } else {
        NSNumber *unreadMessages = [channelData objectForKey:@"unreadMessages"];
        [channelData setObject:[NSNumber numberWithInt:([unreadMessages intValue] + 1)] forKey:@"unreadMessages"];
        [self.mainView.channelList reloadData];
    }
    
    bool appIsInactive = (![NSApp isActive]);
    bool channelIsInactive = (![channel isEqualToString:_currentChannel]);
    bool shouldAlert = ([text rangeOfString:[self getNick]].location != NSNotFound);
    
    if ((appIsInactive || channelIsInactive) && shouldAlert) {
        [self performSelectorOnMainThread:@selector(incrementUnreadAlerts) withObject:nil waitUntilDone:NO];
        
        SEL requestUserAttention = @selector(requestUserAttention:);
        NSRequestUserAttentionType attentionType = NSInformationalRequest;
        
        NSMethodSignature *signature = [NSApplication instanceMethodSignatureForSelector:requestUserAttention];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        
        [invocation setTarget:NSApp];
        [invocation setSelector:requestUserAttention];
        [invocation setArgument:&attentionType atIndex:2];
        
        [invocation performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:NO];
        
        int unreadAlerts = [[channelData objectForKey:@"unreadAlerts"] intValue];
        [channelData setObject:[NSNumber numberWithInt:unreadAlerts + 1] forKey:@"unreadAlerts"];
        
        [self.mainView.channelList reloadData];
    }
}

- (void)didTopic:(NSString *)topic onChannel:(NSString *)channel fromUser:(NSString *)user {
    NSMutableDictionary *channelData = [_serverData objectForKey:channel];
    
    NSMutableArray *messages = [channelData objectForKey:@"messages"];
    
    TopicMessage *message = [[TopicMessage alloc] initWithTopic:topic user:user time:[NSDate date]];
    [messages addObject:message];
    [message release];
    
    [channelData setObject:topic forKey:@"topic"];
    
    if ([channel isEqual:_currentChannel]) {
        [self.mainView.messageList reloadData];
        [self updateWindowTitle];
    }
}

- (void)didNames:(NSArray *)names forChannel:(NSString *)channel {
    NSMutableArray *users = [[_serverData objectForKey:channel] objectForKey:@"users"];
    
    [users addObjectsFromArray:names];
    
    if ([channel isEqual:_currentChannel]) {
        [self.mainView.userList reloadData];
    }
}

- (void)didNick:(NSString *)nick fromUser:(NSString *)user {
    if (_currentChannel != nil) {
        NSMutableDictionary *channel = [_serverData objectForKey:_currentChannel];
        NSMutableArray *messages = [channel objectForKey:@"messages"];
        NSMutableArray *users = [channel objectForKey:@"users"];

        [users removeObject:user];
        if ([nick isEqual:[_server getNick]]) {
            [users insertObject:nick atIndex:0];
        } else {
            [users addObject:nick];            
        }
        
        NickMessage *message = [[NickMessage alloc] initWithOldNick:user newNick:nick time:[NSDate date]];
        [messages addObject:message];
        [message release];
        
        [self.mainView.messageList reloadData];
        [self.mainView.userList reloadData];
    }
}

- (void)didNickInUse:(NSString *)nick {
    if (_currentChannel != nil) {
        NSMutableArray *messages = [[_serverData objectForKey:_currentChannel] objectForKey:@"messages"];

        NickInUseMessage *message = [[NickInUseMessage alloc] initWithInUseNick:nick time:[NSDate date]];
        [messages addObject:message];
        [message release];
        
        [self.mainView.messageList reloadData];
    }
}

#pragma mark -
#pragma mark Private methods

- (NSMutableDictionary *)loadChannel:(NSString *)channel {
    NSMutableArray *messages = [[NSMutableArray alloc] initWithCapacity:10];
    NSMutableArray *users = [[NSMutableArray alloc] initWithCapacity:10];
    
    NSMutableDictionary *channelData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        messages, @"messages",
                                        users, @"users",
                                        [NSNumber numberWithInt:0], @"unreadMessages",
                                        [NSNumber numberWithInt:0], @"unreadAlerts",
                                        nil];
    [messages release];
    [users release];
    
    [_serverData setObject:channelData forKey:channel];
    
    return channelData;
}

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
