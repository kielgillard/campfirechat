//
//  CFCPlugIn.m
//  CampfireChat
//
//  Created by Kiel Gillard on 21/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <IMServicePlugIn/IMServicePlugIn.h>
#import "CFCPlugIn.h"
#import "CFCRequest.h"

@implementation CFCPlugIn
@synthesize iChatInterface, requests, server, authenticationToken, roomsKeyedByIdentifier, roomIdentifiers;

/*!
 @method     initWithServiceApplication:
 
 @discussion iChat calls this method to instantiate your service plug-in.
 
 At instantiation time, you are handed an IMServiceApplication
 which implements the corresponding protocols for each 
 optional protocol that your IMServicePlugIn implements.
 
 @param      serviceApplication  Your service application interface, used
 to communicate upwards to iChat.
 */
- (id)initWithServiceApplication:(id<IMServiceApplication>)serviceApplication
{
    if ((self = [super init])) {
        requests = [[NSMutableSet alloc] initWithCapacity:1];
        iChatInterface = [serviceApplication retain];
    }
    
    return self;
}

- (void)dealloc
{
    [requests release];
    [iChatInterface release];
    [authenticationToken release];
    [server release];
    [roomsKeyedByIdentifier release];
    [roomIdentifiers release];
    
    [super dealloc];
}

- (NSURL *)URLWithCampfirePath:(NSString *)path
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://%@:X%@/%@", self.authenticationToken, self.server, path]];
}

/*!
 @method     updateAccountSettings:
 
 @discussion iChat calls this method on the IMServicePlugIn prior to login
 with the user's account settings.
 
 @param      accountSettings  An NSDictionary containing the account settings.
 
 Common keys:
 IMServerHostAccountSetting     NSString - the server hostname
 IMServerPortAccountSetting     NSNumber - the server port number
 IMLoginHandleAccountSetting    NSString - the login handle to use
 IMPasswordAccountSetting       NSString - the password
 IMUsesSSLAccountSetting        NSNumber - (YES = use SSL, NO = do not use SSL)
 */
- (oneway void) updateAccountSettings:(NSDictionary *)accountSettings
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, accountSettings);
    //port, ssl ignored
    
    //server = https://ko.campfirenow.com/
    self.server = [accountSettings objectForKey:IMAccountSettingServerHost];
    self.authenticationToken = [accountSettings objectForKey:IMAccountSettingLoginHandle];
}


/*!
 @method     login
 
 @discussion iChat calls this method on the IMServicePlugIn instance when the user 
 wishes to log into your service.
 
 iChat will show your service in the "Connecting" state until
 -plugInDidLogIn is called on the service application.
 */
- (oneway void) login
{
    NSURL *url = [self URLWithCampfirePath:@"/rooms.json"];
    NSLog(@"%s %@", __PRETTY_FUNCTION__, url);
    CFCRequest *r = [[CFCRequest alloc] initWithURL:url];
    
    r.completion = ^(id json, NSError *error) {
      
        if (error) {
            
            [self.iChatInterface plugInDidLogOutWithError:error reconnect:NO];
            
        } else {
            
            [self.iChatInterface plugInDidLogIn];
            
            //enumerate the rooms available, 
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                
                NSArray *rooms = [json objectForKey:@"rooms"];
                NSMutableDictionary *keyedRooms = [[NSMutableDictionary alloc] initWithCapacity:[rooms count]];
                NSMutableArray *identifiers = [[NSMutableArray alloc] initWithCapacity:[rooms count]];
                
                for (NSDictionary *room in [json objectForKey:@"rooms"]) {
                    
                    NSString *eyeDee = [[room objectForKey:@"id"] description];
                    NSString *name = [room objectForKey:@"name"];
                    
                    //cache room info conveniently
                    [identifiers addObject:eyeDee];
                    [keyedRooms setObject:room forKey:eyeDee];
                    
                    NSAttributedString *fancyName = [[NSAttributedString alloc] initWithString:name];
                    IMServicePlugInMessage *msg = [[IMServicePlugInMessage alloc] initWithContent:fancyName];
                    
                    //invite user
                    [self.iChatInterface plugInDidReceiveInvitation:msg forChatRoom:eyeDee fromHandle:self.authenticationToken];
                    
                    //clean up
                    [msg release];
                    [fancyName release];
                }
                
                self.roomsKeyedByIdentifier = keyedRooms;
                self.roomIdentifiers = roomIdentifiers;
                
                //forget request
                [self.requests removeObject:r];
            });
        }
    };
    
    [self.requests addObject:r];
    
    [r begin];
    
    [r release];
}


/*!
 @method     logout
 
 @discussion iChat calls this method on the IMServicePlugIn instance when the user 
 wishes to disconnect from your service.
 
 iChat will show your service in the "Disconnecting" state until
 -plugInDidLogOutWithError: is called on the service application.
 */
- (oneway void) logout
{
    [self.iChatInterface plugInDidLogOutWithError:nil reconnect:NO];
}

#pragma mark -
#pragma mark Chat Room
#pragma mark -

/*!
 @method     joinChatRoom:
 
 @discussion iChat calls this method on the IMServicePlugIn instance when the user attempts
 to join a chat room.
 
 To indicate success, -plugInDidJoinChatRoom: should be called by the service plug-in on the
 service application, followed by -handles:didJoinChatRoom: to indicate the current
 chat room member handles.
 
 To indicate failure, -plugInDidLeaveChatRoom:error: should be called by the service plug-in
 with a non-nil error.
 
 This method may also be called by iChat when the user clicks "Accept" to a chat
 room invitation.
 
 @param      roomName  The name of the room which the user wishes to join.
 */
