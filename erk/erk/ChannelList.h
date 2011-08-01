//
//  ChannelList.h
//  erk
//
//  Created by Vernon Thommeret on 7/3/11.
//  Copyright 2011 Allergic Studios. All rights reserved.
//

#import "TUIKit.h"
#import "erkAppDelegate.h"

@interface ChannelList : NSObject <TUITableViewDelegate, TUITableViewDataSource> {
    TUITableView *_tableView;
    erkAppDelegate *_appDelegate;
}

- (id)initWithFrame:(CGRect)b;
- (void)reloadData;
- (void)selectRowAtIndexPath:(TUIFastIndexPath *)indexPath;

@property (nonatomic, retain) TUITableView *tableView;

@end
