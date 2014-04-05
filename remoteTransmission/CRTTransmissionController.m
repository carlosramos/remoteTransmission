//
//  CRTTransmissionController.m
//  remoteTransmission
//
//  Created by Carlos Ramos on 28/03/14.
//  Copyright (c) 2014 Carlos Ramos González. All rights reserved.
//

#import "CRTTransmissionController.h"
#import "NSString+crt_CorrectURLEncoding.h"

NSString *const CRTTransmissionControllerErrorDomain = @"CRTTransmissionControllerErrorDomain";
const NSInteger CRTTransmissionControllerErrorUnknownStatusCode = 1;
const NSInteger CRTTransmissionControllerErrorNotSuccessfulResponse = 2;
const NSInteger CRTTransmissionControllerErrorMalformedResponse = 3;

@implementation CRTTransmissionController 

+ (CRTTransmissionController *)sharedController
{
    static CRTTransmissionController *_controller = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _controller = [[CRTTransmissionController alloc] init];
    });
    return _controller;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        _authentication = [[CRTAuthentication alloc] init];
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 1;     // Serial queue
        _transmissionSessionID = @"nosessionyet";
        
        _session = [NSURLSession sessionWithConfiguration:self.sessionConfiguration delegate:self delegateQueue:self.queue];
        [self readHostPortFromUserDefaults];
    }
    return self;
}


- (void)readHostPortFromUserDefaults
{
    NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"host"];
    NSInteger port = [[NSUserDefaults standardUserDefaults] integerForKey:@"port"];
    NSAssert(port >= 0, @"port can't be zero or negative");
    self.host = str;
    self.port = port;
}


- (void)saveHostPortOnUserDefaults
{
    [[NSUserDefaults standardUserDefaults] setObject:self.host forKey:@"host"];
    [[NSUserDefaults standardUserDefaults] setInteger:self.port forKey:@"port"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)setHost:(NSString *)host port:(NSUInteger)port
{
    self.host = host;
    self.port = port;
    [self saveHostPortOnUserDefaults];
}


- (NSURLSessionConfiguration *)sessionConfiguration
{
    return [NSURLSessionConfiguration defaultSessionConfiguration];
}


- (NSURL *)rpcURL
{
    NSAssert(self.host.length > 0 && self.port > 0, @"host and port must be initialized to use -[rpcURL]");
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%d/transmission/rpc", self.host, self.port]];
}


- (NSDictionary *)createRequestForMethod:(NSString *)method withArguments:(id)args tag:(NSInteger)tag
{
    NSAssert(method != nil, @"method can't be nil");
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    dict[@"method"] = method;
    
    if (args) {
        dict[@"arguments"] = args;
    }
    
    if (tag > 0) {
        dict[@"tag"] = @(tag);
    }
    
    return dict;
}


- (NSURLRequest *)transmissionRequest:(id)data
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.rpcURL];
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:&error];
    if (error) {
        NSLog(@"Error creating JSON serialization of %@", data);
        NSLog(@"Error: %@", error);
        return nil;
    }
    
    if (self.transmissionSessionID) {
        [request addValue:self.transmissionSessionID forHTTPHeaderField:@"x-transmission-session-id"];
    }
    if (self.authentication) {
        NSString *encodedLogin = [self.authentication base64Authentication];
        if (encodedLogin.length > 0) {
            [request addValue:[NSString stringWithFormat:@"Basic %@", encodedLogin] forHTTPHeaderField:@"Authorization"];
        }
    }
    
    [request setHTTPBody:jsonData];
    [request setHTTPMethod:@"POST"];
    
    return request;
}


