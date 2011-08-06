//
//  Channel.h
//  erk
//
//  Created by Vernon Thommeret on 8/6/11.
//  Copyright (c) 2011 Allergic Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Channel : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * unreadCount;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * topic;
@property (nonatomic, retain) NSNumber * autojoin;
@property (nonatomic, retain) NSString * modes;
@property (nonatomic, retain) NSManagedObject * messages;
@property (nonatomic, retain) NSManagedObject * server;
@property (nonatomic, retain) NSManagedObject * users;

@end
