//
//  PreferencesView.m
//  erk
//
//  Created by Vernon Thommeret on 8/13/11.
//  Copyright 2011 Allergic Studios. All rights reserved.
//

#import "PreferencesView.h"


@implementation PreferencesView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [TUIColor colorWithWhite:0.96 alpha:1.0];
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

@end
