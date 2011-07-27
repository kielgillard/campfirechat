//
//  CFCRequest.h
//  CampfireChat
//
//  Created by Kiel Gillard on 22/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Abstract Campfire API request class. 
 */
@interface CFCRequest : NSObject

- (id)initWithURL:(NSURL *)url;

- (id)initWithRequest:(NSURLRequest *)request;

- (void)begin;

- (void)cancel;

@property (nonatomic, copy) void(^completion)(id json, NSError *error);             /**< Invoked when request completes, passing nil for json if an error occured. */
@end
