//
//  MECharacter.h
//  MarvelWiki
//
//  Created by Jason Anderson on 5/14/14.
//  Copyright (c) 2014 Jason Anderson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MECharacter : NSObject

@property (strong,nonatomic) NSString *thumbnailPath;
@property (strong,nonatomic) NSString *imagePath;
@property (strong,nonatomic) NSString *name;
@property (strong,nonatomic) NSURL *detailLink;

@end
