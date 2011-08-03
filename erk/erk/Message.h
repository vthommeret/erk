//
//  Message.h
//  erk
//
//  Created by Vernon Thommeret on 1/24/11.
//  Copyright 2011 Vernon Thommeret. All rights reserved.
//

#import <Foundation/Foundation.h>

// abstract
@interface Message : NSObject {
    NSDate *_time;
}

- (NSString *)getFormattedTime;

@end

@interface UserMessage : Message {
    NSString *_text;
	NSString *_user;
}

@property (nonatomic, readonly) NSString *text;
@property (nonatomic, readonly) NSString *user;

- (id)initWithText:(NSString *)text user:(NSString *)user time:(NSDate *)time;

@end

@interface TopicMessage : Message {
    NSString *_topic;
	NSString *_user;
}

- (id)initWithTopic:(NSString *)text user:(NSString *)user time:(NSDate *)time;

@end

@interface JoinMessage : Message {
	NSString *_user;
}

// needs init and to be implemented

@end

@interface NickMessage : Message {
    NSString *_oldNick;
    NSString *_newNick;
}

- (id)initWithOldNick:(NSString *)oldNick newNick:(NSString *)newNick time:(NSDate *)time;

@end

@interface ServerMessage : Message {
    NSString *_text;
}

// needs init and implementation (possibly)

@end

@interface NickInUseMessage : ServerMessage {
    NSString *_inUseNick;
}

- (id)initWithInUseNick:(NSString *)inUseNick time:(NSDate *)time;

@end