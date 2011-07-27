//
//  CFCRequest.m
//  CampfireChat
//
//  Created by Kiel Gillard on 22/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CFCRequest.h"

@interface CFCRequest ()
@property (nonatomic, retain) NSMutableData *buffer;            /**< What response is appended to. */
@property (nonatomic, retain) NSURLRequest *request;            /**< What to access. */
@property (nonatomic, retain) NSURLConnection *connection;      /**< Responsible for starting receiver's request. */
@end

@implementation CFCRequest
@synthesize completion, request, connection, buffer;

- (id)initWithURL:(NSURL *)url
{
    if ((self = [super init])) {
        self.request = [NSURLRequest requestWithURL:url];
    }
    
    return self;
}

- (id)initWithRequest:(NSURLRequest *)r
{
    if ((self = [super init])) {
        self.request = r;
    }
    
    return self;
}

- (void)dealloc
{
    [connection cancel];
    [connection release];
    [request release];
    [buffer release];
    [completion release];
    
    [super dealloc];
}

- (void)begin
{
    NSURLConnection *c = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:YES];
    self.connection = c;
    [c release];
}

- (void)cancel
{
    [self.connection cancel];
    self.connection = nil;
}

- (void)connection:(NSURLConnection *)c didReceiveData:(NSData *)data
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

- (void)connectionDidFinishLoading:(NSURLConnection *)c
{
    NSError *error;
    id obj = [NSJSONSerialization JSONObjectWithData:self.buffer options:NSJSONReadingAllowFragments error:&error];
    
    if (obj) {
        
        NSLog(@"%s %@", __PRETTY_FUNCTION__, obj);
        self.completion(obj, nil);
        
    } else {
        NSLog(@"%@", error);
        self.completion(nil, error);
    }
}

- (void)connection:(NSURLConnection *)c didFailWithError:(NSError *)error
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
    self.completion(nil, error);
}

@end
