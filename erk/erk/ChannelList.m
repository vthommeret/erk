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

#import "ServerController.h"
#import "Server.h"
#import "Channel.h"

@implementation ChannelList

@synthesize tableView = _tableView;

- (id)initWithFrame:(CGRect)b
{
    if ((self = [super init])) {
        _appDelegate = (erkAppDelegate *) [NSApplication sharedApplication].delegate;
        
        TUITableView *tableView = [[TUITableView alloc] initWithFrame:b];
        tableView.dataSource = self;
        tableView.delegate = self;
        
        _tableView = [tableView retain];
        [tableView release];
        
        [[self channelsController] addObserver:self forKeyPath:@"arrangedObjects" options:0 context:nil];
    }
    return self;
}

- (void)dealloc
{
    [_tableView release];
    [super dealloc];
}

- (NSArrayController *)channelsController {
    return _appDelegate.activeServerController.channelsController;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [_tableView reloadData];
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
    return [[self channelsController].arrangedObjects count];
}

- (CGFloat)tableView:(TUITableView *)tableView heightForRowAtIndexPath:(TUIFastIndexPath *)indexPath
{
    return 35.0;
}

- (TUITableViewCell *)tableView:(TUITableView *)tableView cellForRowAtIndexPath:(TUIFastIndexPath *)indexPath
{
    MainTableViewCell *cell = reusableTableCellOfClass(tableView, MainTableViewCell);
    
    Channel *channel = [[self channelsController].arrangedObjects objectAtIndex:indexPath.row];
    
    NSString *channelName = channel.name;
    
    NSInteger unreadMessages = channel.unreadCount;
    NSInteger unreadAlerts = channel.unreadAlerts;

    NSString *channelText;

    if (unreadMessages > 0) {
        channelText = [NSString stringWithFormat:@"%@ (%lu)", channelName, unreadMessages];
    } else {
        channelText = channelName;
    }
    
    TUIAttributedString *attributedString = [TUIAttributedString stringWithString:channelText];
    attributedString.font = _appDelegate.mediumFont;
    
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
