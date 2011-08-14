//
//  Server.m
//  erk
//
//  Created by Vernon Thommeret on 8/14/11.
//  Copyright (c) 2011 Allergic Studios. All rights reserved.
//

#import "Server.h"

@interface Server (ServerAccessors)

- (NSNumber *)primitivePort;
- (void)setPrimitivePort:(NSNumber *)port;

- (NSMutableSet *)primitiveChannels;
- (void)setPrimitiveChannels:(NSMutableSet *)channels;

@end

@implementation Server

@dynamic port;
@dynamic address;
@dynamic realName;
@dynamic nickname;
@dynamic loginName;
@dynamic serverPass;
@dynamic channels;

+ (Server *)insertServerInContext:(NSManagedObjectContext *)context {
    Server *server = [NSEntityDescription insertNewObjectForEntityForName:@"Server" inManagedObjectContext:context];
    return server;
}

+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription entityForName:@"Server" inManagedObjectContext:context];
}

#pragma mark -
#pragma mark Port

- (NSInteger)port {
    [self willAccessValueForKey:@"port"];
    NSInteger port = [[self primitivePort] integerValue];
    [self didAccessValueForKey:@"port"];
    return port;
}

- (void)setPort:(NSInteger)port {
    [self willChangeValueForKey:@"port"];
    [self setPrimitivePort:[NSNumber numberWithInteger:port]];
    [self didChangeValueForKey:@"port"];
}

#pragma mark -
#pragma mark Channel objects

- (void)addChannelsObject:(NSManagedObject *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self addChannels:changedObjects];
    [changedObjects release];
}

- (void)removeChannelsObject:(NSManagedObject *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self removeChannels:changedObjects];
    [changedObjects release];
}

- (void)addChannels:(NSSet *)value {
    [self willChangeValueForKey:@"channels" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveChannels] unionSet:value];
    [self didChangeValueForKey:@"channels" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeChannels:(NSSet *)value {
    [self willChangeValueForKey:@"channels" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveChannels] minusSet:value];
    [self didChangeValueForKey:@"channels" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

@end
