//
//  IrcServer.h
//  erk
//
//  Created by Vernon Thommeret on 1/16/11.
//  Copyright 2011 Vernon Thommeret. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IRC_LOGGING

#define kAny		@"*"
#define kPass		@"PASS"
#define kNick		@"NICK"
#define kUser		@"USER"
#define kJoin		@"JOIN"
#define kPrivMsg	@"PRIVMSG"
#define kPrivMsg	@"PRIVMSG"
#define kTopic		@"TOPIC"
#define kSay		@"SAY"
#define kMsg        @"MSG"

#define kPing		@"PING"
#define kPong		@"PONG"

#define kWelcome	@"001"
#define kTopicReply	@"332"
#define kNameReply	@"353"

@class GCDAsyncSocket;
@protocol IrcServerDelegate;

@interface IrcServer : NSObject {
	dispatch_queue_t _socketQueue;
	GCDAsyncSocket *_serverSocket;
	BOOL _connected;
	
	NSString *_host;
	NSInteger _port;
	NSString *_nick;
	NSString *_user;
	NSString *_name;
	NSString *_serverPass;
	id<IrcServerDelegate> _delegate;
	
	NSMutableDictionary *_messages;
}

@property (nonatomic, assign) BOOL connected;
@property (nonatomic, copy) NSString *nick;

- (id)initWithHost:(NSString *)host port:(NSInteger)port nick:(NSString *)nick user:(NSString *)user
			  name:(NSString *)name serverPass:(NSString *)serverPass
		  delegate:(id<IrcServerDelegate>)delegate;
- (void)connect;
- (void)readCommand:(NSString *)line fromChannel:(NSString *)channel;
- (void)join:(NSString *)channel;
- (void)privMsg:(NSString *)msg toChannel:(NSString *)channel;
- (void)topic:(NSString *)topic onChannel:(NSString *)channel;
- (void)nick:(NSString *)nick;

- (NSString *)getNick;

- (void)readData;
- (void)writeCommand:(NSString *)command withValue:(NSString *)value;
- (void)writeCommand:(NSString *)command withValues:(NSArray *)values;

@end

#pragma mark -
#pragma mark IrcServerDelegate Protocol

@protocol IrcServerDelegate <NSObject>

@optional

- (void)didConnect;
- (void)didJoin:(NSString *)channel byUser:(NSString *)user;
- (void)didSay:(NSString *)msg to:(NSString *)recipient fromUser:(NSString *)user;
- (void)didTopic:(NSString *)topic onChannel:(NSString *)channel fromUser:(NSString *)user;
- (void)didNames:(NSArray *)names forChannel:(NSString *)channel;
- (void)didNick:(NSString *)nick fromUser:(NSString *)user;

@end