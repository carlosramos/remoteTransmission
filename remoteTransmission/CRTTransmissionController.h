//
//  CRTTransmissionController.h
//  remoteTransmission
//
//  Created by Carlos Ramos on 28/03/14.
//  Copyright (c) 2014 Carlos Ramos González. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRTAuthentication.h"

typedef void(^ServerCallback)(id data, NSError *error);

extern NSString *const CRTTransmissionControllerErrorDomain;
extern const NSInteger CRTTransmissionControllerErrorUnknownStatusCode;
extern const NSInteger CRTTransmissionControllerErrorNotSuccessfulResponse;
extern const NSInteger CRTTransmissionControllerErrorMalformedResponse;

@interface CRTTransmissionController : NSObject <NSURLSessionDelegate, NSURLSessionDataDelegate>
/** Authentication model: contains the username and password. Reads them from user defaults on creation. */
@property (nonatomic, strong) CRTAuthentication *authentication;
/** Session ID. Check transmission RPC documentation for details */
@property (nonatomic, copy) NSString *transmissionSessionID;
/// @name NSURLSession properties.
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSURLSession *session;
/// @name Connection details.
@property (nonatomic, copy) NSString *host;
@property (nonatomic, assign) NSUInteger port;

/** Returns the shared instance of the controller. */
+ (CRTTransmissionController *)sharedController;

/** Sends to the Transmission RPC server the given request.

 The request should be a dictionary built with -createRequestForMethod:withArguments:tag:.
 This method is used by more abstract methods like -torrentList: and -sessionStats:. You should use
 those instead of building the request yourself.
 @param request NSDictionary with keys "method", "arguments" and "tag", 
                as described in Transmission RPC documentation.
 @param callback Block that should be called when the request is done or if there is an error.
 @see -torrentList:
 @see -sessionStats:
 */
- (void)sendRequest:(NSDictionary *)request callback:(ServerCallback)callback;

/** Set the RPC host and port. */
- (void)setHost:(NSString *)host port:(NSUInteger)port;

/** Checks if the user has the BitTorrent protocol port open in the computer with the transmission client.
 @param callback Block called when the response from the server is received. If there is an error, it is returned
                 in the error parameter and the isPortOpen parameter is set to NO. */
- (void)isPortOpen:(void (^)(BOOL isPortOpen, NSError *error))callback;

/** Get the current list of torrents (active or inactive) running on the Transmission client.
 @param callback Block called when the list is obtained. If there is an error, it is returned in the error parameter and
                 the list parameter is set to nil.
 */
- (void)torrentList:(void (^)(NSArray *list, NSError *error))callback;

/** Get various global session statistics, like download/upload speed.
 @param callback Block called when the stats are obtained. If there is an error, it is returned in the error parameter and
                 the stats parameter is set to nil.
 */
- (void)sessionStats:(void (^)(NSDictionary *stats, NSError *error))callback;

/** Gets the current speed limits.
 @param callback Block called when the data is retrieved. downloadLimit and uploadLimit are 0 if there's no
                 limit currently set. If there's an error, it is returned in the error parameter and both
                 downloadLimit and uploadLimit are set to 0.
 */
- (void)getSpeedLimits:(void (^)(long downloadLimit, long uploadLimit, NSError *error))callback;

/** Sets the current speed limits.
 @param downloadLimit The download speed limit, or 0 for unlimited.
 @param uploadLimit The upload speed limit, or 0 for unlimited.
 @param callback Block called when the data is sent to the server. If there's an error, it is returned in the
                 error parameter.
 */
- (void)setDownloadLimit:(long)downloadLimit uploadLimit:(long)uploadLimit withCompletion:(void (^)(NSError *error))callback;

- (void)addTorrent:(NSString *)torrentFilePathOrURL withCompletion:(void (^)(NSError *error))callback;
@end
