//
//  IrcServer.m
//  erk
//
//  Created by Vernon Thommeret on 1/16/11.
//  Copyright 2011 Vernon Thommeret. All rights reserved.
//

#import "IrcServer.h"
#import "GCDAsyncSocket.h"
#import "NSInvocation+ForwardedConstruction.h"

@implementation IrcServer

@synthesize connected = _connected;
@synthesize nick = _nick;

#pragma mark -
#pragma mark Public methods

- (id)initWithHost:(NSString *)host port:(NSInteger)port serverPass:(NSString *)serverPass
              nick:(NSString *)nick user:(NSString *)user name:(NSString *)name
          userPass:(NSString *)userPass
          delegate:(id<IrcServerDelegate>)delegate {
    
    if ((self = [super init])) {
        _host = [host copy];
        _port = port;
        _serverPass = [serverPass copy];
        _nick = [nick copy];
        _user = [user copy];
        _name = [name copy];
        _userPass = [userPass copy];
        _delegate = delegate;
        _socketQueue = dispatch_queue_create("SocketQueue", NULL);
        _serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_socketQueue];
        _connected = NO;
    }
    return self;
}

- (void)dealloc {
    [_host release];
    [_nick release];
    [_serverPass release];
    [_nick release];
    [_user release];
    [_name release];
    [_userPass release];
    [_serverSocket release];
    [super dealloc];
}

- (void)connect {
    [_serverSocket connectToHost:_host onPort:_port error:nil];
    
    // Tell me what you support.
    [self writeCommand:kCap withValue:@"LS"];
    
    if (_serverPass != nil) {
        [self writeCommand:kPass withValue:_serverPass];
    }
    
    [self writeCommand:kNick withValue:_nick];
    [self writeCommand:kUser withValues:[NSArray arrayWithObjects:_user, kAny, kAny, _name, nil]];
    
    [self readData];
}

- (void)readCommand:(NSString *)line fromChannel:(NSString *)channel {
    if (![line hasPrefix:@"/"]) {
        [self privMsg:line toChannel:channel];
    } else {
        NSArray *parts = [[line substringFromIndex:1] componentsSeparatedByString:@" "];
        NSInteger count = [parts count];

        if (count > 0) {
            NSString *command = [parts objectAtIndex:0];
            if ([command caseInsensitiveCompare:kJoin] == NSOrderedSame) {
                if (count > 1) {
                    [self join: [[parts subarrayWithRange:NSMakeRange(1, count-1)] componentsJoinedByString: @" "]];
                } else {
                    // was a command to join the empty string
                }
            } else if ([command caseInsensitiveCompare:kTopic] == NSOrderedSame) {
                if (count > 1) {
                    [self topic:[[parts subarrayWithRange:NSMakeRange(1, count-1)] componentsJoinedByString: @" "] onChannel:channel];
                } else {
                    [self topic:nil onChannel:channel];
                }
            } else if ([command caseInsensitiveCompare:kSay] == NSOrderedSame) {
                if (count > 1) {
                    [self privMsg:[[parts subarrayWithRange:NSMakeRange(1, count-1)] componentsJoinedByString: @" "] toChannel:channel];
                } else {
                    // said empty string
                }
            } else if ([command caseInsensitiveCompare:kNick] == NSOrderedSame) {
                if (count > 1) {
                    [self nick:[[parts subarrayWithRange:NSMakeRange(1, count-1)] componentsJoinedByString: @" "]];
                } else {
                    // changed nick to empty string
                }
            } else if ([command caseInsensitiveCompare:kMsg] == NSOrderedSame) {
                if (count > 1) {
                    if (count > 2) {
                        [self privMsg:[[parts subarrayWithRange:NSMakeRange(2, count-2)] componentsJoinedByString: @" "] toChannel:[parts objectAtIndex:1]];
                    } else {
                        // said empty string to person/channel
                    }
                } else {
                    // said empty string to the empty string channel
                }
            } else if ([command caseInsensitiveCompare:kPart] == NSOrderedSame) {
                if (count > 1) {
                    // use specified channels to leave
                    [self partWithChannels:[parts subarrayWithRange:NSMakeRange(1, count-1)]];
                } else {
                    // no channels specified to leave
                    NSString *currentChannel = [_delegate getCurrentChannel];
                    if (currentChannel != nil) {
                        [self partWithChannels:[NSArray arrayWithObject:currentChannel]];
                    } else {
                        // not in a channel, so nothing to leave
                    }
                }
            }
        } else {
            // was an empty string command
        }
    }
}

- (void)join:(NSString *)channel {
    [self writeCommand:kJoin withValue:channel];
}

- (void)privMsg:(NSString *)msg toChannel:(NSString *)channel {
    [self writeCommand:kPrivMsg withValues:[NSArray arrayWithObjects:channel, msg, nil]];
    
    if ([_delegate respondsToSelector:@selector(didSay:to:fromUser:)]) {
        [[NSInvocation invokeOnMainThreadWithTarget:_delegate]
            didSay:[NSString stringWithString:msg] to:[NSString stringWithString:channel] fromUser:[NSString stringWithString:_nick]];
    }
}

