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
    
//    NSURL *url = [NSURL URLWithString:@"https://2377aee6086c61880586396725fc1a394ad69571:X@ko.campfirenow.com/room/314457.json"];
    NSURL *url = [NSURL URLWithString:@"https://2377aee6086c61880586396725fc1a394ad69571:X@ko.campfirenow.com/rooms.json"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
    while (!continueTest && [[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
    
    [p release];
    [request release];
    [connection release];
}

//- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
//{
//    
//}

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
    
    continueTest = YES;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *text = [[NSString alloc] initWithData:self.buffer encoding:NSUTF8StringEncoding];
    NSLog(@"text = %@", text);
    
    NSError *error;
    id obj = [NSJSONSerialization JSONObjectWithData:self.buffer options:NSJSONReadingAllowFragments error:&error];
    
    if (obj) {
        
        NSLog(@"%@", obj);
        
    } else {
        NSLog(@"%@", error);
    }
    
    [text release];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
}

@end
