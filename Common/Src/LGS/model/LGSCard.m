/**
 *  LGSCard.m
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

#import "LGSAdditionValue.h"
#import "LGSCard.h"
#import "LGSTypes.h"

@implementation LGSAction
@synthesize type;
@synthesize value;

-(id) initWithType:(NSString*) aType andValue:(NSString*) aValue
{
	if(self = [super init])
	{
		type = [aType retain];
		value = [aValue retain];
	}
	return self;
}

-(void) dealloc
{
	[value release];
	[type release];
	[super dealloc];
}

@end

@implementation LGSCard
@synthesize imagePath;
@synthesize surfaces;
@synthesize actions;
@synthesize coords;

-(id) initWithXMLNode:(DDXMLElement*) aNode
{
	if(self = [super init])
	{
		NSMutableDictionary* parseMessages = [[NSMutableDictionary alloc] init];
		NSMutableDictionary* parseSurfaces = [[NSMutableDictionary alloc] init];
		NSMutableDictionary* parseActions = [[NSMutableDictionary alloc] init];

		imagePath = [[[aNode attributeForName:@"imagePath"] stringValue] retain];
		coords = LGSMakePoint([[[aNode attributeForName:@"mapX"] stringValue] intValue],
		                      [[[aNode attributeForName:@"mapY"] stringValue] intValue]);

		for(DDXMLElement* nodeChild in [aNode children])
		{
			if([[nodeChild name] isEqualToString:@"messages"])
			{
				for(DDXMLElement* messageNode in [nodeChild children])
				{
					if([messageNode isKindOfClass:[DDXMLElement class]])
					{
						[parseMessages setValue:[[messageNode attributeForName:@"value"] stringValue] forKey:[[messageNode attributeForName:@"key"] stringValue]];
					}
				}
			}
			else if([[nodeChild name] isEqualToString:@"surfaces"])
			{
				for(DDXMLElement* surfaceNode in [nodeChild children])
				{
					if([surfaceNode isKindOfClass:[DDXMLElement class]])
					{
						LGSRect surfaceRect = LGSMakeRect([[[surfaceNode attributeForName:@"x"] stringValue] intValue],
						                                  [[[surfaceNode attributeForName:@"y"] stringValue] intValue],
						                                  [[[surfaceNode attributeForName:@"width"] stringValue] intValue],
						                                  [[[surfaceNode attributeForName:@"height"] stringValue] intValue]);
						[parseSurfaces setObject:[[surfaceNode attributeForName:@"action"] stringValue] forKey:[NSValue valueWithLGSRect:surfaceRect]];
					}
				}
			}
			else if([[nodeChild name] isEqualToString:@"actions"])
			{
				for(DDXMLElement* actionNode in [nodeChild children])
				{
					if([actionNode isKindOfClass:[DDXMLElement class]])
					{
						LGSAction* action = [[[LGSAction alloc] initWithType:[[actionNode attributeForName:@"type"] stringValue] andValue:[[actionNode attributeForName:@"value"] stringValue]] autorelease];
						[parseActions setValue:action forKey:[[actionNode attributeForName:@"key"] stringValue]];
					}
				}
			}
		}

		actions = parseActions;
		surfaces = parseSurfaces;
		messages = parseMessages;
	}
	return self;
}

-(NSString*) messageFromKey:(NSString*) aKey
{
	return [messages valueForKey:aKey];
}

-(void) dealloc
{
	[actions release];
	[surfaces release];
	[messages release];
	[imagePath release];
	[super dealloc];
}

@end
