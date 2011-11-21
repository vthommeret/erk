//
//  Message.m
//  erk
//
//  Created by Vernon Thommeret on 11/21/11.
//  Copyright (c) 2011 Allergic Studios. All rights reserved.
//

#import "Message.h"
#import "Channel.h"

@implementation Message

@dynamic time;
@dynamic channel;

+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (NSString *)getFormattedTime {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	[dateFormatter setLocale:[NSLocale currentLocale]];
	
	NSString *formattedTime = [dateFormatter stringFromDate:self.time];
	[dateFormatter release];
	
	return formattedTime;
}

@end
