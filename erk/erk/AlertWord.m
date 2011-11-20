//
//  AlertWord.m
//  erk
//
//  Created by Vernon Thommeret on 11/20/11.
//  Copyright (c) 2011 Allergic Studios. All rights reserved.
//

#import "AlertWord.h"
#import "Server.h"

@implementation AlertWord

@dynamic word;
@dynamic server;

// Convenience methods

+ (AlertWord *)insertAlertWordInContext:(NSManagedObjectContext *)context {
    AlertWord *alertWord = [NSEntityDescription insertNewObjectForEntityForName:@"AlertWord" inManagedObjectContext:context];
    return alertWord;
}

+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription entityForName:@"AlertWord" inManagedObjectContext:context];
}

@end
