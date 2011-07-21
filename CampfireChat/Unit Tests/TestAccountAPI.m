//
//  TestAccountAPI.m
//  CampfireChat
//
//  Created by Kiel Gillard on 21/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TestAccountAPI.h"
#import "CFCPlugIn.h"

@implementation TestAccountAPI
@synthesize buffer;

- (void)setUp
{
    [super setUp];
    
    continueTest = NO;
    self.buffer = nil;
}

- (void)tearDown
{
    self.buffer = nil;
    continueTest = NO;
    
    [super tearDown];
}

- (void)testRequestingAccount
{
    CFCPlugIn *p = [[CFCPlugIn alloc] initWithServiceApplication:nil];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", p.server, @"account.json"]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:[NSString stringWithFormat:@"%@:%@", p.authenticationToken, @"X"] forHTTPHeaderField:@"Authorization"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
    while (!continueTest && [[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
    
    [p release];
    [request release];
    [connection release];
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    
}

- (NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request
{
    return nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSMutableData *b = self.buffer;
    
    if (b) {
        
        [b appendData:data];
        
    } else {
        
        b = [data mutableCopy];
        self.buffer = b;
        [b release];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *text = [[NSString alloc] initWithData:self.buffer encoding:NSUTF8StringEncoding];
    NSLog(@"text = %@", text);
    [text release];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
}

@end
