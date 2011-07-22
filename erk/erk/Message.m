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
	NSString *description = [[NSString alloc] initWithFormat:@"%@ %@: %@", [self getFormattedTime], _user, _text];
	return [description autorelease];
}

- (id)copyWithZone:(NSZone *)zone {
	Message *message = [[Message allocWithZone:zone] initWithText:_text user:_user time:_time];
	return message;
}

@end

@implementation TopicMessage

- (NSString *)description {
	NSString *description;
	if (_user == nil) {
		description = [[NSString alloc] initWithFormat:@"%@ topic: %@", [self getFormattedTime], _text];
	} else {
		description = [[NSString alloc] initWithFormat:@"%@ %@ set the topic: %@", [self getFormattedTime], _user, _text];
	}
	return [description autorelease];
}

@end

@implementation JoinMessage

- (NSString *)description {
	NSString *description = [[NSString alloc] initWithFormat:@"%@ %@ entered the chat room", [self getFormattedTime], _user];
	return [description autorelease];
}

@end