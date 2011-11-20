//
//  AlertWord.h
//  erk
//
//  Created by Vernon Thommeret on 11/20/11.
//  Copyright (c) 2011 Allergic Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Server;

@interface AlertWord : NSManagedObject

@property (nonatomic, retain) NSString *word;
@property (nonatomic, retain) Server *server;

+ (AlertWord *)insertAlertWordInContext:(NSManagedObjectContext *)context;
+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context;

@end