- (void)torrentList:(void (^)(NSArray *, NSError *))callback
{
    NSDictionary *request = [self createRequestForMethod:@"torrent-get"
                                           withArguments:@{@"fields": @[@"id", @"name", @"totalSize", @"percentDone", @"status"]}
                                                     tag:0];
    [self sendRequest:request callback:^(id data, NSError *error) {
        if (error) {
            callback(nil, error);
            return;
        }
        
        NSDictionary *args = (NSDictionary *)data[@"arguments"];
        if (!args || args[@"torrents"] == nil) {
            callback(nil, [NSError errorWithDomain:CRTTransmissionControllerErrorDomain
                                              code:CRTTransmissionControllerErrorMalformedResponse
                                          userInfo:@{NSLocalizedDescriptionKey: @"Malformed response from server"}]);
            return;
        }
        
        callback(args[@"torrents"], nil);
    }];
}


- (void)sessionStats:(void (^)(NSDictionary *, NSError *))callback
{
    NSDictionary *request = [self createRequestForMethod:@"session-stats"
                                           withArguments:nil
                                                     tag:0];
    [self sendRequest:request callback:^(id data, NSError *error) {
        if (error) {
            callback(nil, error);
            return;
        }
        
        NSDictionary *args = data[@"arguments"];
        if (!args) {
            callback(nil, [NSError errorWithDomain:CRTTransmissionControllerErrorDomain
                                              code:CRTTransmissionControllerErrorMalformedResponse
                                          userInfo:@{NSLocalizedDescriptionKey: @"Malformed response from server"}]);
            return;
        }
        
        callback(args, nil);
    }];
}

- (void)setSessionConfiguration:(NSDictionary *)stats withCompletion:(void (^)(NSError *__autoreleasing))callback
{
    NSDictionary *request = [self createRequestForMethod:@"session-set"
                                           withArguments:stats
                                                     tag:0];
    
    [self sendRequest:request callback:^(id data, NSError *error) {
        if (error) {
            callback(error);
            return;
        }
        
        callback(nil);
    }];
}

- (void)getSpeedLimits:(void (^)(long, long, NSError *))callback
{
    NSDictionary *request = [self createRequestForMethod:@"session-get"
                                           withArguments:nil
                                                     tag:0];
    
    [self sendRequest:request callback:^(id data, NSError *error) {
        if (error) {
            callback(0, 0, error);
            return;
        }
        
        NSDictionary *arguments = data[@"arguments"];
        if (!arguments || !arguments[@"speed-limit-down-enabled"] ||
            !arguments[@"speed-limit-up-enabled"] ||
            !arguments[@"speed-limit-down"] ||
            !arguments[@"speed-limit-up"]) {
            callback(0, 0, [NSError errorWithDomain:CRTTransmissionControllerErrorDomain
                                               code:CRTTransmissionControllerErrorMalformedResponse
                                           userInfo:@{NSLocalizedDescriptionKey: @"Malformed response from server"}]);
            return;
        }
        
        BOOL downloadLimitEnabled = [arguments[@"speed-limit-down-enabled"] boolValue];
        BOOL uploadLimitEnabled = [arguments[@"speed-limit-up-enabled"] boolValue];
        long downloadLimit = 0, uploadLimit = 0;
        if (downloadLimitEnabled) {
            downloadLimit = [arguments[@"speed-limit-down"] longValue];
        }
        if (uploadLimitEnabled) {
            uploadLimit = [arguments[@"speed-limit-up"] longValue];
        }
        
        callback(downloadLimit, uploadLimit, nil);
    }];
}

- (void)setDownloadLimit:(long)downloadLimit
             uploadLimit:(long)uploadLimit
          withCompletion:(void (^)(NSError *))callback
{
    NSMutableDictionary *args = [@{@"speed-limit-down-enabled": (downloadLimit ? @YES : @NO),
                                  @"speed-limit-up-enabled": (uploadLimit ? @YES : @NO)} mutableCopy];
    
    if (downloadLimit)
        args[@"speed-limit-down"] = @(downloadLimit);
    if (uploadLimit)
        args[@"speed-limit-up"] = @(uploadLimit);
    
    NSDictionary *request = [self createRequestForMethod:@"session-set"
                                           withArguments:args
                                                     tag:0];
    
    [self sendRequest:request callback:^(id data, NSError *error) {
        if (error) {
            callback(error);
            return;
        }
        
        callback(nil);
    }];
}

