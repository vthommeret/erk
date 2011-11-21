//
//  UserMessage.h
//  erk
//
//  Created by Vernon Thommeret on 11/21/11.
//  Copyright (c) 2011 Allergic Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Message.h"

@interface UserMessage : Message

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *nickname;

+ (UserMessage *)insertUserMessageInContext:(NSManagedObjectContext *)context;

@end
