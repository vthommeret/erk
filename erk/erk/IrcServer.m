//
//  IrcServer.m
//  erk
//
//  Created by Vernon Thommeret on 1/16/11.
//  Copyright 2011 Vernon Thommeret. All rights reserved.
//

#import "IrcServer.h"
#import "GCDAsyncSocket.h"

@implementation IrcServer

@synthesize connected = _connected;
@synthesize nick = _nick;

#pragma mark -
#pragma mark Public methods

- (id)initWithHost:(NSString *)host port:(NSInteger)port nick:(NSString *)nick user:(NSString *)user
              name:(NSString *)name serverPass:(NSString *)serverPass
          delegate:(id<IrcServerDelegate>)delegate {
    if ((self = [super init])) {
        _host = [host copy];
        _port = port;
        _nick = [nick copy];
        _user = [user copy];
        _name = [name copy];
        _serverPass = [serverPass copy];
        _delegate = delegate;
        _socketQueue = dispatch_queue_create("SocketQueue", NULL);
        _serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_socketQueue];
        _connected = NO;
        
        _messages = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    return self;
}

- (void)dealloc {
    [_host dealloc];
    [_nick dealloc];
    [_user dealloc];
    [_serverPass dealloc];
    [_serverSocket dealloc];
    [super dealloc];
}

- (void)connect {
    [_serverSocket connectToHost:_host onPort:_port error:nil];
    [self writeCommand:kPass withValue:_serverPass];
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
                    [self join: [[parts subarrayWithRange:(NSRange){1, count - 1}] componentsJoinedByString: @" "]];
                } else {
                    // was a command to join the empty string
                }
            } else if ([command caseInsensitiveCompare:kTopic] == NSOrderedSame) {
                if (count > 1) {
                    [self topic:[[parts subarrayWithRange:(NSRange){1, count - 1}] componentsJoinedByString: @" "] onChannel:channel];
                } else {
                    [self topic:nil onChannel:channel];
                }
            } else if ([command caseInsensitiveCompare:kSay] == NSOrderedSame) {
                if (count > 1) {
                    [self privMsg:[[parts subarrayWithRange:(NSRange){1, count - 1}] componentsJoinedByString: @" "] toChannel:channel];
                } else {
                    // said empty string
                }
            } else if ([command caseInsensitiveCompare:kNick] == NSOrderedSame) {
                if (count > 1) {
                    [self nick:[[parts subarrayWithRange:(NSRange){1, count - 1}] componentsJoinedByString: @" "]];
                } else {
                    // changed nick to empty string
                }
            } else if ([command caseInsensitiveCompare:kMsg] == NSOrderedSame) {
                if (count > 1) {
                    if (count > 2) {
                        [self privMsg:[[parts subarrayWithRange:(NSRange){2, count - 2}] componentsJoinedByString: @" "] toChannel:[parts objectAtIndex:1]];
                    } else {
                        // said empty string to person/channel
                    }
                } else {
                    // said empty string to the empty string channel
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
        [_delegate didSay:msg to:channel fromUser:_nick];
    }
}

- (void)nick:(NSString *)nick {
    [self writeCommand:kNick withValue:nick];
}

- (void)topic:(NSString *)topic onChannel:(NSString *)channel {
    [self writeCommand:kTopic withValues:[NSArray arrayWithObjects:channel, topic, nil]];
}

- (NSString *)getNick {
    return _nick;
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
            [_delegate didConnect];
        }
        
        // join -> didJoin
        else if ([command isEqualToString:kJoin] && [_delegate respondsToSelector:@selector(didJoin:byUser:)]) {
            [_delegate didJoin:[paramsArray objectAtIndex:0] byUser:[prefix objectForKey:@"name"]];
        }
        
        // part -> didPart
        else if ([command isEqualToString:kPart] && [_delegate respondsToSelector:@selector(didPart:byUser:)]) {
            [_delegate didPart:[paramsArray objectAtIndex:0] byUser:[prefix objectForKey:@"name"]];
        }
        
        // privmsg -> didSay:to:fromUser
        else if ([command isEqualToString:kPrivMsg]) {
            NSString *displayName = [prefix objectForKey:@"name"];
            NSString *msg = [paramsArray objectAtIndex:1];
            NSString *recipient = [paramsArray objectAtIndex:0];
            
            if ([_delegate respondsToSelector:@selector(didSay:to:fromUser:)]) {
                [_delegate didSay:msg to:recipient fromUser:displayName];
            }
        }
        
        // topic -> didTopic:onChannel:fromUser
        else if ([command isEqualToString:kTopic]) {
            NSString *topic = [paramsArray objectAtIndex:1];
            NSString *channel = [paramsArray objectAtIndex:0];
            NSString *user = [prefix objectForKey:@"name"];
            
            if ([_delegate respondsToSelector:@selector(didTopic:onChannel:fromUser:)]) {
                [_delegate didTopic:topic onChannel:channel fromUser:user];
            }
        }
        
        // name -> didNames:forChannel
        else if ([command isEqualToString:kNameReply]) {
            NSString *channel = [paramsArray objectAtIndex:([paramsArray count] - 2)];
            NSString *namesString = [[paramsArray lastObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSArray *names = [namesString componentsSeparatedByString:@" "];
            
            if ([_delegate respondsToSelector:@selector(didNames:forChannel:)]) {
                [_delegate didNames:names forChannel:channel];
            }
        }
        
        // topic from joining
        else if ([command isEqualToString:kTopicReply] ){
            NSString *topic = [paramsArray lastObject];
            NSString *channel = [paramsArray objectAtIndex:([paramsArray count] - 2)];
            
            if ([_delegate respondsToSelector:@selector(didTopic:onChannel:fromUser:)]) {
                [_delegate didTopic:topic onChannel:channel fromUser:nil];
            }
        }
        
        else if ([command isEqualToString:kNick] ){
            NSString *oldNick = [prefix objectForKey:@"name"];
            NSString *nick = [paramsArray objectAtIndex:0];
            
            if ([self.nick isEqualToString:oldNick]) {
                self.nick = nick;
            }
            
            if ([_delegate respondsToSelector:@selector(didNick:fromUser:)]) {
                [_delegate didNick:nick fromUser:oldNick];
            }

        }
        
        else if ([command isEqualToString:kNickInUse]) {
            NSString *inUseNick = [paramsArray objectAtIndex:1];
            
            if ([_delegate respondsToSelector:@selector(didNickInUse:)]) {
                [_delegate didNickInUse:inUseNick];
            }
        }
        
        [paramsArray release];
    }

    [self readData];
}

@end
