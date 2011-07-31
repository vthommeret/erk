//
//  erkAppDelegate.h
//  erk
//
//  Created by Vernon Thommeret on 7/3/11.
//  Copyright 2011 Allergic Studios. All rights reserved.
//

#import "MainTableViewCell.h"

@implementation MainTableViewCell

- (id)initWithStyle:(TUITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		textRenderer = [[TUITextRenderer alloc] init];
		
		/*
		 Add the text renderer to the view so events get routed to it properly.
		 Text selection, dictionary popup, etc should just work.
		 You can add more than one.
		 
		 The text renderer encapsulates an attributed string and a frame.
		 The attributed string in this case is set by setAttributedString:
		 which is configured by the table view delegate.  The frame needs to be 
		 set before it can be drawn, we do that in drawRect: below.
		 */
		self.textRenderers = [NSArray arrayWithObjects:textRenderer, nil];
	}
	return self;
}

- (void)dealloc
{
	[textRenderer release];
	[super dealloc];
}

- (NSAttributedString *)attributedString
{
	return textRenderer.attributedString;
}

- (void)setAttributedString:(NSAttributedString *)attributedString
{
	textRenderer.attributedString = attributedString;
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
	CGRect b = self.bounds;
    
	CGContextRef ctx = TUIGraphicsGetCurrentContext();
    
	if (self.selected) {
		// selected background
		CGContextSetRGBFillColor(ctx, .87, .87, .87, 1);
		CGContextFillRect(ctx, b);
	} else {
		// light gray background
		CGContextSetRGBFillColor(ctx, .97, .97, .97, 1);
		CGContextFillRect(ctx, b);
		
		// emboss
		CGContextSetRGBFillColor(ctx, 0, 0, 0, 0.08); // dark at the bottom
		CGContextFillRect(ctx, CGRectMake(0, 0, b.size.width, 1));
	}
	
	// text
	CGRect textRect = CGRectOffset(b, 10, -8);
    
	textRenderer.frame = textRect; // set the frame so it knows where to draw itself
	[textRenderer draw];
	
}

- (CGSize)sizeConstrainedToWidth:(CGFloat)width {
    return [textRenderer sizeConstrainedToWidth:width];
}

@end
