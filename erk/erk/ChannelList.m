//
//  ChannelList.m
//  erk
//
//  Created by Vernon Thommeret on 7/3/11.
//  Copyright 2011 Allergic Studios. All rights reserved.
//

#import "ChannelList.h"
#import "MainView.h"
#import "MainTableViewCell.h"
#import "NSInvocation+ForwardedConstruction.h"

@implementation ChannelList

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

- (void)selectRowAtIndexPath:(TUIFastIndexPath *)indexPath {
    [[NSInvocation invokeOnMainThreadWithTarget:self.tableView] selectRowAtIndexPath:indexPath
                                                                            animated:YES
                                                                      scrollPosition:TUITableViewScrollPositionToVisible];
}

#pragma mark -
#pragma mark Table view delegate methods

- (NSInteger)tableView:(TUITableView *)table numberOfRowsInSection:(NSInteger)section
{
    return [_appDelegate countChannels];
}

- (CGFloat)tableView:(TUITableView *)tableView heightForRowAtIndexPath:(TUIFastIndexPath *)indexPath
{
    return 35.0;
}

- (TUITableViewCell *)tableView:(TUITableView *)tableView cellForRowAtIndexPath:(TUIFastIndexPath *)indexPath
{
    MainView *mainView = (MainView *)tableView.superview;
    MainTableViewCell *cell = reusableTableCellOfClass(tableView, MainTableViewCell);
    
    NSString *channelName = [_appDelegate channelNameForRow:indexPath.row];
    NSMutableDictionary *channelData = [_appDelegate channelDataForName:channelName];
    
    int unreadMessages = [[channelData objectForKey:@"unreadMessages"] intValue];
    int unreadAlerts = [[channelData objectForKey:@"unreadAlerts"] intValue];
    
    NSString *channelText;
    
    if (unreadMessages > 0) {
        channelText = [NSString stringWithFormat:@"%@ (%d)", channelName, unreadMessages];
    } else {
        channelText = channelName;
    }
    
    TUIAttributedString *attributedString = [TUIAttributedString stringWithString:channelText];
    attributedString.font = mainView.mediumFont;
    
    if (unreadAlerts > 0) {
        attributedString.color = [TUIColor purpleColor];
    } else {
        attributedString.color = [TUIColor blackColor];
    }
    
    cell.attributedString = attributedString;
    
    return cell;
}

- (void)tableView:(TUITableView *)tableView didClickRowAtIndexPath:(TUIFastIndexPath *)indexPath withEvent:(NSEvent *)event {
    [_appDelegate setCurrentChannelForRow:indexPath.row];
}

@end
