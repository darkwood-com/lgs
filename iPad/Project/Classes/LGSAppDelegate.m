//
//  LGSAppDelegate.m
//  LGS
//
//  Created by Mathieu Ledru on 04/04/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "LGSAppDelegate.h"

@implementation LGSAppDelegate

@synthesize window;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
    // Override point for customization after application launch
	
    [window makeKeyAndVisible];
    
    return YES;
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
