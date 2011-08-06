//
//  Server.h
//  erk
//
//  Created by Vernon Thommeret on 8/6/11.
//  Copyright (c) 2011 Allergic Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Channel;

@interface Server : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * port;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * login_name;
@property (nonatomic, retain) NSString * real_name;
@property (nonatomic, retain) NSString * serverPass;
@property (nonatomic, retain) NSSet* channels;

@end
