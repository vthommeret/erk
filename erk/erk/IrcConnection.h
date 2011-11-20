//
//  IrcConnection.h
//  erk
//
//  Created by Vernon Thommeret on 1/16/11.
//  Copyright 2011 Vernon Thommeret. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IRC_LOGGING

#define kAny            @"*"
#define kPass           @"PASS"
#define kNick           @"NICK"
#define kUser           @"USER"
#define kJoin           @"JOIN"
#define kPart           @"PART"
#define kPrivMsg        @"PRIVMSG"
#define kTopic          @"TOPIC"
#define kSay            @"SAY"
#define kMsg            @"MSG"
#define kAuthenticate   @"AUTHENTICATE"

#define kPing           @"PING"
#define kPong           @"PONG"
#define kCap            @"CAP"

#define kWelcome        @"001"
#define kTopicReply     @"332"
#define kNameReply      @"353"
#define kNickInUse      @"433"

@class GCDAsyncSocket;
@protocol IrcConnectionDelegate;

@interface IrcConnection : NSObject {
    dispatch_queue_t _socketQueue;
    GCDAsyncSocket *_serverSocket;
    BOOL _connected;
    
    NSString *_host;
    NSInteger _port;
    NSString *_serverPass;
    NSString *_nick;
    NSString *_user;
    NSString *_name;
    NSString *_userPass;
    id<IrcConnectionDelegate> _delegate;
}

@property (nonatomic, assign) BOOL connected;
@property (nonatomic, copy) NSString *nick;

- (id)initWithHost:(NSString *)host port:(NSInteger)port serverPass:(NSString *)serverPass nick:(NSString *)nick user:(NSString *)user
              name:(NSString *)name userPass:(NSString *)userPass
          delegate:(id<IrcConnectionDelegate>)delegate;
- (void)connect;
- (void)readCommand:(NSString *)line fromChannel:(NSString *)channel;
- (void)join:(NSString *)channel;
- (void)privMsg:(NSString *)msg toChannel:(NSString *)channel;
- (void)topic:(NSString *)topic onChannel:(NSString *)channel;
- (void)nick:(NSString *)nick;
- (void)partWithChannels:(NSArray *)channels;
- (void)requestCapability:(NSString *)capability;
- (void)cancelCapability;
- (void)authenticate:(NSString *)data;

- (NSString *)nick;
- (NSString *)userPass;

- (void)readData;
- (void)writeCommand:(NSString *)command withValue:(NSString *)value;
- (void)writeCommand:(NSString *)command withValues:(NSArray *)values;

@end

#pragma mark -
#pragma mark IrcConnectionDelegate Protocol

@protocol IrcConnectionDelegate <NSObject>

@optional

- (void)didConnect;
- (void)didJoin:(NSString *)channel byUser:(NSString *)user;
- (void)didPart:(NSString *)channel byUser:(NSString *)user;
- (void)didSay:(NSString *)msg to:(NSString *)recipient fromUser:(NSString *)user;
- (void)didTopic:(NSString *)topic onChannel:(NSString *)channel fromUser:(NSString *)user;
- (void)didNames:(NSArray *)names forChannel:(NSString *)channel;
- (void)didNick:(NSString *)nick fromUser:(NSString *)user;
- (void)didNickInUse:(NSString *)nick;
- (void)didCapWithSubcommand:(NSString *)subcommand capabilities:(NSArray *)capabilities;
- (void)didAuthenticate:(NSString *)type;

- (NSString *)getCurrentChannel;

@end