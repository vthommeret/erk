//
//  Channel.h
//  erk
//
//  Created by Vernon Thommeret on 11/20/11.
//  Copyright (c) 2011 Allergic Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Server;

@interface Channel : NSManagedObject

@property (nonatomic, retain) NSString *modes;
@property (nonatomic, assign) NSInteger unreadCount;
@property (nonatomic, assign) NSInteger unreadAlerts;
@property (nonatomic, retain) NSString *topic;
@property (nonatomic, assign) BOOL autojoin;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) Server *server;
@property (nonatomic, retain) NSManagedObject *messages;
@property (nonatomic, retain) NSManagedObject *users;

+ (Channel *)insertChannelInContext:(NSManagedObjectContext *)context;
+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context;

- (void)addMessage:(NSManagedObject *)value;
- (void)removeMessage:(NSManagedObject *)value;
- (void)addMessages:(NSSet *)value;
- (void)removeMessages:(NSSet *)value;

- (void)addUser:(NSManagedObject *)value;
- (void)removeUser:(NSManagedObject *)value;
- (void)addUsers:(NSSet *)value;
- (void)removeUsers:(NSSet *)value;

@end
