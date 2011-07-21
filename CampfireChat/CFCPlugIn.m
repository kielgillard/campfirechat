//
//  CFCPlugIn.m
//  CampfireChat
//
//  Created by Kiel Gillard on 21/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <IMServicePlugIn/IMServicePlugIn.h>
#import "CFCPlugIn.h"

@implementation CFCPlugIn
@synthesize iChatInterface, server, authenticationToken;

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
        iChatInterface = [serviceApplication retain];
        server = @"https://ko.campfirenow.com/";
        authenticationToken = @"2377aee6086c61880586396725fc1a394ad69571";
    }
    
    return self;
}

- (void)dealloc
{
    [iChatInterface release];
    [authenticationToken release];
    [server release];
    
    [super dealloc];
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
    //port, ssl ignored
    
    //server = https://ko.campfirenow.com/
    self.server = [accountSettings objectForKey:IMAccountSettingServerHost];
    self.authenticationToken = [accountSettings objectForKey:IMAccountSettingPassword];
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
    
}

@end
