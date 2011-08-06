//
//  User.h
//  erk
//
//  Created by Vernon Thommeret on 8/6/11.
//  Copyright (c) 2011 Allergic Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Channel;

@interface User : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * modes;
@property (nonatomic, retain) Channel * channel;

@end
