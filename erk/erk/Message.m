//
//  Message.m
//  erk
//
//  Created by Vernon Thommeret on 1/24/11.
//  Copyright 2011 Vernon Thommeret. All rights reserved.
//

#import "Message.h"

@implementation Message

- (void)dealloc {
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

@end

@implementation UserMessage

@synthesize text = _text;
@synthesize user = _user;

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
    [_user release];
    [super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ %@: %@", [self getFormattedTime], _user, _text];
}

@end

@implementation TopicMessage

- (id)initWithTopic:(NSString *)topic user:(NSString *)user time:(NSDate *)time {
	if ((self = [super init])) {
		_topic = [topic copy];
		_user = [user copy];
		_time = [time retain];
	}
	return self;
}

- (void)dealloc {
    [_topic release];
    [_user release];
    [super dealloc];
}

- (NSString *)description {
	if (_user == nil) {
		return [NSString stringWithFormat:@"%@ topic: %@", [self getFormattedTime], _topic];
	} else {
		return [NSString stringWithFormat:@"%@ %@ set the topic: %@", [self getFormattedTime], _user, _topic];
	}
}

@end

@implementation JoinMessage

- (id)initWithUser:(NSString *)user time:(NSDate *)time {
    if ((self = [super init])) {
        _user = [user copy];
        _time = [time retain];
    }
    return self;
}

- (void)dealloc {
    [_user release];
    [super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ %@ entered the chat room", [self getFormattedTime], _user];
}

@end

@implementation PartMessage

- (id)initWithUser:(NSString *)user time:(NSDate *)time {
    if ((self = [super init])) {
        _user = [user copy];
        _time = [time retain];
    }
    return self;
}

- (void)dealloc {
    [_user release];
    [super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ %@ left the chat room", [self getFormattedTime], _user];
}

@end

@implementation NickMessage

- (id)initWithOldNick:(NSString *)oldNick newNick:(NSString *)newNick time:(NSDate *)time {
    if ((self = [super init])) {
        _oldNick = [oldNick copy];
        _newNick = [newNick copy];
        _time = [time retain];
    }
    return self;
}

- (void)dealloc {
    [_oldNick release];
    [_newNick release];
    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@ is now known as %@", [self getFormattedTime], _oldNick, _newNick];
}

@end

@implementation ServerMessage
@end

// TODO: Is NickInUseMessage a ServerMessage since it doesn't have text?

@implementation NickInUseMessage

- (id)initWithInUseNick:(NSString *)inUseNick time:(NSDate *)time {
    if ((self = [super init])) {
        _inUseNick = [inUseNick copy];
        _time = [time retain];
    }
    return self;
}

- (void)dealloc {
    [_inUseNick release];
    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ nick is already in use: %@", [self getFormattedTime], _inUseNick];
}

@end