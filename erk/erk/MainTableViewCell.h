//
//  erkAppDelegate.h
//  erk
//
//  Created by Vernon Thommeret on 7/3/11.
//  Copyright 2011 Allergic Studios. All rights reserved.
//

#import "TUIKit.h"

@interface MainTableViewCell : TUITableViewCell
{
	TUITextRenderer *textRenderer;
}

@property (nonatomic, copy) NSAttributedString *attributedString;

- (CGSize)sizeConstrainedToWidth:(CGFloat)width;

@end
