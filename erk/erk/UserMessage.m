//
//  UserMessage.m
//  erk
//
//  Created by Vernon Thommeret on 11/21/11.
//  Copyright (c) 2011 Allergic Studios. All rights reserved.
//

#import "UserMessage.h"

@implementation UserMessage

@dynamic text;
@dynamic nickname;

// Convenience methods

+ (UserMessage *)insertUserMessageInContext:(NSManagedObjectContext *)context {
    UserMessage *userMessage = [NSEntityDescription insertNewObjectForEntityForName:@"UserMessage" inManagedObjectContext:context];
    userMessage.time = [NSDate date];
    return userMessage;
}

+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription entityForName:@"UserMessage" inManagedObjectContext:context];
}

@end
