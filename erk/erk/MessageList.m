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
#import "Message.h"

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
    [_tableView reloadData];
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
    
    Message *message = [_appDelegate messageForRow:indexPath.row];
    TUIAttributedString *attributedString;
    
    // TODO: Have subclasses of MainTableViewCell that are initialized with different type of messages and do appropriate drawing.
    
    if ([message class] == [UserMessage class]) {
        UserMessage *userMessage = (UserMessage *)message;
        
        NSString *prefix = [NSString stringWithFormat:@"%@ %@: ", [message getFormattedTime], userMessage.user];
        NSString *messageBody = [NSString stringWithFormat:@"%@%@", prefix, userMessage.text];
        
        attributedString = [TUIAttributedString stringWithString:messageBody];
        attributedString.color = [TUIColor blackColor];
        attributedString.font = mainView.mediumFont;
        
        NSString *currentNick = [_appDelegate getNick];
        
        if (userMessage.user != currentNick) {
            NSUInteger start = [prefix length];
            NSUInteger len = [messageBody length];
            
            NSRange checkRange;
            NSRange foundRange;
            
            NSMutableArray *highlightWords = [[_appDelegate highlightWords] mutableCopy];
            [highlightWords addObject:currentNick];
            
            for (NSString *highlightWord in highlightWords) {
                checkRange = NSMakeRange(start, len - start);
                
                while ((foundRange = [messageBody rangeOfString:highlightWord options:NSCaseInsensitiveSearch range:checkRange]).location != NSNotFound) {
                    // TODO: change purpleColor to highlightColor in some decorator class.
                    
                    [attributedString setColor:[TUIColor purpleColor] inRange:foundRange];
                    checkRange = NSMakeRange(foundRange.location + foundRange.length, len - foundRange.location - foundRange.length);
                }
            }
            
            [highlightWords release];
        }
    } else {
        attributedString = [TUIAttributedString stringWithString:[message description]];
        attributedString.color = [TUIColor blackColor];
        attributedString.font = mainView.mediumFont;
    }
    
    cell.attributedString = attributedString;
    
	return cell;
}

@end