- (void)nick:(NSString *)nick {
    [self writeCommand:kNick withValue:nick];
}

- (void)topic:(NSString *)topic onChannel:(NSString *)channel {
    [self writeCommand:kTopic withValues:[NSArray arrayWithObjects:channel, topic, nil]];
}

- (void)partWithChannels:(NSArray *)channels {
    [self writeCommand:kPart withValue:[channels componentsJoinedByString:@","]];
}

- (void)requestCapability:(NSString *)capability {
    [self writeCommand:kCap withValues:[NSArray arrayWithObjects:@"REQ", capability, nil]];
}

- (void)cancelCapability {
    [self writeCommand:kCap withValue:@"END"];
}

- (void)authenticate:(NSString *)data {
    [self writeCommand:kAuthenticate withValue:data];
}

- (NSString *)nick {
    return _nick;
}

- (NSString *)userPass {
    return _userPass;
}

#pragma mark -
#pragma mark Private methods

- (void)readData {
    [_serverSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
}

- (void)writeCommand:(NSString *)command withValue:(NSString *)value {
    [self writeCommand:command withValues:[NSArray arrayWithObject:value]];
}

- (void)writeCommand:(NSString *)command withValues:(NSArray *)values {
    NSMutableArray *mutableValues = [values mutableCopy];
    NSString *trailing = [mutableValues lastObject];
    [mutableValues removeLastObject];
    [mutableValues addObject:[NSString stringWithFormat:@":%@", trailing]];
    
    NSString *data = [[NSString alloc] initWithFormat:@"%@ %@\r\n", command, [mutableValues componentsJoinedByString:@" "]];
    [mutableValues release];
    
#ifdef IRC_LOGGING
    NSLog(@"CLIENT: %@", data);
#endif
    
    [_serverSocket writeData:[data dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1 tag:0];
    [data release];
}

- (NSDictionary *)parsePrefix:(NSString *)prefix {
    NSMutableDictionary *parseDict = [[NSMutableDictionary alloc] initWithCapacity:5];
    
    NSString *name;
    
    NSRange nickRange = [prefix rangeOfString:@"!"];
    if (nickRange.location != NSNotFound) {
        name = [prefix substringToIndex:nickRange.location];
    } else {
        NSRange userRange = [prefix rangeOfString:@"@"];
        if (userRange.location != NSNotFound) {
            name = [prefix substringToIndex:userRange.location];
        } else {
            name = prefix;
        }
    }
    
    [parseDict setObject: name forKey:@"name"];
    
    NSDictionary *returnDict = [[parseDict copy] autorelease];
    [parseDict release];
    
    return returnDict;
}

#pragma mark -
#pragma mark Delegate methods

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *rawLine = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];

    NSRange term = [rawLine rangeOfString:@"\r\n"];
    NSString *line = [rawLine substringToIndex:term.location];
    [rawLine release];
    
#ifdef IRC_LOGGING
        NSLog(@"SERVER: %@", line);
#endif

    if (![line isEqual:@""]) {
        /** parse */
        
        NSDictionary *prefix = nil;
        NSString *command;
        
        NSMutableArray *components = [[line componentsSeparatedByString:@" "] mutableCopy];
        
        // grab prefix
        
        if ([line hasPrefix:@":"]) {
            NSString *prefixString = [[components objectAtIndex:0] substringFromIndex:1];
            prefix = [self parsePrefix:prefixString];
            [components removeObjectAtIndex:0];
        }
        
        NSString *params = [components componentsJoinedByString:@" "];
        [components release];
        
        // grab params
        
        NSMutableArray *paramsArray;
        NSRange trailingDelimiter = [params rangeOfString:@" :"];
        if (trailingDelimiter.location != NSNotFound) {
            NSString *initial = [params substringToIndex:trailingDelimiter.location];
            NSString *trailing = [params substringFromIndex:trailingDelimiter.location + 2];
            paramsArray = [[initial componentsSeparatedByString:@" "] mutableCopy];
            [paramsArray addObject:trailing];
        } else {
            paramsArray = [[params componentsSeparatedByString:@" "] mutableCopy];
        }

        // grab command
        
        command = [paramsArray objectAtIndex:0];
        [paramsArray removeObjectAtIndex:0];
        
        /** handle */
        
        // ping -> pong
        if ([command isEqualToString:kPing]) {
            [self writeCommand:kPong withValue:[paramsArray objectAtIndex:0]];
        }
        
        // welcome -> didConnect
        else if ([command isEqualToString:kWelcome] && [_delegate respondsToSelector:@selector(didConnect)]) {
            _connected = YES;
            [[NSInvocation invokeOnMainThreadWithTarget:_delegate] didConnect];
        }
        
        // join -> didJoin
        else if ([command isEqualToString:kJoin] && [_delegate respondsToSelector:@selector(didJoin:byUser:)]) {
            [[NSInvocation invokeOnMainThreadWithTarget:_delegate]
                didJoin:[NSString stringWithString:[paramsArray objectAtIndex:0]]
                 byUser:[NSString stringWithString:[prefix objectForKey:@"name"]]];
        }
        
        // part -> didPart
        else if ([command isEqualToString:kPart] && [_delegate respondsToSelector:@selector(didPart:byUser:)]) {
            [[NSInvocation invokeOnMainThreadWithTarget:_delegate]
                didPart:[NSString stringWithString:[paramsArray objectAtIndex:0]]
                byUser:[NSString stringWithString:[prefix objectForKey:@"name"]]];
        }
        
        // privmsg -> didSay:to:fromUser
        else if ([command isEqualToString:kPrivMsg]) {
            NSString *displayName = [prefix objectForKey:@"name"];
            NSString *msg = [paramsArray objectAtIndex:1];
            NSString *recipient = [paramsArray objectAtIndex:0];
            
            if ([_delegate respondsToSelector:@selector(didSay:to:fromUser:)]) {
                [[NSInvocation invokeOnMainThreadWithTarget:_delegate]
                    didSay:[NSString stringWithString:msg]
                        to:[NSString stringWithString:recipient]
                  fromUser:[NSString stringWithString:displayName]];
            }
        }
        
        // topic -> didTopic:onChannel:fromUser
        else if ([command isEqualToString:kTopic]) {
            NSString *topic = [paramsArray objectAtIndex:1];
            NSString *channel = [paramsArray objectAtIndex:0];
            NSString *user = [prefix objectForKey:@"name"];
            
            if ([_delegate respondsToSelector:@selector(didTopic:onChannel:fromUser:)]) {
                [[NSInvocation invokeOnMainThreadWithTarget:_delegate]
                    didTopic:[NSString stringWithString:topic]
                   onChannel:[NSString stringWithString:channel]
                    fromUser:[NSString stringWithString:user]];
            }
        }
        
        // name -> didNames:forChannel
        else if ([command isEqualToString:kNameReply]) {
            NSString *channel = [paramsArray objectAtIndex:([paramsArray count] - 2)];
            NSString *namesString = [[paramsArray lastObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSArray *names = [namesString componentsSeparatedByString:@" "];
            
            if ([_delegate respondsToSelector:@selector(didNames:forChannel:)]) {
                [[NSInvocation invokeOnMainThreadWithTarget:_delegate]
                    didNames:[NSArray arrayWithArray:names]
                  forChannel:[NSString stringWithString:channel]];
            }
        }
        
        // topic from joining
        else if ([command isEqualToString:kTopicReply] ){
            NSString *topic = [paramsArray lastObject];
            NSString *channel = [paramsArray objectAtIndex:([paramsArray count] - 2)];
            
            if ([_delegate respondsToSelector:@selector(didTopic:onChannel:fromUser:)]) {
                [[NSInvocation invokeOnMainThreadWithTarget:_delegate]
                    didTopic:[NSString stringWithString:topic]
                   onChannel:[NSString stringWithString:channel]
                    fromUser:nil];
            }
        }
        
        else if ([command isEqualToString:kNick] ){
            NSString *oldNick = [prefix objectForKey:@"name"];
            NSString *nick = [paramsArray objectAtIndex:0];
            
            if ([self.nick isEqualToString:oldNick]) {
                self.nick = nick;
            }
            
            if ([_delegate respondsToSelector:@selector(didNick:fromUser:)]) {
                [[NSInvocation invokeOnMainThreadWithTarget:_delegate]
                    didNick:[NSString stringWithString:nick]
                   fromUser:[NSString stringWithString:oldNick]];
            }

        }
        
        else if ([command isEqualToString:kNickInUse]) {
            NSString *inUseNick = [paramsArray objectAtIndex:1];
            
            if ([_delegate respondsToSelector:@selector(didNickInUse:)]) {
                [[NSInvocation invokeOnMainThreadWithTarget:_delegate]
                    didNickInUse:[NSString stringWithString:inUseNick]];
            }
        }
        
        else if ([command isEqualToString:kCap]) {
            if ([paramsArray count] >= 3) {
                NSString *subcommand = [paramsArray objectAtIndex:1];
                NSArray *capabilities = [[paramsArray objectAtIndex:2] componentsSeparatedByString:@" "];
                
                if ([_delegate respondsToSelector:@selector(didCapWithSubcommand:capabilities:)]) {
                    [[NSInvocation invokeOnMainThreadWithTarget:_delegate]
                     didCapWithSubcommand:[NSString stringWithString:subcommand] capabilities:[NSArray arrayWithArray:capabilities]];
                }
            }
        }
        
        else if ([command isEqualToString:kAuthenticate]) {
            if ([paramsArray count] >= 1) {
                NSString *type = [paramsArray objectAtIndex:0];
                
                if ([_delegate respondsToSelector:@selector(didAuthenticate:)]) {
                    [[NSInvocation invokeOnMainThreadWithTarget:_delegate] didAuthenticate:[NSString stringWithString:type]];
                }
            }
        }
        
        [paramsArray release];
    }

    [self readData];
}

@end