- (void)addTorrent:(NSString *)torrentFilePathOrURL withCompletion:(void (^)(NSError *))callback
{
    NSAssert(torrentFilePathOrURL != nil, @"The .torrent file path or URL can't be nil");
    
    NSDictionary *request = [self createRequestForMethod:@"torrent-add"
                                           withArguments:@{@"filename": torrentFilePathOrURL}
                                                     tag:0];
    
    [self sendRequest:request callback:^(id data, NSError *error) {
        if (error) {
            callback(error);
            return;
        }
        
        callback(nil);
    }];
}

- (void)isPortOpen:(void (^)(BOOL isPortOpen, NSError *__autoreleasing error))callback
{
    NSDictionary *request = [self createRequestForMethod:@"port-test" withArguments:nil tag:0];
    [self sendRequest:request callback:^(id data, NSError *error) {
        if (error) {
            NSLog(@"Error request: %@", error);
            callback(NO, error);
            return;
        }
        NSDictionary *result = (NSDictionary *)data;
        NSDictionary *args = result[@"arguments"];
        if (!args) {
            NSLog(@"No hay argumentos de vuelta.");
            callback(NO, [NSError errorWithDomain:CRTTransmissionControllerErrorDomain
                                              code:CRTTransmissionControllerErrorMalformedResponse
                                          userInfo:@{NSLocalizedDescriptionKey: @"Expected \"arguments\" key in response."}]);
            return;
        }
        NSNumber *isPortOpen = args[@"port-is-open"];
        if (!isPortOpen) {
            NSLog(@"No hay port-is-open");
            callback(NO, [NSError errorWithDomain:CRTTransmissionControllerErrorDomain
                                             code:CRTTransmissionControllerErrorMalformedResponse
                                         userInfo:@{NSLocalizedDescriptionKey: @"Expected \"arguments.port-is-open\" key in response."}]);
            return;
        }
        
        callback(isPortOpen.boolValue, nil);
    }];
}


- (void)sendRequest:(NSDictionary *)request callback:(ServerCallback)callback
{
    NSURLRequest *finalRequest = [self transmissionRequest:request];
    NSAssert(finalRequest != nil, @"Error building NSURLRequest");
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:finalRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            callback(nil, error);
            return;
        }
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 409) {
            // Our transmission-session-id was invalid and the server has given us a new one.
            // Store it and retry the request.
            self.transmissionSessionID = httpResponse.allHeaderFields[@"x-transmission-session-id"];
            NSLog(@"Received transmission-session-id: %@", self.transmissionSessionID);
            [self sendRequest:request callback:callback];
        } else if (httpResponse.statusCode == 200) {
            NSError *errorJSON = nil;
            id jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&errorJSON];
            if (errorJSON) {
                callback(nil, errorJSON);
                return;
            }
            
            if ([jsonData isKindOfClass:[NSDictionary class]]) {
                NSDictionary *resultDict = jsonData;
                if ([resultDict[@"result"] isEqualToString:@"success"]) {
                    callback(jsonData, nil);
                } else {
                    callback(jsonData, [NSError errorWithDomain:CRTTransmissionControllerErrorDomain
                                                           code:CRTTransmissionControllerErrorNotSuccessfulResponse
                                                       userInfo:@{NSLocalizedDescriptionKey: @"result is not \"success\""}]);
                }
            }
        } else {
            callback(nil, [NSError errorWithDomain:CRTTransmissionControllerErrorDomain
                                              code:CRTTransmissionControllerErrorUnknownStatusCode
                                          userInfo:@{@"statusCode": @(httpResponse.statusCode),
                                                     NSLocalizedDescriptionKey: @"Status code not expected"}]);
        }
    }];
    [dataTask resume];
}


@end
