//
//  WDServer.m
//  PresBrowser
//
//  Created by alex on 2/28/14.
//  Copyright (c) 2014 Oz Michaeli. All rights reserved.
//

#import "WDServer.h"
#import <GCDAsyncUdpSocket.h>

static NSString * const kServerExit = @"EXIT";
static NSString * const kAnnounce = @"HELLO";
static NSString * const kNavigate = @"NAVIGATE";

static NSString * const SERVER = @"192.168.0.200";
static int const PORT = 40450;

@interface WDMessage : NSObject
- (WDMessage*) initWithServer: (WDServer*) server command:(NSString*) command args:(NSArray*) args;
@property (strong, nonatomic) NSUUID *uuid;
@property (strong, nonatomic) NSString *serverName;
@property (strong, nonatomic) NSString *command;
@property (strong, nonatomic) NSArray *args;
@end

@implementation WDMessage : NSObject

+ (WDMessage *)messageFrom: (WDServer*) server command:(NSString*) command{
    return [WDMessage messageFrom:server command:command args: nil];
}
+ (WDMessage *)messageFrom: (WDServer*) server command:(NSString*) command args:(NSArray*) args {
    return [[WDMessage alloc] initWithServer: server command: command args: args];
}

+ (WDMessage *)messageFromData: (NSData*) data{
    char* bytes = (char*)[data bytes];
    long len = [data length];
    NSMutableArray* dataArray = [NSMutableArray array];
    int last = 0;
    for(int i = 0; i<len; i++){
        if(bytes[i] == '\0'){
            NSData *buffer = [NSData dataWithBytes:(bytes + last) length:(i - last)];
            [dataArray addObject: [[NSString alloc] initWithData:buffer encoding:NSUTF8StringEncoding]];
            last = i;
        }
    }
    NSData *buffer = [NSData dataWithBytes:(bytes + last) length:(len - last)];
    [dataArray addObject: [[NSString alloc] initWithData:buffer encoding:NSUTF8StringEncoding]];
    return [[WDMessage alloc] init];
}

- (NSData*) data{
    long arglength = [self.args count];
    NSMutableArray *data = [NSMutableArray arrayWithObjects:@"wd1.0",[self.uuid UUIDString],self.serverName, self.command, arglength, nil];
    
    if(self.args != nil){
        [data addObjectsFromArray:self.args];
    }
    return [[data componentsJoinedByString:@"\t"] dataUsingEncoding:NSUTF8StringEncoding];
}

- (WDMessage*) initWithServer: (WDServer*) server command:(NSString*) command args:(NSArray*) args{
    if(nil != (self = [super init])){
        self.uuid = server.uuid;
        self.command = command;
        self.serverName = server.name;
        self.args = args;
    }
    return self;
}


@end

@implementation WDServer
- (WDServer*) initWithName: (NSString*)name{
    if(nil != (self = [super init])){
        self.uuid = [NSUUID UUID];
        self.name = name;
    }
    return self;
}

- (void) start{
    self.socket = [[GCDAsyncUdpSocket alloc] initWithDelegate: self delegateQueue:dispatch_get_main_queue()];
    NSError *err;
    [self.socket bindToPort:0 error:&err];
    NSLog(@"%@", err);
    [self.socket beginReceiving:&err];
    NSLog(@"%@", err);
    WDMessage *message = [WDMessage messageFrom:self command:kAnnounce];
    [self send: message];
}

-(void) end{
    WDMessage *message = [WDMessage messageFrom: self command: kServerExit];
    [self send: message];
    [self.socket closeAfterSending];
}

- (void) send: (WDMessage*) message{
    NSLog(@"Sending message: %@", [message data]);
    [self.socket sendData: [message data] toHost:SERVER port:PORT withTimeout:10 tag:0];
}

/**
 * Called when the datagram with the given tag has been sent.
 **/
- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    
}

/**
 * Called if an error occurs while trying to send a datagram.
 * This could be due to a timeout, or something more serious such as the data being too large to fit in a sigle packet.
 **/
- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    
}

/**
 * Called when the socket has received the requested datagram.
 *
 * Due to the nature of UDP, you may occasionally receive undesired packets.
 * These may be rogue UDP packets from unknown hosts,
 * or they may be delayed packets arriving after retransmissions have already occurred.
 * It's important these packets are properly ignored, while not interfering with the flow of your implementation.
 * As an aid, this delegate method has a boolean return value.
 * If you ever need to ignore a received packet, simply return NO,
 * and AsyncUdpSocket will continue as if the packet never arrived.
 * That is, the original receive request will still be queued, and will still timeout as usual if a timeout was set.
 * For example, say you requested to receive data, and you set a timeout of 500 milliseconds, using a tag of 15.
 * If rogue data arrives after 250 milliseconds, this delegate method would be invoked, and you could simply return NO.
 * If the expected data then arrives within the next 250 milliseconds,
 * this delegate method will be invoked, with a tag of 15, just as if the rogue data never appeared.
 *
 * Under normal circumstances, you simply return YES from this method.
 **/
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock
     didReceiveData:(NSData *)data
            withTag:(long)tag
           fromHost:(NSString *)host
               port:(UInt16)port{
    NSLog(@"Got raw %@", data);
    WDMessage * message = [WDMessage messageFromData:data];
    if(message == nil){
        return NO;
    }
    NSLog(@"Got %@ from %@", message.command, message.uuid.UUIDString);
    if([message.command isEqualToString:kNavigate]){
        NSLog(@"Navigate %@", [message.args objectAtIndex:0]);
    }
    return YES;
}

/**
 * Called if an error occurs while trying to receive a requested datagram.
 * This is generally due to a timeout, but could potentially be something else if some kind of OS error occurred.
 **/
- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error{
    
}

/**
 * Called when the socket is closed.
 * A socket is only closed if you explicitly call one of the close methods.
 **/
- (void)onUdpSocketDidClose:(AsyncUdpSocket *)sock{
    
}

@end
