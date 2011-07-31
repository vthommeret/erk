//
//  MessageList.m
//  erk
//
//  Created by Vernon Thommeret on 7/4/11.
//  Copyright 2011 Allergic Studios. All rights reserved.
//

#import "MessageList.h"
#import "MainView.h"
#import "MainTableViewCell.h"

#import "ChannelList.h"
#import "UserList.h"

@implementation MessageList

@synthesize tableView = _tableView;

- (id)initWithFrame:(CGRect)b
{
    if ((self = [super init])) {
        _appDelegate = (erkAppDelegate *) [NSApplication sharedApplication].delegate;
        
        TUITableView *tableView = [[TUITableView alloc] initWithFrame:b];
		tableView.dataSource = self;
		tableView.delegate = self;
        
        self.tableView = tableView;
        [tableView release];
    }
    return self;
}

- (void)dealloc
{
    [_tableView release];
    [super dealloc];
}

- (NSInteger)tableView:(TUITableView *)table numberOfRowsInSection:(NSInteger)section
{
	return [_appDelegate countMessages];
}

- (CGFloat)tableView:(TUITableView *)tableView heightForRowAtIndexPath:(TUIFastIndexPath *)indexPath
{
    MainTableViewCell *cell = (MainTableViewCell *) [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return [cell sizeConstrainedToWidth:tableView.bounds.size.width].height + 17;
}

- (TUITableViewCell *)tableView:(TUITableView *)tableView cellForRowAtIndexPath:(TUIFastIndexPath *)indexPath
{
    MainView *mainView = (MainView *)tableView.superview;
    
	MainTableViewCell *cell = reusableTableCellOfClass(tableView, MainTableViewCell);
    
    NSString *messageBody = [_appDelegate messageBodyForRow:indexPath.row];

	TUIAttributedString *s = [TUIAttributedString stringWithString:messageBody];
	s.color = [TUIColor blackColor];
	s.font = mainView.mediumFont;
	cell.attributedString = s;
    
	return cell;
}

@end
