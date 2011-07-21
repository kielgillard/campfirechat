//
//  TestAccountAPI.h
//  CampfireChat
//
//  Created by Kiel Gillard on 21/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@interface TestAccountAPI : SenTestCase {
    BOOL continueTest;
}

@property (nonatomic, retain) NSMutableData *buffer;
@end
