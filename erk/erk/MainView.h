//
//  erkAppDelegate.h
//  erk
//
//  Created by Vernon Thommeret on 7/3/11.
//  Copyright 2011 Allergic Studios. All rights reserved.
//

#import "TUIKit.h"

@class ChannelList;
@class UserList;
@class MessageList;
@class MessageToolbar;

@interface MainView : TUIView
{
	ChannelList *_channelList;
    UserList *_userList;
    MessageList *_messageList;
    MessageToolbar *_messageToolbar;
    
    TUITextField *_messageField;
}

@property (nonatomic, retain) ChannelList *channelList;
@property (nonatomic, retain) UserList *userList;
@property (nonatomic, retain) MessageList *messageList;
@property (nonatomic, retain) MessageToolbar *messageToolbar;

@property (nonatomic, retain) TUITextField *messageField;

@end
