//
//  Message.h
//  erk
//
//  Created by Vernon Thommeret on 1/24/11.
//  Copyright 2011 Vernon Thommeret. All rights reserved.
//

#import <Foundation/Foundation.h>

// abstract
@interface OldMessage : NSObject {
    NSDate *_time;
}

- (NSString *)getFormattedTime;

@end

@interface OldUserMessage : OldMessage {
    NSString *_text;
	NSString *_user;
}

@property (nonatomic, readonly) NSString *text;
@property (nonatomic, readonly) NSString *user;

- (id)initWithText:(NSString *)text user:(NSString *)user time:(NSDate *)time;

@end

@interface TopicMessage : OldMessage {
    NSString *_topic;
	NSString *_user;
}

- (id)initWithTopic:(NSString *)text user:(NSString *)user time:(NSDate *)time;

@end

@interface JoinMessage : OldMessage {
	NSString *_user;
}

- (id)initWithUser:(NSString *)user time:(NSDate *)time;

@end

@interface PartMessage : OldMessage {
	NSString *_user;
}

- (id)initWithUser:(NSString *)user time:(NSDate *)time;

@end

@interface NickMessage : OldMessage {
    NSString *_oldNick;
    NSString *_newNick;
}

- (id)initWithOldNick:(NSString *)oldNick newNick:(NSString *)newNick time:(NSDate *)time;

@end

// abstract
@interface ServerMessage : OldMessage {
}

@end

@interface NickInUseMessage : ServerMessage {
    NSString *_inUseNick;
}

- (id)initWithInUseNick:(NSString *)inUseNick time:(NSDate *)time;

@end