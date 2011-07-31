//
//  UserList.m
//  erk
//
//  Created by Vernon Thommeret on 7/4/11.
//  Copyright 2011 Allergic Studios. All rights reserved.
//

#import "UserList.h"
#import "MainView.h"
#import "MainTableViewCell.h"

@implementation UserList

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
	return [_appDelegate countUsers];
}

- (CGFloat)tableView:(TUITableView *)tableView heightForRowAtIndexPath:(TUIFastIndexPath *)indexPath
{
	return 35;
}

- (TUITableViewCell *)tableView:(TUITableView *)tableView cellForRowAtIndexPath:(TUIFastIndexPath *)indexPath
{
    MainView *mainView = (MainView *)tableView.superview;
    
	MainTableViewCell *cell = reusableTableCellOfClass(tableView, MainTableViewCell);
	
    NSString *user = [_appDelegate userForRow:indexPath.row];
    
	TUIAttributedString *s = [TUIAttributedString stringWithString:user];
	s.color = [TUIColor blackColor];
	s.font = mainView.mediumFont;
	cell.attributedString = s;
	
	return cell;
}

@end
