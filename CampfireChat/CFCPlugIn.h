//
//  CFCPlugIn.h
//  CampfireChat
//
//  Created by Kiel Gillard on 21/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <IMServicePlugIn/IMServicePlugIn.h>

@interface CFCPlugIn : NSObject <IMServicePlugIn, IMServicePlugInChatRoomSupport>

/**
 * Conveniently creates a URL with authentication stuff added.
 * @param path RESTful path to .json.
 * @result URL or nil if path was bogus.
 */
- (NSURL *)URLWithCampfirePath:(NSString *)path;

/**
 * Requests /room/#{id}.json
 * @param String representation of Campfire room id.
 */
- (void)requestParticipantsForRoom:(NSString *)roomName;

@property (nonatomic, retain) id <IMServiceApplication, IMServiceApplicationChatRoomSupport> iChatInterface;     /**< Your service application interface, used to communicate upwards to iChat. */
@property (nonatomic, retain) NSString *server;                             /**< Campfire API endpoint. Typically https://domain.campfirenow.com/ */
@property (nonatomic, retain) NSString *authenticationToken;                /**< Campfire API authentication token obtained from Campfire web site. It is the value of the IMPasswordAccountSetting key. */
@property (nonatomic, retain) NSMutableSet *requests;                       /**< CFCRequest objects currently connecting to the internet. */
@property (nonatomic, retain) NSDictionary *roomsKeyedByIdentifier;                 /**< Cached room info keyed by room ID. */
@property (nonatomic, retain) NSArray *roomIdentifiers;                           /**< Room IDs ordered by creation date or something. */
@end
