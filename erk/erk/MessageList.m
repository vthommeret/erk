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

#import "ServerController.h"
#import "Message.h"
#import "UserMessage.h"

#import "ChannelList.h"
#import "UserList.h"
#import "OldMessage.h"

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
        
        [[self messagesController] addObserver:self forKeyPath:@"arrangedObjects" options:0 context:nil];
    }
    return self;
}

- (void)dealloc
{
    [_tableView release];
    [super dealloc];
}

- (NSArrayController *)messagesController {
    return _appDelegate.activeServerController.messagesController;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    NSLog(@"observing messages: %@ (%@)", object, change);
    
    [_tableView reloadData];
}

#pragma mark -
#pragma mark TUITableView methods

- (NSInteger)tableView:(TUITableView *)table numberOfRowsInSection:(NSInteger)section
{
	return [[self messagesController].arrangedObjects count];
}

- (CGFloat)tableView:(TUITableView *)tableView heightForRowAtIndexPath:(TUIFastIndexPath *)indexPath
{
    MainTableViewCell *cell = (MainTableViewCell *) [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return [cell sizeConstrainedToWidth:tableView.bounds.size.width].height + 17;
}

- (TUITableViewCell *)tableView:(TUITableView *)tableView cellForRowAtIndexPath:(TUIFastIndexPath *)indexPath
{
	MainTableViewCell *cell = reusableTableCellOfClass(tableView, MainTableViewCell);
    
    Message *message = [[self messagesController].arrangedObjects objectAtIndex:indexPath.row];
    
    TUIAttributedString *attributedString;
    
    // TODO: Have subclasses of MainTableViewCell that are initialized with different type of messages and do appropriate drawing.
    
    if ([message class] == [UserMessage class]) {
        UserMessage *userMessage = (UserMessage *) message;
        
        NSString *prefix = [NSString stringWithFormat:@"%@ %@: ", [message getFormattedTime], userMessage.nickname];
        NSString *messageBody = [NSString stringWithFormat:@"%@%@", prefix, userMessage.text];
        
        attributedString = [TUIAttributedString stringWithString:messageBody];
        attributedString.color = [TUIColor blackColor];
        attributedString.font = _appDelegate.mediumFont;
        
        NSString *currentNick = [_appDelegate nick];
        
        if (userMessage.nickname != currentNick) {
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
        attributedString.font = _appDelegate.mediumFont;
    }
    
    cell.attributedString = attributedString;
    
	return cell;
}

@end
