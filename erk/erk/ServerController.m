//
//  ServerController.m
//  erk
//
//  Created by Vernon Thommeret on 11/20/11.
//  Copyright (c) 2011 Allergic Studios. All rights reserved.
//

#import "ServerController.h"

#import "IrcConnection.h"
#import "Server.h"
#import "Channel.h"

#import "Message.h"
#import "User.h"

#import "erkAppDelegate.h"

@implementation ServerController

@synthesize channelsController = _channelsController;
@synthesize usersController = _usersController;

- (id)initWithServer:(Server *)server appDelegate:(erkAppDelegate *)appDelegate {
    if (self = [super init]) {
        _server = [server retain];
        
        // TODO: userPass -> nickpass and loginName -> username
        _connection = [[IrcConnection alloc] initWithHost:_server.address
                                                     port:_server.port
                                               serverPass:_server.serverPass
                                                     nick:_server.nickname
                                                     user:_server.loginName
                                                     name:_server.realName
                                                 userPass:_server.userPass
                                                 delegate:self];
        
        /** Autojoin channels. */
        
        _autojoinChannels = [[NSMutableSet alloc] initWithCapacity:_server.channels.count];
        
        for (Channel *channel in _server.channels) {
            // TODO: Figure out how to set autojoin on save preferences
            // if (channel.autojoin) {
                [_autojoinChannels addObject:channel];
            // }
        }
        
        /** Data. Move this over to Core Data, soon */
        
        _data = [[NSMutableDictionary alloc] initWithCapacity:10];
        
        /** App delegate. Clean up later. */
        
        // If app delegate is unneeded after refactoring... delete it.
        _appDelegate = appDelegate;
        _managedObjectContext = _appDelegate.managedObjectContext;
        
        /** ChannelsArrayController */
        
        NSArrayController *channelsController = [[NSArrayController alloc] init];
        [channelsController bind:@"contentSet" toObject:_server withKeyPath:@"channels" options:nil];
        self.channelsController = channelsController;
        [channelsController release];
        
        /** UsersArrayController */
        
        NSArrayController *usersController = [[NSArrayController alloc] init];
        self.usersController = usersController;
        [usersController release];
    }
    return self;
}

- (void)dealloc {
    [_server release];
    [_autojoinChannels release];
    [_data release];
    [_channelsController release];
    [_usersController release];
    [super dealloc];
}

- (void)connect {
    [_connection connect];
}

- (void)readCommand:(NSString *)command {
    // TODO: _connection.state. connecting, connected, disconnected
    if (_connection.connected && _activeChannel != nil) {
        [_connection readCommand:command fromChannel:_activeChannel.name];
    }
}

#pragma mark -
#pragma mark Legacy methods for refactoring

// temp: return live nickname, rather than stored in model?
- (NSString *)nick {
    return _server.nickname;
}

// temp
- (NSInteger)countChannels {
    return [[_data allKeys] count];
}

// temp
- (NSString *)channelNameForRow:(NSInteger)row {
    return [[_data allKeys] objectAtIndex:row];
}

// temp
- (NSMutableDictionary *)activeChannelData {
    return [self channelDataForName:_activeChannel.name];
}

// temp
- (NSMutableDictionary *)channelDataForName:(NSString *)name {
    return [_data objectForKey:name];
}

// temp
- (NSString *)activeChannelName {
    return _activeChannel.name;
}

#pragma mark -
#pragma mark IrcConnectionDelegate methods

- (void)didConnect {
//    for (Channel *channel in _autojoinChannels) {
//        [_connection join:channel.name];
//    }
    [_connection join:@"#vernonbot2"];
}

// TODO: Encapsulate a lot of this logic into a ChannelController.
- (void)didJoin:(NSString *)channelName byUser:(NSString *)user {
    if ([self channelForName:channelName] == nil) {
        Channel *newChannel = [Channel insertChannelInContext:_appDelegate.managedObjectContext];
        newChannel.name = channelName;
        
        _activeChannel = newChannel;
        
        // Terrible place for this to live... But for now.
        [_usersController bind:@"contentSet" toObject:_activeChannel withKeyPath:@"users" options:nil];
        
        [_server addChannel:newChannel];
    }
    
//    if ([_data objectForKey:channelName] == nil) { // I joined
//        [self loadChannel:channelName];
//        
//        for (Channel *channel in _server.channels) {
//            if ([channel.name isEqualToString:channelName]) {
//                _activeChannel = channel;
//            }
//        }
//        
//        [_appDelegate.mainView.channelList reloadData];
//        [_appDelegate.mainView.messageList reloadData];
//        
//        NSUInteger row = [[_data allKeys] indexOfObject:channelName];
//        TUIFastIndexPath *indexPath = [TUIFastIndexPath indexPathForRow:row inSection:0];
//        
//        [_appDelegate.mainView.channelList selectRowAtIndexPath:indexPath];
//        
//        [_appDelegate updateWindowTitle];
//    } else {
//        NSMutableDictionary *channelData = [_data objectForKey:channelName];
//        
//        NSMutableArray *users = [channelData objectForKey:@"users"];
//        [users addObject:user];
//        
//        NSMutableArray *messages = [channelData objectForKey:@"messages"];
//        
//        JoinMessage *message = [[JoinMessage alloc] initWithUser:user time:[NSDate date]];
//        [messages addObject:message];
//        [message release];
//        
//        if ([channelName isEqualToString:_activeChannel.name]) {
//            [_appDelegate.mainView.messageList reloadData];
//            [_appDelegate.mainView.userList reloadData];
//        }
//    }
}

- (void)didSay:(NSString *)text to:(NSString *)recipient fromUser:(NSString *)sender {
    NSString *channelName;
    
    if ([recipient isEqual:_server.nickname]) { // private message
        channelName = sender;
        return; // not supported yet
    } else { // channel message
        channelName = recipient;
    }
    
    Channel *channel = [self channelForName:channelName];
    channel;
}

- (void)didNames:(NSArray *)names forChannel:(NSString *)channelName {
    Channel *channel = [self channelForName:channelName];
    if (channel != nil) {
        for (NSString *nickname in names) {
            User *user = [User insertUserInContext:_managedObjectContext];
            user.nickname = nickname;
            [channel addUser:user];
        }
    }
}

#pragma mark -
#pragma mark Helper methods

- (Channel *)channelForName:(NSString *)name {
    for (Channel *channel in _server.channels) {
        if ([channel.name isEqualToString:name]) {
            return channel;
        }
    }
    return nil;
}

@end
