//
//  Channel.m
//  erk
//
//  Created by Vernon Thommeret on 11/20/11.
//  Copyright (c) 2011 Allergic Studios. All rights reserved.
//

#import "Channel.h"
#import "Server.h"

@interface Channel (PrimitiveAccessors)

- (NSNumber *)primitiveAutojoin;
- (void)setPrimitiveAutojoin:(NSNumber *)value;

@end

@implementation Channel

@dynamic modes;
@dynamic unreadCount;
@dynamic topic;
@dynamic autojoin;
@dynamic name;
@dynamic server;
@dynamic messages;
@dynamic users;

// Convenience methods

+ (Channel *)insertChannelInContext:(NSManagedObjectContext *)context {
    Channel *channel = [NSEntityDescription insertNewObjectForEntityForName:@"Channel" inManagedObjectContext:context];
    return channel;
}

+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription entityForName:@"Channel" inManagedObjectContext:context];
}

// Autojoin accessors

- (BOOL)autojoin {
    [self willAccessValueForKey:@"autojoin"];
    BOOL value = [[self primitiveAutojoin] boolValue];
    [self didAccessValueForKey:@"autojoin"];
    return value;
}

- (void)setAutojoin:(BOOL)value {
    [self willChangeValueForKey:@"autojoin"];
    [self setPrimitiveAutojoin:[NSNumber numberWithBool:value]];
    [self didChangeValueForKey:@"autojoin"];
}

@end
