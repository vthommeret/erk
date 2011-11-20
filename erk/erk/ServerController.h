//
//  ServerController.h
//  erk
//
//  Created by Vernon Thommeret on 11/20/11.
//  Copyright (c) 2011 Allergic Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IrcConnection.h"

@class IrcConnection;
@class Server;
@class Channel;
@class erkAppDelegate;

@interface ServerController : NSObject <IrcConnectionDelegate> {
    Server *_server;
    IrcConnection *_connection;
    
    NSMutableSet *_autojoinChannels;
    NSMutableDictionary *_data;
    
    Channel *_activeChannel;
    
    erkAppDelegate *_appDelegate;
}

- (id)initWithServer:(Server *)server appDelegate:(erkAppDelegate *)appDelegate;
- (void)connect;

- (void)readCommand:(NSString *)command;

- (NSString *)nick; // temp
- (NSInteger)countChannels; // temp
- (NSString *)channelNameForRow:(NSInteger)row; // temp
- (NSMutableDictionary *)activeChannelData; // temp
- (NSMutableDictionary *)channelDataForName:(NSString *)name; // temp
- (NSString *)activeChannelName; // temp

- (NSMutableDictionary *)loadChannel:(NSString *)channel;

@end
