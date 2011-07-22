//
//  Message.h
//  erk
//
//  Created by Vernon Thommeret on 1/24/11.
//  Copyright 2011 Vernon Thommeret. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject <NSCopying> {
	NSString *_text;
	NSString *_user;
	NSDate *_time;
}

- (id)initWithText:(NSString *)text user:(NSString *)user time:(NSDate *)time;
- (NSString *)getFormattedTime;

@end

@interface TopicMessage : Message {}
@end

@interface JoinMessage : Message {}
@end