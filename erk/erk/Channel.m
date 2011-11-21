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

- (NSNumber *)primitiveUnreadCount;
- (void)setPrimitiveUnreadCount:(NSNumber *)value;

- (NSNumber *)primitiveUnreadAlerts;
- (void)setPrimitiveUnreadAlerts:(NSNumber *)value;

- (NSNumber *)primitiveAutojoin;
- (void)setPrimitiveAutojoin:(NSNumber *)value;

- (NSMutableSet *)primitiveMessages;

- (NSMutableSet *)primitiveUsers;

@end

@implementation Channel

@dynamic modes;
@dynamic unreadCount;
@dynamic unreadAlerts;
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

// unreadCount accessors

- (NSInteger)unreadCount {
    [self willAccessValueForKey:@"unreadCount"];
    NSInteger value = [[self primitiveUnreadCount] integerValue];
    [self didAccessValueForKey:@"unreadCount"];
    return value;
}

- (void)setUnreadCount:(NSInteger)value {
    [self willChangeValueForKey:@"unreadCount"];
    [self setPrimitiveUnreadCount:[NSNumber numberWithInteger:value]];
    [self didChangeValueForKey:@"unreadCount"];
}

// unreadAlerts accessors

- (NSInteger)unreadAlerts {
    [self willAccessValueForKey:@"unreadAlerts"];
    NSInteger value = [[self primitiveUnreadAlerts] integerValue];
    [self didAccessValueForKey:@"unreadAlerts"];
    return value;
}

- (void)setUnreadAlerts:(NSInteger)value {
    [self willChangeValueForKey:@"unreadAlerts"];
    [self setPrimitiveUnreadAlerts:[NSNumber numberWithInteger:value]];
    [self didChangeValueForKey:@"unreadAlerts"];
}

// autojoin accessors

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

// message object methods

- (void)addMessage:(NSManagedObject *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self addMessages:changedObjects];
    [changedObjects release];
}

- (void)removeMessage:(NSManagedObject *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self removeMessages:changedObjects];
    [changedObjects release];
}

- (void)addMessages:(NSSet *)value {
    [self willChangeValueForKey:@"messages" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveMessages] unionSet:value];
    [self didChangeValueForKey:@"messages" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeMessages:(NSSet *)value {
    [self willChangeValueForKey:@"messages" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveMessages] minusSet:value];
    [self didChangeValueForKey:@"messages" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

// user object methods

- (void)addUser:(NSManagedObject *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self addUsers:changedObjects];
    [changedObjects release];
}

- (void)removeUser:(NSManagedObject *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self removeUsers:changedObjects];
    [changedObjects release];
}

- (void)addUsers:(NSSet *)value {
    [self willChangeValueForKey:@"users" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveUsers] unionSet:value];
    [self didChangeValueForKey:@"users" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeUsers:(NSSet *)value {
    [self willChangeValueForKey:@"users" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveUsers] minusSet:value];
    [self didChangeValueForKey:@"users" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

@end
