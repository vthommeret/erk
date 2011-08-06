//
//  Server.m
//  erk
//
//  Created by Vernon Thommeret on 8/6/11.
//  Copyright (c) 2011 Allergic Studios. All rights reserved.
//

#import "Server.h"
#import "Channel.h"


@implementation Server
@dynamic address;
@dynamic port;
@dynamic nickname;
@dynamic login_name;
@dynamic real_name;
@dynamic serverPass;
@dynamic channels;

- (void)addChannelsObject:(Channel *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"channels" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"channels"] addObject:value];
    [self didChangeValueForKey:@"channels" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeChannelsObject:(Channel *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"channels" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"channels"] removeObject:value];
    [self didChangeValueForKey:@"channels" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addChannels:(NSSet *)value {    
    [self willChangeValueForKey:@"channels" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"channels"] unionSet:value];
    [self didChangeValueForKey:@"channels" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeChannels:(NSSet *)value {
    [self willChangeValueForKey:@"channels" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"channels"] minusSet:value];
    [self didChangeValueForKey:@"channels" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
