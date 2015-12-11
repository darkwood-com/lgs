/**
 *  LGSAdditionControl.m
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

#import "LGSAdditionControl.h"

@implementation LGSControl (LGSAdditionControl)

-(void) addToView:(LGSView*) aView withTarget:(id<LGSActions>) aTarget isHidden:(BOOL) isHidden
{
#ifdef D_MAC
	[self setTarget:aTarget];
	[self setAction:@selector(lgsActions:)];
	[self setHidden:isHidden];

	[aView addSubview:self];
#endif

#if defined(D_IOS)
	[self addTarget:aTarget action:@selector(lgsActions:)forControlEvents:UIControlEventTouchDown];
	[self setHidden:isHidden];

	[aView addSubview:self];
#endif
}

-(BOOL) sendActionToTarget;
{
#ifdef D_MAC
	if(([self action] == nil) || ([self target] == nil))
	{
		return NO;
	}

	return [self sendAction:[self action] to:[self target]];
#endif

#if defined(D_IOS)
	id target = nil;
	SEL action = nil;

	for(NSObject* aTarget in [self allTargets])
	{
		target = aTarget;
		NSArray* actions = [self actionsForTarget:target forControlEvent:UIControlEventTouchDown];
		for(NSString* anAction in actions)
		{
			if((anAction != nil) && [aTarget respondsToSelector:NSSelectorFromString(anAction)])
			{
				action = NSSelectorFromString(anAction);
			}
		}
	}

	if((target == nil) || (action == nil))
	{
		return NO;
	}

	[self sendAction:action to:target forEvent:nil];

	return YES;
#endif
}

#ifdef D_MAC

-(void) mouseDown:(NSEvent*) theEvent
{
	[self sendActionToTarget];
}

#endif

#if defined(D_IOS)

-(void) touchesBegan:(NSSet*) touches withEvent:(UIEvent*) event
{
	[self sendActionToTarget];
}

#endif

@end
