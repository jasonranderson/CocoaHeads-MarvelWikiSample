//
//  MEDataManager.m
//  MarvelWiki
//
//  Created by Jason Anderson on 5/13/14.
//  Copyright (c) 2014 Jason Anderson. All rights reserved.
//

#import "MEDataManager.h"
#import "MECharacter.h"
#import "NSString+MEExtensions.h"
#import <AFNetworking/AFNetworking.h>

/*
 Applications must pass two parameters in addition to the apikey parameter:
 
 ts - a timestamp (or other long string which can change on a request-by-request basis)
 hash - a md5 digest of the ts parameter, your private key and your public key (e.g. md5(ts+privateKey+publicKey)
 
 For example, a user with a public key of "1234" and a private key of "abcd" could construct a valid call as follows: http://gateway.marvel.com/v1/comics/?ts=1&apikey=1234&hash=ffd275c5130566a2916217b101f26150 (the hash value is the md5 digest of 1abcd1234)
 */

NSString *const kAPIBaseURL = @"http://gateway.marvel.com";
NSString *const kAPICharacterEndPoint = @"/v1/public/characters";

@interface MEDataManager()

@property (strong,nonatomic) NSString *apiPublicKey;
@property (strong,nonatomic) NSString *apiPrivateKey;

@property (strong,nonatomic) AFHTTPSessionManager *sessionManager;

@end

@implementation MEDataManager

+ (instancetype)sharedManager
{
    static id retval;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        retval = [[[self class] alloc] init];
    });
    
    return retval;
}

- (instancetype)init
{
    if (!(self = [super init]))
        return nil;
    
    NSString *apiConfigPath = [[NSBundle mainBundle] pathForResource:@"apiConfig" ofType:@"plist"];
    NSAssert(apiConfigPath, @"The file, apiConfig.plist, is required. Generate a copy from apiConfigSample.plist and apply your Marvel API Keys in the areas provided.");
    
    NSDictionary *apiDictionary = [[NSDictionary alloc] initWithContentsOfFile:apiConfigPath];
    [self setApiPrivateKey:apiDictionary[@"apiPrivateKey"]];
    [self setApiPublicKey:apiDictionary[@"apiPublicKey"]];
    
    [self setSessionManager:[[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kAPIBaseURL]]];
    [self.sessionManager.reachabilityManager startMonitoring];
    
    return self;
}

- (void)searchAPIWithString: (NSString *)string completion:(void (^)(NSArray *resultsArray))completion
{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSString *hash = [[NSString stringWithFormat:@"%@%@%@",@(timeInterval),self.apiPrivateKey,self.apiPublicKey] ME_MD5String];
    
    NSMutableURLRequest *request = [self.sessionManager.requestSerializer requestWithMethod:@"GET" URLString:[NSString stringWithFormat:@"%@%@",kAPIBaseURL,kAPICharacterEndPoint] parameters:@{@"apikey" : self.apiPublicKey, @"ts" : @(timeInterval), @"hash" : hash, @"nameStartsWith" : string} error:NULL];
    
    NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        
        if (!error) {
            NSDictionary *json = responseObject;
            
           NSMutableArray *resultsArray = [NSMutableArray array];
            for (NSDictionary *characterDictionary in json[@"data"][@"results"]) {
                MECharacter *character = [[MECharacter alloc] init];
                character.name = characterDictionary[@"name"];
                character.thumbnailPath = [NSString stringWithFormat:@"%@/standard_small.%@", characterDictionary[@"thumbnail"][@"path"],characterDictionary[@"thumbnail"][@"extension"]];
                character.imagePath = [NSString stringWithFormat:@"%@/landscape_incredible.%@", characterDictionary[@"thumbnail"][@"path"],characterDictionary[@"thumbnail"][@"extension"]];
                
                
                NSString *wikiLink;
                for (NSDictionary *urlDictionary in characterDictionary[@"urls"]) {
                    if ([urlDictionary[@"type"] isEqualToString:@"wiki"])
                        wikiLink = urlDictionary[@"url"];
                }
                
                if (wikiLink.length > 0)
                    character.detailLink = [NSURL URLWithString:wikiLink];
                
                [resultsArray addObject:character];
            }
            
            completion(resultsArray);
        } else {
            completion(@[]);
        }
    }];
    
    [dataTask resume];
}

@end
