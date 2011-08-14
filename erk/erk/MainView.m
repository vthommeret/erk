//
//  erkAppDelegate.h
//  erk
//
//  Created by Vernon Thommeret on 7/3/11.
//  Copyright 2011 Allergic Studios. All rights reserved.
//

#import "MainView.h"

#import "ChannelList.h"
#import "UserList.h"
#import "MessageList.h"
#import "MessageToolbar.h"

#define COLUMN_WIDTH    150
#define TOOLBAR_HEIGHT  40

@implementation MainView

@synthesize channelList = _channelList;
@synthesize userList = _userList;
@synthesize messageList = _messageList;
@synthesize messageToolbar = _messageToolbar;

@synthesize messageField = _messageField;

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame])) {        
		self.backgroundColor = [TUIColor colorWithWhite:0.9 alpha:1.0];
		
        // Add ChannelList table view
        
		CGRect channelListFrame = self.bounds;
        channelListFrame.size.width = COLUMN_WIDTH;
        channelListFrame.size.height -= TOOLBAR_HEIGHT;
        channelListFrame.origin.y += TOOLBAR_HEIGHT;
		
		ChannelList *channelList = [[ChannelList alloc] initWithFrame:channelListFrame];
        
        channelList.tableView.backgroundColor = [TUIColor colorWithWhite:0.96 alpha:1.0];
        channelList.tableView.autoresizingMask = TUIViewAutoresizingFlexibleHeight | TUIViewAutoresizingFlexibleRightMargin;
		[self addSubview:channelList.tableView];
        
        self.channelList = channelList;
        [channelList release];
        
        // Add MessageList table view
        
        CGRect messageListFrame = self.bounds;
        messageListFrame.size.width = messageListFrame.size.width - (2 * COLUMN_WIDTH) - 2;
        messageListFrame.size.height -= TOOLBAR_HEIGHT;
        messageListFrame.origin.x = COLUMN_WIDTH + 1;
        messageListFrame.origin.y += TOOLBAR_HEIGHT;
        
        MessageList *messageList = [[MessageList alloc] initWithFrame:messageListFrame];
        
        messageList.tableView.backgroundColor = [TUIColor colorWithWhite:0.96 alpha:1.0];
        messageList.tableView.autoresizingMask = TUIViewAutoresizingFlexibleSize;
        [self addSubview:messageList.tableView];
        
        self.messageList = messageList;
        [messageList release];
        
        // Add UserList table view
        
        CGRect userListFrame = self.bounds;
        userListFrame.size.width = COLUMN_WIDTH;
        userListFrame.size.height -= TOOLBAR_HEIGHT;
        userListFrame.origin.x = self.bounds.size.width - COLUMN_WIDTH;
        userListFrame.origin.y += TOOLBAR_HEIGHT;
        
        UserList *userList = [[UserList alloc] initWithFrame:userListFrame];
        
        userList.tableView.backgroundColor = [TUIColor colorWithWhite:0.96 alpha:1.0];
        userList.tableView.autoresizingMask = TUIViewAutoresizingFlexibleHeight | TUIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:userList.tableView];
        
        self.userList = userList;
        [userList release];
        
        // Add MessageToolbar view
        
        CGRect messageToolbarFrame = self.bounds;
        messageToolbarFrame.size.height = TOOLBAR_HEIGHT;
        
        MessageToolbar *messageToolbar = [[MessageToolbar alloc] initWithFrame:messageToolbarFrame];
        
        messageToolbar.view.autoresizingMask = TUIViewAutoresizingFlexibleWidth;
        [self addSubview:messageToolbar.view];
        
        self.messageToolbar = messageToolbar;
        [messageToolbar release];
    }
	return self;
}

- (void)dealloc
{
	[_channelList release];
    [_userList release];
    [_messageList release];
    [_messageToolbar release];
    
    [_messageField release];
    
	[super dealloc];
}

@end
