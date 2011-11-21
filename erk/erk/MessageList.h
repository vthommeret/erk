//
//  MessageList.h
//  erk
//
//  Created by Vernon Thommeret on 7/4/11.
//  Copyright 2011 Allergic Studios. All rights reserved.
//

#import "TUIKit.h"
#import "erkAppDelegate.h"

@interface MessageList : NSObject <TUITableViewDelegate, TUITableViewDataSource> {
    TUITableView *_tableView;
    erkAppDelegate *_appDelegate;
}

- (id)initWithFrame:(CGRect)b;
- (NSArrayController *)messagesController;

@property (nonatomic, retain) TUITableView *tableView;

@end
