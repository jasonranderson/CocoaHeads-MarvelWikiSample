//
//  MEDataManager.h
//  MarvelWiki
//
//  Created by Jason Anderson on 5/13/14.
//  Copyright (c) 2014 Jason Anderson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MEDataManager : NSObject

+ (instancetype)sharedManager;

- (void)searchAPIWithString: (NSString *)string completion:(void (^)(NSArray *resultsArray))completion;

@end
