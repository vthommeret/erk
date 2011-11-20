//
//  MessageToolbar.m
//  erk
//
//  Created by Vernon Thommeret on 7/4/11.
//  Copyright 2011 Allergic Studios. All rights reserved.
//

#import "MessageToolbar.h"
#import "MainView.h"
#import "ChannelList.h"
#import "UserList.h"

#define COLUMN_WIDTH    150

@implementation MessageToolbar

@synthesize view = _view;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super init])) {
        _appDelegate = (erkAppDelegate *) [NSApplication sharedApplication].delegate;
        
        TUIView *view = [[TUIView alloc] initWithFrame:frame];
        
        view.drawRect = ^(TUIView *view, CGRect rect) {
            CGRect bounds = view.bounds;
            CGContextRef ctx = TUIGraphicsGetCurrentContext();
            
            // gray gradient
            CGFloat colorA[] = { 0.85, 0.85, 0.85, 1.0 };
            CGFloat colorB[] = { 0.71, 0.71, 0.71, 1.0 };
            CGContextDrawLinearGradientBetweenPoints(ctx, CGPointMake(0, bounds.size.height), colorA, CGPointMake(0, 0), colorB);
            
            // top emboss
            CGContextSetRGBFillColor(ctx, 1, 1, 1, 0.5);
            CGContextFillRect(ctx, CGRectMake(0, bounds.size.height-2, bounds.size.width, 1));
            CGContextSetRGBFillColor(ctx, 0, 0, 0, 0.3);
            CGContextFillRect(ctx, CGRectMake(0, bounds.size.height-1, bounds.size.width, 1));
            
            // separators
            
            MainView *mainView = (MainView *) view.superview;
            ChannelList *channelList = mainView.channelList;
            UserList *userList = mainView.userList;
            
            CGContextSetRGBFillColor(ctx, 0, 0, 0, 0.1);
            CGContextFillRect(ctx, CGRectMake(channelList.tableView.bounds.size.width, 0, 1, bounds.size.height));
            CGContextFillRect(ctx, CGRectMake(userList.tableView.frame.origin.x, 0, 1, bounds.size.height));
        };
        
        // Add message field
        
        CGRect messageFieldFrame = view.bounds;
        messageFieldFrame.size.width -= (2 * COLUMN_WIDTH + 1) + 14;
        messageFieldFrame.size.height -= 16;
        messageFieldFrame.origin.x += (COLUMN_WIDTH + 1) + 7;
        messageFieldFrame.origin.y += 8;
        
        TUITextField *messageField = [[TUITextField alloc] initWithFrame:messageFieldFrame];
        messageField.contentInset = TUIEdgeInsetsMake(5, 5, 0, 0);
        
        messageField.delegate = self;
        [messageField addTarget:self action:@selector(handleReturn:) forControlEvents:TUIControlEventEditingDidEndOnExit];
        
        [view addSubview:messageField];
        [messageField release];
        
        self.view = view;
        [view release];
    }
    return self;
}

- (void)dealloc {
    [_view release];
    [super dealloc];
}

#pragma mark -
#pragma mark Target action methods

- (void)handleReturn:(TUITextField *)field {
    NSString *command = field.text;
    if (![command isEqualToString:@""]) {
        [_appDelegate sendCommand:command];
		field.text = @"";
    }
}

#pragma mark -
#pragma mark Text field delegate methods

- (BOOL)textFieldShouldReturn:(TUITextField *)textField {
    return YES;
}

@end
