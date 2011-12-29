/**
 *  LGSUser.m
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

#import "LGSUser.h"

static LGSUser* sharedUser = nil;

@implementation LGSUser
@synthesize name;
@synthesize gold;
@synthesize cardID;
@synthesize points;
@synthesize askedQuestions;
@synthesize objects;
@synthesize adventures;
@synthesize nbQuestionsCharacter;

+(LGSUser*) sharedUser
{
	@synchronized(self)
	{
		if(sharedUser == nil)
		{
			sharedUser = [[self alloc] init];
		}
	}
	return sharedUser;
}

+(void) setSharedUser:(LGSUser*) aUser
{
	@synchronized(self)
	{
		if(sharedUser != nil)
		{
			[sharedUser release];
		}
		sharedUser = [aUser retain];
	}
}

- (id) initWithCoder: (NSCoder *)coder
{
  if (self = [super init])
  {
    name = [[coder decodeObjectForKey:@"name"] retain];
    gold = [[coder decodeObjectForKey:@"gold"] integerValue];
    cardID = [[coder decodeObjectForKey:@"cardID"] retain];
    points = [[coder decodeObjectForKey:@"points"] retain];
    askedQuestions = [[coder decodeObjectForKey:@"askedQuestions"] retain];
    objects = [[coder decodeObjectForKey:@"objects"] retain];
    adventures = [[coder decodeObjectForKey:@"adventures"] retain];
    nbQuestionsCharacter = [[coder decodeObjectForKey:@"nbQuestionsCharacter"] retain];
  }
  return self;
}

- (void) encodeWithCoder: (NSCoder *)coder
{
  [coder encodeObject: name forKey:@"name"];
  [coder encodeObject: [NSNumber numberWithInteger:gold] forKey:@"gold"];
  [coder encodeObject: cardID forKey:@"cardID"];
  [coder encodeObject: points forKey:@"points"];
  [coder encodeObject: askedQuestions forKey:@"askedQuestions"];
  [coder encodeObject: objects forKey:@"objects"];
  [coder encodeObject: adventures forKey:@"adventures"];
  [coder encodeObject: nbQuestionsCharacter forKey:@"nbQuestionsCharacter"];
}

-(id) init
{
	if(self = [super init])
	{
		/*
		 initiation code - original from LGS hypercard
		 put it into nom
		 put 1 into nbdep
		 put 13 into fortune
		 put "card id 4101" into endroit
		 put "0,0,0,0" into points
		 put "-,-,-,-" into questionsposees
		 put "false,false,false,false,false,false,false,false,false,false,"\
		 &"false,false,false,false,false" into objets
		 put "false,0,1,0,true,0,false,false,false,0" into peripeties
		 put "0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0" into nbquestpers
		 put false into effacerchamps
		 put "0,0,0,0,0,0,0,0" into pourcentages
		 */
		
		//default user params
		name = [@"Matyo" retain];
		nbSteps = 0;
		gold = 13;
		cardID = [@"0" retain];

		NSArray* k = nil;
		NSArray* o = nil;

		k = [NSArray arrayWithObjects:@"Litter", @"Matem", @"Histora", @"Encyclopia", nil];
		o = [NSArray arrayWithObjects:
		     [NSNumber numberWithInteger:0],
		     [NSNumber numberWithInteger:0],
		     [NSNumber numberWithInteger:0],
		     [NSNumber numberWithInteger:0],
		     nil];

		points = [[NSMutableDictionary dictionaryWithObjects:o forKeys:k] retain];

		askedQuestions = [[NSMutableArray alloc] init];

		k = [NSArray arrayWithObjects:	@"lexique", @"boulier", @"atlas", @"croix_celtique", @"sablier", @"piece_roi", @"sac_or", @"herbes",
										@"pepite", @"pommes", @"bouteille", @"lait", @"joncs", @"fleurs", @"collier", @"torche", nil];
		o = [NSArray arrayWithObjects:
		     [NSNumber numberWithBool:NO],
		     [NSNumber numberWithBool:NO],
		     [NSNumber numberWithBool:NO],
		     [NSNumber numberWithBool:NO],
		     [NSNumber numberWithBool:NO],
		     [NSNumber numberWithBool:NO],
		     [NSNumber numberWithBool:NO],
		     [NSNumber numberWithBool:NO],
		     [NSNumber numberWithBool:NO],
		     [NSNumber numberWithBool:NO],
		     [NSNumber numberWithBool:NO],
		     [NSNumber numberWithBool:NO],
		     [NSNumber numberWithBool:NO],
		     [NSNumber numberWithBool:NO],
		     [NSNumber numberWithBool:NO],
		     [NSNumber numberWithBool:NO],
		     nil];

		objects = [[NSMutableDictionary dictionaryWithObjects:o forKeys:k] retain];

		k = [NSArray arrayWithObjects:	@"mendiant", @"taverne", @"nbAdviceBoutique", @"vente_herbes", @"lueur_pepite", @"gnome", 
										@"lexique_prete", @"boulier_notable", @"atlas_sage", @"nbStepsCat", @"coupDePied_chien", nil];
		o = [NSArray arrayWithObjects:
		     [NSNumber numberWithBool:NO],
		     [NSNumber numberWithInteger:0],
		     [NSNumber numberWithInteger:1],
		     [NSNumber numberWithInteger:0],
		     [NSNumber numberWithBool:YES],
		     [NSNumber numberWithInteger:0],
		     [NSNumber numberWithBool:NO],
		     [NSNumber numberWithBool:NO],
		     [NSNumber numberWithBool:NO],
		     [NSNumber numberWithInteger:0],
		     [NSNumber numberWithInteger:0],
		     nil];

		adventures = [[NSMutableDictionary dictionaryWithObjects:o forKeys:k] retain];
		
		k = [NSArray arrayWithObjects:	@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", 
										@"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19",
										@"20", @"21", @"22", @"23", @"24", @"25", @"26", @"ange", nil];
		o = [NSArray arrayWithObjects:
		     [NSNumber numberWithInteger:0],
		     [NSNumber numberWithInteger:0],
		     [NSNumber numberWithInteger:0],
		     [NSNumber numberWithInteger:0],
		     [NSNumber numberWithInteger:0],
		     [NSNumber numberWithInteger:0],
		     [NSNumber numberWithInteger:0],
		     [NSNumber numberWithInteger:0],
		     [NSNumber numberWithInteger:0],
		     [NSNumber numberWithInteger:0],
		     [NSNumber numberWithInteger:0],
		     [NSNumber numberWithInteger:0],
		     [NSNumber numberWithInteger:0],
		     [NSNumber numberWithInteger:0],
		     [NSNumber numberWithInteger:0],
		     [NSNumber numberWithInteger:0],
		     [NSNumber numberWithInteger:0],
		     [NSNumber numberWithInteger:0],
		     [NSNumber numberWithInteger:0],
		     [NSNumber numberWithInteger:0],
		     [NSNumber numberWithInteger:0],
		     [NSNumber numberWithInteger:0],
		     [NSNumber numberWithInteger:0],
		     [NSNumber numberWithInteger:0],
		     [NSNumber numberWithInteger:0],
		     [NSNumber numberWithInteger:0],
		     [NSNumber numberWithInteger:0],
		     nil];
		
		nbQuestionsCharacter = [[NSMutableDictionary dictionaryWithObjects:o forKeys:k] retain];
	}
	return self;
}

