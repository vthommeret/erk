//
//  MessageToolbar.h
//  erk
//
//  Created by Vernon Thommeret on 7/4/11.
//  Copyright 2011 Allergic Studios. All rights reserved.
//

#import "TUIKit.h"
#import "erkAppDelegate.h"

@interface MessageToolbar : NSObject <TUITextFieldDelegate> {
    TUIView *_view;
    erkAppDelegate *_appDelegate;
}

@property (nonatomic, retain) TUIView *view;

- (id)initWithFrame:(CGRect)frame;
- (void)handleReturn:(TUITextField *)textField;

@end