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

- (void)reloadData {
    [_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

#pragma mark -
#pragma mark TUITableView methods

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
    
    NSString *messageBody = [[_appDelegate messageForRow:indexPath.row] description];

	TUIAttributedString *attributedString = [TUIAttributedString stringWithString:messageBody];
	attributedString.color = [TUIColor blackColor];
	attributedString.font = mainView.mediumFont;
	cell.attributedString = attributedString;
    
	return cell;
}

@end
