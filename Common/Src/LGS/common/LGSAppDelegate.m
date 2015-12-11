/**
 *  LGSAppDelegate.m
 *  LGS
 *
 *  Created by Mathieu LEDRU on 08/11/09.
 *
 *  BSD License:
 *  Copyright (c) 2010, Mathieu LEDRU
 *
 *  All rights reserved.
 *  Redistribution and use in source and binary forms, with or without modification,
 *  are permitted provided that the following conditions are met:
 *
 *  *   Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 *  *   Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer
 *      in the documentation and/or other materials provided with the distribution.
 *  *   Neither the name of the Mathieu LEDRU nor the names of its contributors
 *      may be used to endorse or promote products derived from this software
 *      without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND ANY
 *  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 *  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS AND CONTRIBUTORS BE LIABLE FOR ANY
 *  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 *  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 *  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 *  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

#import "LGSAppDelegate.h"
#import "LGSGameViewController.h"

@implementation LGSAppDelegate

@synthesize window;
@synthesize view;

#ifdef D_MAC

-(void) applicationDidFinishLaunching:(NSNotification*) application
{
	srand(clock()); //make random number different for each run time

	mainController = [[[LGSDefaultViewController controllerClassWithKey:@"PlatformMain"] alloc] initWithAppDelegate:self];
}

- (IBAction)newGame:(NSMenuItem *)sender
{
    [self changeLGSController:@"PlatformMain"];
}

- (IBAction)revertToSaved:(NSMenuItem *)sender
{
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	NSString* loadPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"save.lgs"];
	NSDictionary* rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile:loadPath];
	if(rootObject)
	{
		//load a game
		[LGSUser setSharedUser:[rootObject valueForKey:@"user"]];
		[self changeLGSController:@"PlatformGame"];
	}
}

- (IBAction)saveGame:(NSMenuItem *)sender
{
	if([mainController isKindOfClass:[LGSGameViewController class]])
	{
		LGSGameViewController* game = (LGSGameViewController*) mainController;
		[game lgsActions:game.saveView];
	}
}

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)anItem
{
	SEL theAction = [anItem action];

	if (theAction == @selector(revertToSaved:))
	{
		NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
		NSString* loadPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"save.lgs"];
		NSDictionary* rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile:loadPath];
		if(rootObject)
		{
			return YES;
		}
		return NO;
	}
	else if (theAction == @selector(saveGame:))
	{
		if([mainController isKindOfClass:[LGSGameViewController class]])
		{
			return YES;
		}
		return NO;
	}
	
	return [super validateUserInterfaceItem:anItem];
}

#endif

#if defined(D_IOS)

- (BOOL)application:(LGSApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	srand(clock()); //make random number different for each run time

    CGRect bounds = [UIScreen mainScreen].bounds;
    self.window = [[UIWindow alloc] initWithFrame:bounds];
    self.view = [[UIView alloc] initWithFrame:bounds];
    
    CGAffineTransform transform;
    transform = CGAffineTransformMakeScale(bounds.size.width * 1.0 / 480, bounds.size.height / 320); //ratio scale according to original window size (480x320, iphone4)
    transform = CGAffineTransformRotate(transform, -M_PI_2);
    [self.view setTransform:transform];
    
    [self.view setFrame:CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height)];
    
	mainController = [[[LGSDefaultViewController controllerClassWithKey:@"PlatformMain"] alloc] initWithAppDelegate:self];
    mainController.view = self.view;
    
    self.window.rootViewController = mainController;
  
	[window makeKeyAndVisible];
  
	return TRUE;
}

#endif

-(void) changeLGSController:(NSString*) lgsControllerName
{
	[mainController autorelease];
	mainController = [[[LGSDefaultViewController controllerClassWithKey:lgsControllerName] alloc] initWithAppDelegate:self];
}

-(void) dealloc
{
	[mainController release];
	[self setWindow:nil];
	[self setView:nil];
	[super dealloc];
}

@end
