//
//  MEAppDelegate.m
//  MarvelWiki
//
//  Created by Jason Anderson on 5/13/14.
//  Copyright (c) 2014 Jason Anderson. All rights reserved.
//

#import "MEAppDelegate.h"
#import "MERootViewController.h"

@implementation MEAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self.window setRootViewController:[[MERootViewController alloc] init]];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
