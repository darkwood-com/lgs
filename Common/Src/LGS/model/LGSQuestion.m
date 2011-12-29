/**
 *  LGSQuestion.m
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

#import "LGSQuestion.h"

@implementation LGSQuestion
@synthesize points;
@synthesize ask;
@synthesize answers;

-(id) initWithXMLNode:(DDXMLElement*) aNode
{
	if(self = [super init])
	{
		NSMutableDictionary* parseAnswers = [[NSMutableDictionary alloc] init];
		
		points = [[[aNode attributeForName:@"points"] stringValue] retain];
		ask = [[[aNode attributeForName:@"ask"] stringValue] retain];
		
		for(DDXMLElement* answer in [aNode children])
		{
			if([answer isKindOfClass:[DDXMLElement class]] && [[answer name] isEqualToString:@"answer"])
			{
				BOOL valid = NO;
				if([answer attributeForName:@"valid"] && [[[answer attributeForName:@"valid"] stringValue] isEqualToString:@"true"])
				{
					valid = YES;
				}
				
				[parseAnswers setValue:[NSNumber numberWithBool:valid] forKey:[[answer attributeForName:@"value"] stringValue]];
			}
		}
		
		answers = parseAnswers;
	}
	return self;
}

- (id) initWithCoder: (NSCoder *)coder
{
  if (self = [super init])
  {
    points = [[coder decodeObjectForKey:@"points"] retain];
    ask = [[coder decodeObjectForKey:@"ask"] retain];
    answers = [[coder decodeObjectForKey:@"answers"] retain];
  }
  return self;
}

- (void) encodeWithCoder: (NSCoder *)coder
{
  [coder encodeObject: points forKey:@"points"];
  [coder encodeObject: ask forKey:@"ask"];
  [coder encodeObject: answers forKey:@"answers"];
}

-(BOOL)isEqual:(LGSQuestion*) aQuestion
{
  //compare a question neither with pointer
	if([super isEqual:aQuestion])
	{
		return YES;
	}
	
  //compare a question nor with ask value
	if([ask isEqualToString:aQuestion.ask])
	{
		return YES;
	}
	
	return NO;
}

-(void) dealloc
{
	[points release];
	[ask release];
	[answers release];
	[super dealloc];
}

@end
