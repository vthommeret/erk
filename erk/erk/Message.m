//
//  Message.m
//  erk
//
//  Created by Vernon Thommeret on 1/24/11.
//  Copyright 2011 Vernon Thommeret. All rights reserved.
//

#import "Message.h"

@implementation Message

- (id)initWithText:(NSString *)text user:(NSString *)user time:(NSDate *)time {
	if ((self = [super init])) {
		_text = [text copy];
		_user = [user copy];
		_time = [time retain];
	}
	return self;
}

- (void)dealloc {
	[_text release];
	[_time release];
	[super dealloc];
}

- (NSString *)getFormattedTime {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	[dateFormatter setLocale:[NSLocale currentLocale]];
	
	NSString *formattedTime = [dateFormatter stringFromDate:_time];
	[dateFormatter release];
	
	return formattedTime;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ %@: %@", [self getFormattedTime], _user, _text];
}

- (id)copyWithZone:(NSZone *)zone {
	Message *message = [[Message allocWithZone:zone] initWithText:_text user:_user time:_time];
	return message;
}

@end

@implementation TopicMessage

- (NSString *)description {
	if (_user == nil) {
		return [NSString stringWithFormat:@"%@ topic: %@", [self getFormattedTime], _text];
	} else {
		return [NSString stringWithFormat:@"%@ %@ set the topic: %@", [self getFormattedTime], _user, _text];
	}
}

@end

@implementation JoinMessage

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ %@ entered the chat room", [self getFormattedTime], _user];
}
@end

@implementation NickMessage

- (id)initWithOldNick:(NSString *)oldNick text:(NSString *)text user:(NSString *)user time:(NSDate *)time {
    if ((self = [super initWithText:text user:user time:time])) {
        _oldNick = [oldNick copy];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@ is now known as %@", [self getFormattedTime], _oldNick, _user];
}
@end