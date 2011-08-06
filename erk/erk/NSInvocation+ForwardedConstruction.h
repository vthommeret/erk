//
//  NSInvocation(ForwardedConstruction).h
//
//  Created by Matt Gallagher on 19/03/07.
//  Copyright 2007 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <Cocoa/Cocoa.h>

@interface NSInvocation (ForwardedConstruction)

+ (id)invocationWithTarget:(id)target
             invocationOut:(NSInvocation **)invocationOut
           retainArguments:(BOOL)retain
        invokeOnMainThread:(BOOL)mainThread;
+ (id)invokeOnMainThreadWithTarget:(id)target;

@end
