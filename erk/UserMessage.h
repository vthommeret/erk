//
//  UserMessage.h
//  erk
//
//  Created by Vernon Thommeret on 8/6/11.
//  Copyright (c) 2011 Allergic Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Message.h"


@interface UserMessage : Message {
@private
}
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * nickname;

@end
