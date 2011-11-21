//
//  User.h
//  erk
//
//  Created by Vernon Thommeret on 11/21/11.
//  Copyright (c) 2011 Allergic Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Channel;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString *modes;
@property (nonatomic, retain) NSString *nickname;
@property (nonatomic, retain) Channel *channel;

+ (User *)insertUserInContext:(NSManagedObjectContext *)context;
+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context;

@end
