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

#import "ServerController.h"
#import "User.h"

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
        
        [[self usersController] addObserver:self forKeyPath:@"arrangedObjects" options:0 context:nil];
    }
    return self;
}

- (void)dealloc
{
    [_tableView release];
    [super dealloc];
}

- (NSArrayController *)usersController {
    return _appDelegate.activeServerController.usersController;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [_tableView reloadData];
}

- (void)reloadData {
    // shouldn't really be called anymore
    [_appDelegate sortUsers];
    [_tableView reloadData];
}

#pragma mark -
#pragma mark TUITableView methods

- (NSInteger)tableView:(TUITableView *)table numberOfRowsInSection:(NSInteger)section
{
    return [[self usersController].arrangedObjects count];
}

- (CGFloat)tableView:(TUITableView *)tableView heightForRowAtIndexPath:(TUIFastIndexPath *)indexPath
{
	return 35;
}

- (TUITableViewCell *)tableView:(TUITableView *)tableView cellForRowAtIndexPath:(TUIFastIndexPath *)indexPath
{
	MainTableViewCell *cell = reusableTableCellOfClass(tableView, MainTableViewCell);
	
    User *user = [[self usersController].arrangedObjects objectAtIndex:indexPath.row];
    
	TUIAttributedString *s = [TUIAttributedString stringWithString:user.nickname];
	s.color = [TUIColor blackColor];
	s.font = _appDelegate.mediumFont;
	cell.attributedString = s;
	
	return cell;
}

@end
