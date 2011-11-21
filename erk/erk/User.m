//
//  User.m
//  erk
//
//  Created by Vernon Thommeret on 11/21/11.
//  Copyright (c) 2011 Allergic Studios. All rights reserved.
//

#import "User.h"
#import "Channel.h"

@implementation User

@dynamic modes;
@dynamic nickname;
@dynamic channel;

// Convenience methods

+ (User *)insertUserInContext:(NSManagedObjectContext *)context {
    User *user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
    return user;
}

+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
}

@end
