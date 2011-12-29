/**
 *  LGSData.m
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

#import "DDXML.h"

#import "LGSCard.h"
#import "LGSData.h"
#import "LGSQuestion.h"

static LGSData* sharedData = nil;

NSInteger randomSort(id obj1, id obj2, void* context)
{
	// returns random number -1 0 1
	return (rand()%3 - 1);	
}

@implementation LGSData

+(LGSData*) sharedData
{
	@synchronized(self)
	{
		if(sharedData == nil)
		{
			sharedData = [[self alloc] init];
		}
	}
	return sharedData;
}

-(id) init
{
	if(self = [super init])
	{
		//load data.xml
		NSMutableDictionary* parseInits = [[NSMutableDictionary alloc] init];
		NSMutableDictionary* parseSounds = [[NSMutableDictionary alloc] init];
		NSMutableDictionary* parseCards = [[NSMutableDictionary alloc] init];

		NSString* fileDataPath = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"xml" inDirectory:@"Datas"];
		NSData* fileData = [[NSData alloc] initWithContentsOfFile:fileDataPath];
		DDXMLDocument* docData = [[DDXMLDocument alloc] initWithData:fileData options:0 error:nil];

		for(DDXMLElement* nodeChild in [[docData rootElement] children])
		{
			if([[nodeChild name] isEqualToString:@"inits"])
			{
				for(DDXMLElement* init in [nodeChild children])
				{
					NSMutableDictionary* datas = [[NSMutableDictionary alloc] init];
					for(DDXMLElement* data in [init children])
					{
						if([data isKindOfClass:[DDXMLElement class]])
						{
							[datas setValue:[[data attributeForName:@"value"] stringValue] forKey:[[data attributeForName:@"key"] stringValue]];
						}
					}
					[parseInits setValue:(NSDictionary*)datas forKey:[[init attributeForName:@"key"] stringValue]];
					[datas release];
				}
			}
			else if([[nodeChild name] isEqualToString:@"sounds"])
			{
				for(DDXMLElement* sound in [nodeChild children])
				{
					[parseSounds setValue:[[sound attributeForName:@"value"] stringValue] forKey:[[sound attributeForName:@"key"] stringValue]];
				}
			}
			else if([[nodeChild name] isEqualToString:@"cards"])
			{
				for(DDXMLElement* card in [nodeChild children])
				{
					[parseCards setValue:[[[LGSCard alloc] initWithXMLNode:card] autorelease] forKey:[[card attributeForName:@"key"] stringValue]];
				}
			}
		}

		[fileData release];

		inits = parseInits;
		sounds = parseSounds;
		cards = parseCards;
		
		//load questions.xml
		NSMutableDictionary* parseQuestions = [[NSMutableDictionary alloc] init];
		
		NSString* fileQuestionPath = [[NSBundle mainBundle] pathForResource:@"questions" ofType:@"xml" inDirectory:@"Datas"];
		NSData* fileQuestion = [[NSData alloc] initWithContentsOfFile:fileQuestionPath];
		DDXMLDocument* docQuestion = [[DDXMLDocument alloc] initWithData:fileQuestion options:0 error:nil];
		
		for(DDXMLElement* nodeChild in [[docQuestion rootElement] children])
		{
			if([[nodeChild name] isEqualToString:@"questions"])
			{
				NSMutableArray* questionsArray = [[NSMutableArray alloc] init];
				for(DDXMLElement* question in [nodeChild children])
				{
					[questionsArray addObject:[[[LGSQuestion alloc] initWithXMLNode:question] autorelease]];
				}
				
				//random questions position in the array
				[questionsArray sortUsingFunction:randomSort context:nil];
				
				[parseQuestions setValue:questionsArray forKey:[[nodeChild attributeForName:@"city"] stringValue]];
			}
		}
		
		[fileQuestion release];
		
		questions = parseQuestions;
	}
	return self;
}

-(NSDictionary*) initDatasForKey:(NSString*) aKey
{
	return [inits valueForKey:aKey];
}

-(NSString*) soundDatasForKey:(NSString*) aKey
{
	return [sounds valueForKey:aKey];
}

-(LGSCard*) cardDatasForKey:(NSString*) aKey
{
	return [cards valueForKey:aKey];
}

-(NSArray*) questionsFromCity:(NSString*) city
{
	return [questions valueForKey:city];
}

-(void) dealloc
{
	[cards release];
	[sounds release];
	[inits release];
	[super dealloc];
}

@end