- (oneway void) joinChatRoom:(NSString *)roomName
{
    NSURL *url = [self URLWithCampfirePath:[NSString stringWithFormat:@"/room/%@/join.json", roomName]];
    NSLog(@"%s %@", __PRETTY_FUNCTION__, url);
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [req setHTTPMethod:@"POST"];
    
    CFCRequest *r = [[CFCRequest alloc] initWithRequest:req];
    
    [req release];
    
    r.completion = ^(id json, NSError *error) {
        
        if (error) {
            
            [self.iChatInterface plugInDidLeaveChatRoom:roomName error:error];
            
        } else {
            
            [self requestParticipantsForRoom:roomName];
        }
    };
    
    [self.requests addObject:r];
    
    [r begin];
    
    [r release];
}

- (void)requestParticipantsForRoom:(NSString *)roomName
{
    NSURL *url = [self URLWithCampfirePath:[NSString stringWithFormat:@"/room/%@.json", roomName]];
    NSLog(@"%s %@", __PRETTY_FUNCTION__, url);
    CFCRequest *r = [[CFCRequest alloc] initWithURL:url];
    
    r.completion = ^(id json, NSError *error) {
        
        if (error) {
            
            [self.iChatInterface plugInDidLeaveChatRoom:roomName error:error];
            
        } else {
            
            [self.iChatInterface plugInDidJoinChatRoom:roomName];
            
            //enumerate the rooms available, 
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                
                NSArray *users = [json objectForKey:@"users"];
                NSMutableArray *names = [[NSMutableArray alloc] initWithCapacity:[users count]];
                
                for (NSDictionary *user in users) {
                    [names addObject:[user objectForKey:@"name"]];
                }
                
                [self.iChatInterface handles:names didJoinChatRoom:roomName];
                
                [names release];
                
                //forget request
                [self.requests removeObject:r];
            });
        }
    };
    
    [self.requests addObject:r];
    
    [r begin];
    
    [r release];
}


/*!
 @method     leaveChatRoom:
 
 @discussion iChat calls this method on the IMServicePlugIn instance when the user closes
 the chat room window, or when the service disconnects.
 
 The service plug-in should attempt to cleanly leave the chat room, and then
 call -plugInDidLeaveChatRoom:error: on the service application once the room is left.
 
 @param      roomName  The name of the room which the user wishes to leave.
 */
- (oneway void) leaveChatRoom:(NSString *)roomName
{
    NSURL *url = [self URLWithCampfirePath:[NSString stringWithFormat:@"/room/%@/leave.json", roomName]];
    NSLog(@"%s %@", __PRETTY_FUNCTION__, url);
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [req setHTTPMethod:@"POST"];
    
    CFCRequest *r = [[CFCRequest alloc] initWithRequest:req];
    
    [req release];
    
    r.completion = ^(id json, NSError *error) {
        
        if (error) {
            
            [self.iChatInterface plugInDidLeaveChatRoom:roomName error:error];
            
        } else {
            
            [self.iChatInterface plugInDidLeaveChatRoom:roomName error:nil];
        }
    };
    
    [self.requests addObject:r];
    
    [r begin];
    
    [r release];
}


/*!
 @method     inviteHandles:toChatRoom:withMessage:
 
 @discussion iChat calls this method on the IMServicePlugIn instance when the user 
 invites handles to a specific chatRoom
 
 @param      handles   The handles to invite.
 @param      roomName  The name of the room which the user wishes to leave
 @param      message   The invitation message
 */
- (oneway void) inviteHandles:(NSArray *)handles toChatRoom:(NSString *)roomName withMessage:(IMServicePlugInMessage *)message
{
    
}


/*!
 @method     sendMessage:toChatRoom:
 
 @discussion iChat calls this method on the IMServicePlugIn instance when the user sends
 a message to a chat room.
 
 The service plug-in should use -plugInDidSendMessage:toChatRoom:error: to report 
 delivery of the message.
 
 Some instant messaging services do not report message delivery status of
 messages sent to chat rooms.  Instead, the message is received in a similar
 fashion to other incoming chat room messages.  In this case, the service
 plug-in may choose to reflect successful message delievery status via
 a call to -plugInDidReceiveMessage:forChatRoom:fromHandle:, with the handle
 parameter set to the handle name.
 
 @param      message  The message to send.
 @param      roomName The recipient chat room.
 */
- (oneway void) sendMessage:(IMServicePlugInMessage *)message toChatRoom:(NSString *)roomName
{
    
}


/*!
 @method     declineChatRoomInvitation:
 
 @discussion iChat calls this method on the IMServicePlugIn instance when the user clicks
 the "Decline" button of an incoming chat room invitation.
 
 This method is always called in response to iChat receiving
 -plugInDidReceiveInvitation:forChatRoom:fromHandle: from the service plug-in.
 
 @param      roomName  The name of the room which the user has declined.
 */
- (oneway void) declineChatRoomInvitation:(NSString *)roomName
{
    NSLog(@"Declined %@ => %@", roomName, [self.roomsKeyedByIdentifier objectForKey:roomName]);
}

@end
