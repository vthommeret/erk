//
//  TopicMessage.h
//  erk
//
//  Created by Vernon Thommeret on 8/6/11.
//  Copyright (c) 2011 Allergic Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface TopicMessage : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * topic;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSDate * setTime;

@end
