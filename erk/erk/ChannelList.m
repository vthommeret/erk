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
    SEL selectRow = @selector(selectRowAtIndexPath:animated:scrollPosition:);
    
    bool animated = YES;
    TUITableViewScrollPosition scrollPosition = TUITableViewScrollPositionToVisible;
    
    // Agh.. this is messy. Look into http://cocoawithlove.com/2008/03/construct-nsinvocation-for-any-message.html
    // but less hacky, since we'll probably have to do this a lot.
    
    NSMethodSignature *signature = [TUITableView instanceMethodSignatureForSelector:selectRow];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    
    [invocation setTarget:self.tableView];
    [invocation setSelector:selectRow];
    [invocation setArgument:&indexPath atIndex:2];
    [invocation setArgument:&animated atIndex:3];
    [invocation setArgument:&scrollPosition atIndex:4];
    
    [invocation performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:NO];
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
    
    int unread =  [[channelData objectForKey:@"unread"] intValue];
    NSString *channelText;
    
    if (unread > 0) {
        channelText = [NSString stringWithFormat:@"%@ (%d)", channelName, unread];
    } else {
        channelText = channelName;
    }
    
    TUIAttributedString *s = [TUIAttributedString stringWithString:channelText];
    s.color = [TUIColor blackColor];
    s.font = mainView.mediumFont;
    cell.attributedString = s;
    
    return cell;
}

- (void)tableView:(TUITableView *)tableView didClickRowAtIndexPath:(TUIFastIndexPath *)indexPath withEvent:(NSEvent *)event {
    [_appDelegate setCurrentChannelForRow:indexPath.row];
}

@end
