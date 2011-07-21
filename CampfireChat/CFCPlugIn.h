//
//  CFCPlugIn.h
//  CampfireChat
//
//  Created by Kiel Gillard on 21/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <IMServicePlugIn/IMServicePlugIn.h>

@interface CFCPlugIn : NSObject <IMServicePlugIn>

@property (nonatomic, retain) id <IMServiceApplication> iChatInterface;     /**< Your service application interface, used to communicate upwards to iChat. */
@property (nonatomic, retain) NSString *server;                             /**< Campfire API endpoint. Typically https://domain.campfirenow.com/ */
@property (nonatomic, retain) NSString *authenticationToken;                /**< Campfire API authentication token obtained from Campfire web site. It is the value of the IMPasswordAccountSetting key. */
@end
