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

- (id)initWithServer:(Server *)server;
- (void)connect;
- (NSString *)nick; // temp

- (void)readCommand:(NSString *)command;

- (NSMutableDictionary *)loadChannel:(NSString *)channel;

@end
