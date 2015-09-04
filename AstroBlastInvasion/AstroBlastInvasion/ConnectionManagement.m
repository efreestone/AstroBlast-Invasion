//
//  ConnectionManagement.m
//  AstroBlastInvasion
//
//  Created by Elijah Freestone on 7/9/15.
//  Copyright (c) 2015 Elijah Freestone. All rights reserved.
//

#import "ConnectionManagement.h"

@implementation ConnectionManagement

//Custom method to check internet connection. Moves on to check login if exists
-(BOOL)checkConnection {
    BOOL connectionExists;
    //Check connectivity before sending twitter request. Modified/refactored from Apple example
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus currentNetworkStatus = [networkReachability currentReachabilityStatus];
    //If connection failed
    if (currentNetworkStatus == NotReachable) {
        connectionExists = NO;
        NSLog(@"No Connection from Connection Management!");
    } else {
        connectionExists = YES;
        NSLog(@"Internet Connection Exists from Connection Management.");
    }
    return connectionExists;
} //checkConnection close

@end
