//
//  WDServer.h
//  PresBrowser
//
//  Created by alex on 2/28/14.
//  Copyright (c) 2014 Oz Michaeli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/GCDAsyncUdpSocket.h>

@interface WDServerOld : NSObject <GCDAsyncUdpSocketDelegate>
-(WDServerOld*) initWithName: (NSString*)name;
-(void) start;
-(void) end;
@property (strong, nonatomic) GCDAsyncUdpSocket *socket;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSUUID *uuid;
@end
