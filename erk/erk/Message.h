//
//  Message.h
//  erk
//
//  Created by Vernon Thommeret on 11/21/11.
//  Copyright (c) 2011 Allergic Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Channel;

@interface Message : NSManagedObject

@property (nonatomic, retain) NSDate *time;
@property (nonatomic, retain) Channel *channel;

+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context;

- (NSString *)getFormattedTime;

@end
