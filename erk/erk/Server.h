//
//  Server.h
//  erk
//
//  Created by Vernon Thommeret on 8/14/11.
//  Copyright (c) 2011 Allergic Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Server : NSManagedObject

@property (nonatomic, assign) NSInteger port;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *realName;
@property (nonatomic, retain) NSString *nickname;
@property (nonatomic, retain) NSString *loginName;
@property (nonatomic, retain) NSString *serverPass;
@property (nonatomic, retain) NSSet *channels;

+ (Server *)insertServerInContext:(NSManagedObjectContext *)context;
+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context;

- (void)addChannel:(NSManagedObject *)value;
- (void)removeChannel:(NSManagedObject *)value;
- (void)addChannels:(NSSet *)value;
- (void)removeChannels:(NSSet *)value;

@end
