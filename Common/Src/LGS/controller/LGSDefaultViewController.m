/**
 *  LGSDefaultViewController.m
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
#import "LGSDefaultViewController.h"

static LGSView* sharedView = nil;

@implementation LGSDefaultViewController

+ (LGSView*)getMainView
{
	return sharedView;
}

-(id) initWithAppDelegate:(LGSAppDelegate*) anAppDelegate;
{
	if(self = [super init])
	{
		appDelegate = anAppDelegate;
		self.view = [[LGSView alloc] initWithFrame:anAppDelegate.view.bounds];
		sharedView = self.view;
		[anAppDelegate.view addSubview:self.view];
		NSString* className = [[self class] description];
		name = [className substringWithRange:NSMakeRange(3, [className length] - 17)];
		name = [[name stringByReplacingOccurrencesOfString:@"Platform" withString:@""] retain];
		data = [LGSData sharedData];
		user = [LGSUser sharedUser];

		if(![self start])
		{
			[self release];
			return nil;
		}
	}
	return self;
}

-(BOOL) start
{
	return YES;
}

-(NSDictionary*) initDatas
{
	return [data initDatasForKey:name];
}

+(Class) controllerClassWithKey:(NSString*) key
{
	return NSClassFromString([NSString stringWithFormat:@"LGS%@ViewController", key]);
}

-(void) lgsActions:(LGSControl*) sender
{
}

-(void) dealloc
{
	[name release];
	[self.view removeFromSuperview];
	[self.view release];
	[super dealloc];
}

@end