-(void) goCard:(NSString*) aCardID
{
	nbSteps += 1;
	[cardID release];
	cardID = [aCardID retain];
}

-(LGSAnswerResult) answer:(NSString*) answer forQuestion:(LGSQuestion*) question andCharacter:(NSString*) character inCity:(NSString*) city
{
	LGSAnswerResult result;
	
	result.isValid = NO;
	result.points = 0;
	result.validAnswer = @"";
	
	[askedQuestions addObject:question];
	[nbQuestionsCharacter setObject:[NSNumber numberWithInt:([[nbQuestionsCharacter objectForKey:character] intValue]  + 1)] forKey:character];
	
	NSInteger qPoints = [question.points intValue];
	for(NSString* qAnswer in question.answers)
	{
		if([[question.answers objectForKey:qAnswer] boolValue] == YES)
		{
			//valid answer
			result.validAnswer = qAnswer;
			
			if([answer isEqualToString:qAnswer])
			{
				result.isValid = YES;
				result.points = qPoints;
				
				[points setObject:[NSNumber numberWithInt:([[points objectForKey:city] intValue] + qPoints)] forKey:city];
				
				return result;
			}
		}
	}
	
	//no valid answer given
	if([[points objectForKey:city] intValue] > 0)
	{
		[points setObject:[NSNumber numberWithInt:([[points objectForKey:city] intValue] - 1)] forKey:city];
		result.points = -1;
	}
	
	return result;
}

-(void) dealloc
{
	[name release];
	[cardID release];
	[points release];
	[askedQuestions release];
	[objects release];
	[adventures release];
	[nbQuestionsCharacter release];
	[super dealloc];
}

@end
