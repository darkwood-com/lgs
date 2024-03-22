/**
 *  LGSGameViewController.m
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

#import "LGSGameViewController.h"

#import "LGSAppDelegate.h"
#import "LGSPlatformBoxView.h"
#import "LGSPlatformSurfaceView.h"
#import "LGSSoundManager.h"
#import "LGSQuestion.h"

@implementation LGSGameViewController
@synthesize saveView;

-(BOOL) start
{
	mode = [[NSMutableDictionary alloc] init];
	actions = [[NSMutableDictionary alloc] init];
	boxViewMessages = [[NSMutableDictionary alloc] init];
	boxOriginalViewMessages = [[NSMutableDictionary alloc] init];

	return YES;
}

-(LGSCard*) goCard:(NSString*) cardID
{
	NSString* lastCardID = user.cardID;
	
	[[LGSSoundManager sharedSoundManager] stopSounds];

	//pre-custom actions, after opening a card
	[self lgsCustomActions:LGSGameActionCloseCard currentAction:nil];

	LGSCard* card = [data cardDatasForKey:cardID];

	[user goCard:cardID];

	[actions removeAllObjects];
	[actions addEntriesFromDictionary:card.actions];

	NSArray* surfacesView = [[cameraView.subviews copy] autorelease];
	for(LGSView* surfaceView in surfacesView)
	{
		[surfaceView removeFromSuperview];
	}

	[boxOriginalViewMessages setObject:[card messageFromKey:@"position"] forKey:positionView];
	[boxOriginalViewMessages setObject:[card messageFromKey:@"description"] forKey:descriptionView];
	[boxOriginalViewMessages setObject:[card messageFromKey:@"action"] forKey:actionView];
	[boxOriginalViewMessages setObject:[card messageFromKey:@"angel"] forKey:msgView];
	
	[boxViewMessages removeAllObjects];
	[boxViewMessages addEntriesFromDictionary:boxOriginalViewMessages];

	[mode setObject:[NSNumber numberWithInt:LGSGameModeNormal] forKey:@"mode"];
	//question management
	NSArray* actionParams = [[card messageFromKey:@"action"] componentsSeparatedByString:@","]; //@question,cardReturnId,city,character
	if([[actionParams objectAtIndex:0] isEqualToString:@"@question"])
	{
		//get question params
		[mode setObject:[NSNumber numberWithInt:LGSGameModeQuestion] forKey:@"mode"];
		[mode setObject:[actionParams objectAtIndex:1] forKey:@"cardReturnId"];
		[mode setObject:[actionParams objectAtIndex:2] forKey:@"city"];
		[mode setObject:[actionParams objectAtIndex:3] forKey:@"character"];
		
		if([[mode objectForKey:@"cardReturnId"] isEqualToString:@"last"])
		{
			[mode setObject:lastCardID forKey:@"cardReturnId"];
		}
		
		if([[user.nbQuestionsCharacter objectForKey:[mode objectForKey:@"character"]] intValue] > 3)
		{
			//4 questions max by characters
			[boxViewMessages setObject:@"Désolé, @user ! Il n'y a plus de Talents pour toi ici." forKey:descriptionView];
			[boxViewMessages setObject:@"#Suite...#" forKey:actionView];
			
			[actions setValue:[[[LGSAction alloc] initWithType:@"goCard" andValue:[mode objectForKey:@"cardReturnId"]] autorelease] forKey:@"Suite..."];
		}
		else
		{
			NSString* msgDescription = [boxViewMessages objectForKey:descriptionView];
			msgDescription = [msgDescription stringByAppendingString:@"\nQue choisis-tu ?"];
			[boxViewMessages setObject:msgDescription forKey:descriptionView];
			[boxViewMessages setObject:@"#2 Talents#\n#3 Talents#\n#4 Talents#\n#Ne pas répondre.#" forKey:actionView];
			
			[actions setValue:[[[LGSAction alloc] initWithType:@"question" andValue:@"2"] autorelease] forKey:@"2 Talents"];
			[actions setValue:[[[LGSAction alloc] initWithType:@"question" andValue:@"3"] autorelease] forKey:@"3 Talents"];
			[actions setValue:[[[LGSAction alloc] initWithType:@"question" andValue:@"4"] autorelease] forKey:@"4 Talents"];
			[actions setValue:[[[LGSAction alloc] initWithType:@"goCard" andValue:[mode objectForKey:@"cardReturnId"]] autorelease] forKey:@"Ne pas répondre."];
		}
	}
	
	//post-custom actions, after opening a card
	[self lgsCustomActions:LGSGameActionOpenCard currentAction:nil];

	[self refreshTextViews];

	return card;
}

-(void) lgsActions:(LGSControl*) sender
{
	LGSSoundManager* soundManager = [LGSSoundManager sharedSoundManager];

	//hide or bock other actions when we show msgView
	if(sender == msgView)
	{
		[soundManager stopSound:[data soundDatasForKey:@"angel"]];

		[msgView hide];
	}

	if([msgView isHidden] == NO)
	{
		return;
	}

	//default actions
	NSString* currentAction = nil;
	if(sender == msgView)
	{
		//special action when click on message view
		currentAction = @"action_message";
	}
	else if([sender isKindOfClass:[LGSPlatformSurfaceView class]])
	{
		LGSPlatformSurfaceView* surfaceView = (LGSPlatformSurfaceView*)sender;
		currentAction = [surfaceView currentAction];
	}
	else if([sender isKindOfClass:[LGSPlatformBoxView class]])
	{
		LGSPlatformBoxView* surfaceView = (LGSPlatformBoxView*)sender;
		currentAction = [surfaceView currentAction];
	}
	else if(sender == angelView)
	{
		if(rand() % 5 == 0)
		{
			switch (rand() % 4)
			{
				case 0: [self goCard:@"11660"]; break;
				case 1: [self goCard:@"11661"]; break;
				case 2: [self goCard:@"11662"]; break;
				case 3: [self goCard:@"11663"]; break;
			}
		}
		else
		{
			[boxViewMessages setObject:[boxOriginalViewMessages objectForKey:msgView] forKey:msgView];
			[msgView show];
			[soundManager loadAndPlaySound:[data soundDatasForKey:@"angel"] loop:TRUE];
		}
	}
	else if(sender == bagView)
	{
		NSArray* k = nil;
		NSArray* o = nil;
		
		k = [NSArray arrayWithObjects:	@"lexique", @"boulier", @"atlas", @"croix_celtique", @"sablier", @"piece_roi", @"sac_or", @"herbes", @"pepite",
										@"pommes", @"bouteille", @"lait", @"joncs", @"fleurs", @"collier", @"torche", nil];
		o = [NSArray arrayWithObjects:
		     @"un lexique",
		     @"un boulier",
		     @"un atlas",
		     @"le Talisman de Litter",
		     @"le Talisman de Matem",
		     @"le Talisman de Histora",
		     @"une bourse",
		     @"quelques herbes",
		     @"une pépite",
		     @"des pommes",
		     @"une bouteille",
		     @"un pot de lait",
		     @"des joncs",
		     @"un bouquet de fleurs",
		     @"un collier",
		     @"une torche",
		     nil];
		
		NSDictionary* objectsTranslation = [NSDictionary dictionaryWithObjects:o forKeys:k];
		
		NSString* msgValue = @"Talents : Litter @pointLitter @talentLitter, Matem @pointMatem @talentMatem, Histora @pointHistora @talentHistora, Encyclopia @pointEncyclopia @talentEncyclopia.";
		msgValue = [msgValue stringByAppendingString:@"\nVous possédez @gold @pieceor "];
		
		NSMutableArray* objectsDesc = [[NSMutableArray alloc] init];
		for(NSString* object in user.objects)
		{
			if([[user.objects valueForKey:object] boolValue])
			{
				[objectsDesc addObject:[objectsTranslation objectForKey:object]];
			}
		}
		
		if([objectsDesc count] > 0)
		{
			msgValue = [msgValue stringByAppendingString:@"et il y a dans votre sac :\n"];
			msgValue = [msgValue stringByAppendingString:[objectsDesc componentsJoinedByString:@", "]];
			msgValue = [msgValue stringByAppendingString:@"."];
		}
		else
		{
			msgValue = [msgValue stringByAppendingString:@"et il n'y a rien dans votre sac."];
		}
		
		[objectsDesc release];
		
		[boxViewMessages setObject:msgValue forKey:msgView];
		[msgView show];
	}
	else if(sender == saveView)
	{
    	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    	NSString* savePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"save.lgs"];
    
		NSMutableDictionary * rootObject;
		rootObject = [NSMutableDictionary dictionary];
		[rootObject setValue:user forKey:@"user"];
		[rootObject setValue:[NSDate date] forKey:@"savedate"];
		[NSKeyedArchiver archiveRootObject: rootObject toFile: savePath];
		
		NSString* msgValue = @"@user, ton périple a été enregistré.";
		
		[boxViewMessages setObject:msgValue forKey:msgView];
		[msgView show];
	}

	NSDictionary* allActions = [[NSDictionary alloc] initWithDictionary:actions];
	for(NSString* anAction in allActions)
	{
		if([anAction isEqualToString:currentAction])
		{
			LGSAction* action = [actions valueForKey:anAction];
			if([action.type isEqualToString:@"goCard"])
			{
				[self goCard:action.value];
			}
			else if([action.type isEqualToString:@"printMsg"])
			{
				[boxViewMessages setObject:action.value forKey:msgView];
				[msgView show];
			}
			else if([action.type isEqualToString:@"customAction"])
			{
				currentAction = action.value;
			}
			else if([action.type isEqualToString:@"question"] && [[mode objectForKey:@"mode"] intValue] == LGSGameModeQuestion)
			{
				currentAction = @"";
				[actions removeAllObjects];
				
				//find a question with the same amount of point and that the user do not have already answered
				NSArray* questions = [data questionsFromCity:[mode objectForKey:@"city"]];
				LGSQuestion* chosenQuestion = nil;
				for(LGSQuestion* question in questions)
				{
					if([question.points isEqualToString:action.value] && ![user.askedQuestions containsObject:question])
					{
						chosenQuestion = question;
					}
				}
				
				//@todo : reset all asked question when user have seen all question (and points) from this city
				//message : Tu as déjà vu toutes les questions correspondant à 'city'.
				//          Je veux tout de même te donner une nouvelle chance : nous allons reprendre parmi les questions déjà vues.
				
				if(chosenQuestion)
				{
					//display question chosen and create answer actions
					NSMutableArray* answers = [[NSMutableArray alloc] init];
					for(NSString* answer in chosenQuestion.answers)
					{
						[actions setValue:[[[LGSAction alloc] initWithType:@"answer" andValue:answer] autorelease] forKey:answer];
						[answers addObject:[[@"#" stringByAppendingString:answer] stringByAppendingString:@"#"]];
					}
					
					[boxViewMessages setObject:chosenQuestion.ask forKey:descriptionView];
					[boxViewMessages setObject:[answers componentsJoinedByString:@"\n"] forKey:actionView];
					
					[answers release];
					
					//save chosenQuestion for the next response action
					[mode setObject:chosenQuestion forKey:@"chosenQuestion"];
				}
				else
				{
					//no more question found for that kind of points
					NSString* description = @"@user, tu as déjà vu toutes les questions de ";
					description = [description stringByAppendingString:action.value];
					description = [description stringByAppendingString:@" talents pour "];
					description = [description stringByAppendingString:[mode objectForKey:@"city"]];
					
					[boxViewMessages setObject:description forKey:descriptionView];
					[boxViewMessages setObject:@"#Suite...#" forKey:actionView];
					
					[actions setValue:[[[LGSAction alloc] initWithType:@"goCard" andValue:[mode objectForKey:@"cardReturnId"]] autorelease] forKey:@"Suite..."];
				}
			}
			else if([action.type isEqualToString:@"answer"] && [[mode objectForKey:@"mode"] intValue] == LGSGameModeQuestion)
			{
				NSArray* responseSounds = nil;
				LGSAnswerResult result = [user answer:action.value forQuestion:[mode objectForKey:@"chosenQuestion"] andCharacter:[mode objectForKey:@"character"] inCity:[mode objectForKey:@"city"]];
				
				if(result.isValid)
				{
					responseSounds = [NSArray arrayWithObjects:@"juste1", @"juste2", @"juste3", @"juste4", @"juste5", @"juste6", @"juste7", nil];
					NSString* description = @"Bravo, @user !\n«";
					description = [description stringByAppendingString:result.validAnswer];
					description = [description stringByAppendingString:@"» est en effet la bonne réponse.\nJe t'accorde donc les "];
					description = [description stringByAppendingString:[[NSNumber numberWithInt:result.points] stringValue]];
					description = [description stringByAppendingString:@" Talents que tu mérites."];
					
					[boxViewMessages setObject:description forKey:descriptionView];
				}
				else
				{
					responseSounds = [NSArray arrayWithObjects:@"faux1", @"faux2", @"faux3", @"faux4", @"faux5", @"faux6", @"faux7", nil];
					NSString* description = @"Non, tu fais erreur, @user.\nUne bonne réponse était: «";
					description = [description stringByAppendingString:result.validAnswer];
					description = [description stringByAppendingString:@"»"];
					if(result.points < 0)
					{
						description = [description stringByAppendingString:@"\nJe te retire un Talent."];
					}
					
					[boxViewMessages setObject:description forKey:descriptionView];
				}
				
				NSString* responseSound = [responseSounds objectAtIndex:random() % [responseSounds count]];
				[soundManager loadAndPlaySound:[data soundDatasForKey:responseSound] loop:FALSE];
				
				[boxViewMessages setObject:@"#Suite...#" forKey:actionView];
				[actions setValue:[[[LGSAction alloc] initWithType:@"goCard" andValue:[mode objectForKey:@"cardReturnId"]] autorelease] forKey:@"Suite..."];
			}
		}
	}
	[allActions release];

	//custom actions on current action
	[self lgsCustomActions:LGSGameActionCurrent currentAction:currentAction];

	[self refreshTextViews];
}

-(void) refreshTextViews
{
	//update and replace keywords in boxviews
	for(LGSBoxView* boxView in boxViewMessages)
	{
		NSString* textValue = [boxViewMessages objectForKey:boxView];
		textValue = [textValue stringByReplacingOccurrencesOfString:@"@user" withString:user.name];
		textValue = [textValue stringByReplacingOccurrencesOfString:@"@gold" withString:[[NSNumber numberWithInteger:user.gold] stringValue]];
		textValue = [textValue stringByReplacingOccurrencesOfString:@"@pieceor" withString:user.gold > 1 ? @"pièces d'or":@"pièce d'or"];
		NSInteger totalPoints = 0;
		for(NSString* city in user.points)
		{
			totalPoints += [[user.points objectForKey:city] integerValue];
			
			NSString* pointKey = [@"@point" stringByAppendingString:city];
			NSString* talentKey = [@"@talent" stringByAppendingString:city];
			
			textValue = [textValue stringByReplacingOccurrencesOfString:pointKey withString:[[user.points objectForKey:city] stringValue]];
			textValue = [textValue stringByReplacingOccurrencesOfString:talentKey withString:[[user.points objectForKey:city] intValue] > 1 ? @"talents":@"talent"];
		}
		textValue = [textValue stringByReplacingOccurrencesOfString:@"@totalPoints" withString:[[NSNumber numberWithInteger:totalPoints] stringValue]];

		[boxView setTextValue:textValue];
	}
}

/**
 * custom action, that depends on card id
 * no time to make a perfect and generic action catcher!
 * so all custom actions are grouped here
 */
-(void) lgsCustomActions:(LGSGameAction) actionEvent currentAction:(NSString*) currentAction
{
	LGSSoundManager* soundManager = [LGSSoundManager sharedSoundManager];

	switch(actionEvent)
	{
		case LGSGameActionOpenCard :
		  if([user.cardID isEqualToString:@"4101"] || [user.cardID isEqualToString:@"5535"] || [user.cardID isEqualToString:@"2149"]  || [user.cardID isEqualToString:@"14986"]
			 || [user.cardID isEqualToString:@"13563"] || [user.cardID isEqualToString:@"9383"] || [user.cardID isEqualToString:@"13968"] || [user.cardID isEqualToString:@"7004"]
			 || [user.cardID isEqualToString:@"5079"] || [user.cardID isEqualToString:@"7367"] || [user.cardID isEqualToString:@"9464"] || [user.cardID isEqualToString:@"7548"]
			 || [user.cardID isEqualToString:@"9635"] || [user.cardID isEqualToString:@"7872"] || [user.cardID isEqualToString:@"4269"] || [user.cardID isEqualToString:@"11594"]
			 || [user.cardID isEqualToString:@"3901"] || [user.cardID isEqualToString:@"5463"] || [user.cardID isEqualToString:@"5683"] || [user.cardID isEqualToString:@"3515"]
			 || [user.cardID isEqualToString:@"4519"] || [user.cardID isEqualToString:@"4710"])
		  {
			  NSInteger nbStepsCat = [[user.adventures objectForKey:@"nbStepsCat"] integerValue];
			  if(nbStepsCat > 0)
			  {
				  [user.adventures setObject:[NSNumber numberWithInteger:nbStepsCat - 1] forKey:@"nbStepsCat"];
				  
				  if(rand() % 3 == 0)
				  {
					  [boxViewMessages setObject:@"Les puces de ce satané chat vous dévorent. Cela vous démange sur tout le corps. Allez-vous finir par vous en débarrasser ?" forKey:msgView];
					  [msgView show];
				  }
			  }
		  }
			
		  if([user.cardID isEqualToString:@"4651"])
		  {
			  [soundManager loadAndPlaySound:[data soundDatasForKey:@"oiseau"] loop:TRUE];
		  }
		  else if([user.cardID isEqualToString:@"5725"])
		  {
			  [soundManager loadAndPlaySound:[data soundDatasForKey:@"clochettes"] loop:NO];
		  }
		  else if([user.cardID isEqualToString:@"11322"])
		  {
			  [soundManager loadAndPlaySound:[data soundDatasForKey:@"fermeporte"] loop:NO];
			  if([[user.objects objectForKey:@"atlas"] boolValue])
			  {
				  NSString* actionValue = [boxViewMessages objectForKey:actionView];
				  actionValue = [actionValue stringByAppendingString:@"\n#proposer votre atlas au sage.#"];
				  [boxViewMessages setObject:actionValue forKey:actionView];
			  }
		  }
		  else if([user.cardID isEqualToString:@"4929"])
		  {
			  if(![[user.adventures objectForKey:@"lueur_pepite"] boolValue])
			  {
				  NSString* description = [boxViewMessages objectForKey:descriptionView];
				  description = [description stringByReplacingOccurrencesOfString:@"Une vive lueur sur le bord du chemin attire votre attention. " withString:@""];
				  [boxViewMessages setObject:description forKey:descriptionView];
				  
				  NSString* action = [boxViewMessages objectForKey:actionView];
				  action = [action stringByReplacingOccurrencesOfString:@"\\n#examiner cette lueur.#" withString:@""];
				  [boxViewMessages setObject:action forKey:actionView];
			  }
		  }
		  else if([user.cardID isEqualToString:@"10279"])
		  {
			  [soundManager loadAndPlaySound:[data soundDatasForKey:@"coucou_boucle"] loop:NO];
		  }
		  else if([user.cardID isEqualToString:@"22568"])
		  {
			  [soundManager loadAndPlaySound:[data soundDatasForKey:@"grincements_armoire"] loop:NO];
			  
			  [user.objects setObject:[NSNumber numberWithBool:YES] forKey:@"sac_or"];
			  [user setGold:(user.gold + 20)];
		  }
		  else if([user.cardID isEqualToString:@"22179"])
		  {
			  [soundManager loadAndPlaySound:[data soundDatasForKey:@"grincements_coffre"] loop:NO];
		  }
		  else if([user.cardID isEqualToString:@"9819"])
		  {
			  [soundManager loadAndPlaySound:[data soundDatasForKey:@"corbeau_boucle"] loop:YES];
		  }
		  else if([user.cardID isEqualToString:@"19631"])
		  {
			  if([[user.objects objectForKey:@"pommes"] boolValue])
			  {
				  [soundManager loadAndPlaySound:[data soundDatasForKey:@"chute"] loop:NO];
				  [user.objects setObject:[NSNumber numberWithBool:NO] forKey:@"pommes"];
				  
				  NSString* msgValue = @"";
				  msgValue = [msgValue stringByAppendingString:@"En entrant dans l'auberge, vous trébuchez et le contenu de votre sac se répand sur le sol. Les pommes que vous avez cueillies"];
				  msgValue = [msgValue stringByAppendingString:@" roulent sur le sol. A leur vue, le patron de l'auberge se met en colère et vous traite de voleur."];
				  msgValue = [msgValue stringByAppendingString:@" En effet, ces pommes proviennent de son verger et vous les avez cueillies sans autorisation."];
				  msgValue = [msgValue stringByAppendingString:@" Vous vous sortez de ce mauvais pas en "];
				  
				  if(user.gold > 1)
				  {
					  msgValue = [msgValue stringByAppendingString:@"lui rendant les pommes accompagnées d'une pièce d'or."];
					  [user setGold:(user.gold - 1)];
				  }
				  else
				  {
					  msgValue = [msgValue stringByAppendingString:@"lui rendant les pommes responsables de sa colère."];
				  }
				  
				  [boxViewMessages setObject:msgValue forKey:msgView];
				  [msgView show];
			  }
		  }
		  else if([user.cardID isEqualToString:@"20556"] || [user.cardID isEqualToString:@"7367"])
		  {
			  [soundManager loadAndPlaySound:[data soundDatasForKey:@"mouette_boucle"] loop:YES];
		  }
		  else if([user.cardID isEqualToString:@"27845"])
		  {
			  [soundManager loadAndPlaySound:[data soundDatasForKey:@"ermite"] loop:NO];
			  if(![[user.objects objectForKey:@"pommes"] boolValue])
			  {
				  NSString* action = [boxViewMessages objectForKey:actionView];
				  action = [action stringByReplacingOccurrencesOfString:@"\\n#donner vos pommes à l'ermite.#" withString:@""];
				  [boxViewMessages setObject:action forKey:actionView];
			  }
		  }
		  else if([user.cardID isEqualToString:@"31118"])
		  {
			  [soundManager loadAndPlaySound:[data soundDatasForKey:@"brasse_boucle"] loop:YES];
			  
			  NSString* msgValue = @"";
			  msgValue = [msgValue stringByAppendingString:@"La rivière est très agitée. Vous êtes entraîné par un courant furieux. Plusieurs fois,"];
			  msgValue = [msgValue stringByAppendingString:@" vous vous croyez perdu. Heureusement, les cours de natation que vous avez suivis,"];
			  msgValue = [msgValue stringByAppendingString:@" pourtant avec réticence, au monastère, vous permettent de surnager sans trop de dommage."];
			  
			  if(user.gold > 1)
			  {
				  [user setGold:(user.gold / 2)];
				  msgValue = [msgValue stringByAppendingString:@" Pendant que vous nagez, vous sentez que vous perdez une partie de vos pièces d'or."];
			  }
			  
			  [boxViewMessages setObject:msgValue forKey:msgView];
			  [msgView show];
		  }
		  else if([user.cardID isEqualToString:@"3573"])
		  {
			  [soundManager loadAndPlaySound:[data soundDatasForKey:@"oiseaux_boucle"] loop:YES];
		  }
		  else if([user.cardID isEqualToString:@"4548"])
		  {
			  if([[user.objects objectForKey:@"pepite"] boolValue])
			  {
				  NSString* action = [boxViewMessages objectForKey:actionView];
				  action = [action stringByAppendingString:@"\\n#montrer votre pépite au joaillier.#"];
				  [boxViewMessages setObject:action forKey:actionView];
			  }
			  else if(![[user.objects objectForKey:@"collier"] boolValue])
			  {
				  NSString* action = [boxViewMessages objectForKey:actionView];
				  action = [action stringByAppendingString:@"\\n#acheter un collier.#"];
				  [boxViewMessages setObject:action forKey:actionView];
			  }
		  }
		  else if([user.cardID isEqualToString:@"4686"])
		  {
			  if(user.gold == 0)
			  {
				  NSString* action = [boxViewMessages objectForKey:actionView];
				  action = [action stringByReplacingOccurrencesOfString:@"\\n#donner une pièce d'or#\\n#à la servante.#" withString:@""];
				  [boxViewMessages setObject:action forKey:actionView];
			  }
		  }
		  else if([user.cardID isEqualToString:@"5261"])
		  {
			  [soundManager loadAndPlaySound:[data soundDatasForKey:@"rires_boucle"] loop:YES];
		  }
		  else if([user.cardID isEqualToString:@"7100"])
		  {
			  if(user.gold == 0 || [[user.objects objectForKey:@"bouteille"] boolValue])
			  {
				  NSString* action = [boxViewMessages objectForKey:actionView];
				  action = [action stringByAppendingString:@"\\n#acheter une bouteille de vin.#"];
				  [boxViewMessages setObject:action forKey:actionView];
			  }
		  }
		  else if([user.cardID isEqualToString:@"82770"])
		  {
			  [soundManager loadAndPlaySound:[data soundDatasForKey:@"fermeporte"] loop:NO];
			  if(![[user.objects objectForKey:@"lexique"] boolValue])
			  {
				  NSString* action = [boxViewMessages objectForKey:actionView];
				  action = [action stringByReplacingOccurrencesOfString:@"\\n#proposer votre lexique au prêtre.#" withString:@""];
				  [boxViewMessages setObject:action forKey:actionView];
			  }
		  }
		  else if([user.cardID isEqualToString:@"6197"])
		  {
			  [soundManager loadAndPlaySound:[data soundDatasForKey:@"haltela"] loop:NO];
		  }
		  else if([user.cardID isEqualToString:@"7855"])
		  {
			  NSString* description = @"";
			  
			  if([[user.points objectForKey:@"Matem"] intValue] > 20)
			  {
				  description = @"Vous avez @pointMatem @talentMatem. Cela vous permet d'entrer dans la demeure de Matica.";
				  
				  NSString* action = [boxViewMessages objectForKey:actionView];
				  action = [action stringByAppendingString:@"\\n#Entrer dans la demeure.#"];
				  [boxViewMessages setObject:action forKey:actionView];
			  }
			  else
			  {
				  description = @"Vous n'avez que @pointMatem @talentMatem. Cela n'est pas suffisant pour entrer dans la demeure de Matica.";
			  }

			  
			  [boxViewMessages setObject:description forKey:descriptionView];
		  }
		  else if([user.cardID isEqualToString:@"9150"])
		  {
			  [soundManager loadAndPlaySound:[data soundDatasForKey:@"flute2"] loop:NO];
		  }
		  else if([user.cardID isEqualToString:@"8027"])
		  {
			  if(![[user.objects objectForKey:@"fleurs"] boolValue])
			  {
				  NSString* action = [boxViewMessages objectForKey:actionView];
				  action = [action stringByReplacingOccurrencesOfString:@"\\n#Donner vos fleurs#\\n#à la dame de la fenêtre.#" withString:@""];
				  [boxViewMessages setObject:action forKey:actionView];
			  }
		  }
		  else if([user.cardID isEqualToString:@"9432"] || [user.cardID isEqualToString:@"9627"] || [user.cardID isEqualToString:@"10567"]
				  || [user.cardID isEqualToString:@"11590"] || [user.cardID isEqualToString:@"12941"] || [user.cardID isEqualToString:@"7004"]
				  || [user.cardID isEqualToString:@"10308"] || [user.cardID isEqualToString:@"11340"] || [user.cardID isEqualToString:@"15930"])  
		  {
			  [soundManager loadAndPlaySound:[data soundDatasForKey:@"seagulls_boucle"] loop:YES];
		  }
		  else if([user.cardID isEqualToString:@"13183"])
		  {
			  [soundManager loadAndPlaySound:[data soundDatasForKey:@"aaaah"] loop:NO];
			  if(user.gold == 0)
			  {
				  NSString* action = [boxViewMessages objectForKey:actionView];
				  action = [action stringByReplacingOccurrencesOfString:@"\\n#donner une pièce d'or au pêcheur#\\n#pour le réconforter.#" withString:@""];
				  [boxViewMessages setObject:action forKey:actionView];
			  }
		  }
		  else if([user.cardID isEqualToString:@"15565"])
		  {
			  [soundManager loadAndPlaySound:[data soundDatasForKey:@"goutte"] loop:YES];
			  
			  if(![[user.objects objectForKey:@"joncs"] boolValue])
			  {
				  NSString* action = [boxViewMessages objectForKey:actionView];
				  action = [action stringByReplacingOccurrencesOfString:@"\\n#confectionner une torche#\\n#avec vos joncs.#" withString:@""];
				  [boxViewMessages setObject:action forKey:actionView];
			  }
		  }
		  else if([user.cardID isEqualToString:@"13877"])
		  {
			  NSString* description = @"";
			  
			  if([[user.points objectForKey:@"Histora"] intValue] > 20)
			  {
				  description = @"Vous avez @pointHistora @talentHistora. Cela vous permet d'entrer dans la demeure de Kronolos.";
				  
				  NSString* action = [boxViewMessages objectForKey:actionView];
				  action = [action stringByAppendingString:@"\\n#Entrer dans la demeure.#"];
				  [boxViewMessages setObject:action forKey:actionView];
			  }
			  else
			  {
				  description = @"Vous n'avez que @pointHistora @talentHistora. Cela n'est pas suffisant pour entrer dans la demeure de Kronolos.";
			  }
			  
			  
			  [boxViewMessages setObject:description forKey:descriptionView];
		  }
		  else if([user.cardID isEqualToString:@"15213"])
		  {
			  [soundManager loadAndPlaySound:[data soundDatasForKey:@"leroi"] loop:NO];
		  }
		  else if([user.cardID isEqualToString:@"10877"])
		  {
			  [soundManager loadAndPlaySound:[data soundDatasForKey:@"oiseau"] loop:YES];
		  }
		  else if([user.cardID isEqualToString:@"12274"])
		  {
			  [soundManager loadAndPlaySound:[data soundDatasForKey:@"piu2"] loop:YES];
		  }
		  else if([user.cardID isEqualToString:@"13399"])
		  {
			  [soundManager loadAndPlaySound:[data soundDatasForKey:@"morceau_flute"] loop:YES];
		  }
		  else if([user.cardID isEqualToString:@"13659"])
		  {
			  [soundManager loadAndPlaySound:[data soundDatasForKey:@"enclume"] loop:YES];
		  }
		  else if([user.cardID isEqualToString:@"15762"])
		  {
			  [soundManager loadAndPlaySound:[data soundDatasForKey:@"goutte"] loop:YES];
		  }
		  else if([user.cardID isEqualToString:@"2990"] || [user.cardID isEqualToString:@"3814"] || [user.cardID isEqualToString:@"5204"] || [user.cardID isEqualToString:@"7729"])
		  {
			  [soundManager loadAndPlaySound:[data soundDatasForKey:@"fete"] loop:YES];
		  }
		  else if([user.cardID isEqualToString:@"4269"] || [user.cardID isEqualToString:@"11594"])
		  {
			  [soundManager loadAndPlaySound:[data soundDatasForKey:@"coq"] loop:YES];
		  }
		  else if([user.cardID isEqualToString:@"6640"])
		  {
			  [soundManager loadAndPlaySound:[data soundDatasForKey:@"portes_eglise"] loop:NO];
		  }
		  else if([user.cardID isEqualToString:@"9635"])
		  {
			  if(![[user.objects objectForKey:@"boulier"] boolValue])
			  {
				  NSString* action = [boxViewMessages objectForKey:actionView];
				  action = [action stringByReplacingOccurrencesOfString:@"\\n#Proposer votre boulier au notable.#" withString:@""];
				  [boxViewMessages setObject:action forKey:actionView];
			  }
		  }
		  else if([user.cardID isEqualToString:@"9914"])
		  {
			  if(user.gold == 0)
			  {
				  NSString* action = [boxViewMessages objectForKey:actionView];
				  action = [action stringByReplacingOccurrencesOfString:@"\\n#donner une pièce d'or#\\n#à la vieille femme." withString:@""];
				  [boxViewMessages setObject:action forKey:actionView];
			  }
		  }
		  else if([user.cardID isEqualToString:@"5974"])
		  {
			  NSString* description = @"";
			  
			  if([[user.points objectForKey:@"Litter"] intValue] > 20)
			  {
				  description = @"Vous avez @pointLitter @talentLitter. Cela vous permet d'entrer dans la demeure de Lingus.";
				  
				  NSString* action = [boxViewMessages objectForKey:actionView];
				  action = [action stringByAppendingString:@"\\n#Entrer dans la demeure.#"];
				  [boxViewMessages setObject:action forKey:actionView];
			  }
			  else
			  {
				  description = @"Vous n'avez que @pointLitter @talentLitter. Cela n'est pas suffisant pour entrer dans la demeure de Lingus.";
			  }
			  
			  
			  [boxViewMessages setObject:description forKey:descriptionView];
		  }
		  else if([user.cardID isEqualToString:@"8034"])
		  {
			  [soundManager loadAndPlaySound:[data soundDatasForKey:@"grillejardin"] loop:NO];
			  if(![[user.objects objectForKey:@"lait"] boolValue])
			  {
				  NSString* action = [boxViewMessages objectForKey:actionView];
				  action = [action stringByReplacingOccurrencesOfString:@"\\n#Vendre votre pot de lait.#" withString:@""];
				  [boxViewMessages setObject:action forKey:actionView];
			  }
		  }
		  else if([user.cardID isEqualToString:@"8277"])
		  {
			  [soundManager loadAndPlaySound:[data soundDatasForKey:@"clochettes2"] loop:NO];
			  if(![[user.objects objectForKey:@"herbes"] boolValue])
			  {
				  NSString* action = [boxViewMessages objectForKey:actionView];
				  action = [action stringByReplacingOccurrencesOfString:@"\\n#montrer vos herbes.#" withString:@""];
				  [boxViewMessages setObject:action forKey:actionView];
			  }
		  }
		  else if([user.cardID isEqualToString:@"11876"])
		  {
			  if(![[user.objects objectForKey:@"fleurs"] boolValue])
			  {
				  NSString* action = [boxViewMessages objectForKey:actionView];
				  action = [action stringByReplacingOccurrencesOfString:@"\\n#Donner vos fleurs à la nonne.#" withString:@""];
				  [boxViewMessages setObject:action forKey:actionView];
			  }
		  }
		  else if([user.cardID isEqualToString:@"25754"])
		  {
			  if(![[user.objects objectForKey:@"lait"] boolValue])
			  {
				  NSString* action = [boxViewMessages objectForKey:actionView];
				  action = [action stringByReplacingOccurrencesOfString:@"\\n#donner votre pot de lait#\\n#à la cuisinière.#" withString:@""];
				  [boxViewMessages setObject:action forKey:actionView];
			  }
		  }
		  break;

		case LGSGameActionCurrent:
		  if([user.cardID isEqualToString:@"5725"])
		  {
			  if([currentAction isEqualToString:@"commerçant"])
			  {
				  NSString* msgValue = @"C'est toi, @user";

				  NSNumber* nbAdviceBoutique = [user.adventures objectForKey:@"nbAdviceBoutique"];
				  if([nbAdviceBoutique intValue] < 4)
				  {
					  msgValue = [msgValue stringByAppendingString:@"?\nJe peux te dire qu'"];

					  NSArray* msgKeysChoice = [NSArray arrayWithObjects:@"1", @"2", @"3", nil];
					  NSArray* msgValuesChoice = [NSArray arrayWithObjects:
												  @"un lexique te sera bien utile dans la ville de Litter.",
												  @"un boulier te sera bien utile dans la ville de Matem.",
												  @"un atlas te sera bien utile dans la ville d'Histora.", nil];
					  NSDictionary* msgChoice = [NSDictionary dictionaryWithObjects:msgValuesChoice forKeys:msgKeysChoice];

					  msgValue = [msgValue stringByAppendingString:[msgChoice objectForKey:[nbAdviceBoutique stringValue]]];

					  [user.adventures setValue:[NSNumber numberWithInteger:[nbAdviceBoutique intValue] + 1] forKey:@"nbAdviceBoutique"];

					  if(!([[user.objects objectForKey:@"lexique"] boolValue] && [[user.objects objectForKey:@"boulier"] boolValue] && [[user.objects objectForKey:@"atlas"] boolValue]))
					  {
						  msgValue = [msgValue stringByAppendingString:@"\nQue vas-tu m'acheter ?"];
					  }
				  }
				  else
				  {
					  msgValue = [msgValue stringByAppendingString:@".\nTu m'as déjà suffisamment dérangé comme cela ! Finiras-tu par me laisser travailler en paix ?"];

					  if(!([[user.objects objectForKey:@"lexique"] boolValue] && [[user.objects objectForKey:@"boulier"] boolValue] && [[user.objects objectForKey:@"atlas"] boolValue]))
					  {
						  msgValue = [msgValue stringByAppendingString:@"\nAchète-moi plutôt quelque chose !"];
					  }
				  }

				  [boxViewMessages setObject:msgValue forKey:msgView];
				  [msgView show];
			  }
			  else if([currentAction isEqualToString:@"lexique"] || [currentAction isEqualToString:@"boulier"] || [currentAction isEqualToString:@"atlas"])
			  {
				  NSArray* pricesKeys = [NSArray arrayWithObjects:@"lexique", @"boulier", @"atlas", nil];
				  NSArray* pricesValues = [NSArray arrayWithObjects:
										   [NSNumber numberWithInt:5],
										   [NSNumber numberWithInt:4],
										   [NSNumber numberWithInt:3], nil];
				  NSDictionary* prices = [NSDictionary dictionaryWithObjects:pricesValues forKeys:pricesKeys];

				  if([[user.objects valueForKey:currentAction] boolValue])
				  {
					  //sell
					  [user.objects setValue:[NSNumber numberWithBool:NO] forKey:currentAction];
					  [user setGold:user.gold + [[prices objectForKey:currentAction] intValue]];
				  }
				  else if(user.gold - [[prices objectForKey:currentAction] intValue] >= 0)
				  {
					  //buy
					  [user.objects setValue:[NSNumber numberWithBool:YES] forKey:currentAction];
					  [user setGold:user.gold - [[prices objectForKey:currentAction] intValue]];
				  }
			  }

			  //update actionView 'buy' or 'sell'
			  NSString* actionTextView = @"";
			  actionTextView = [actionTextView stringByAppendingString:[[user.objects objectForKey:@"lexique"] boolValue] ?  @"#revendre le lexique.#\n":@"#acheter un lexique.#\n"];
			  actionTextView = [actionTextView stringByAppendingString:[[user.objects objectForKey:@"boulier"] boolValue] ?  @"#revendre le boulier.#\n":@"#acheter un boulier.#\n"];
			  actionTextView = [actionTextView stringByAppendingString:[[user.objects objectForKey:@"atlas"] boolValue] ?  @"#revendre l'atlas.#\n":@"#acheter un atlas.#\n"];
			  actionTextView = [actionTextView stringByAppendingString:@"#parler au commerçant.#\n#sortir de la boutique.#"];
			  [boxViewMessages setObject:actionTextView forKey:actionView];
		}
		else if([user.cardID isEqualToString:@"5535"] || [user.cardID isEqualToString:@"9819"])
		{
			if([currentAction isEqualToString:@"fleurs"])
			{
				NSString* msgValue = @"";
				
				if([[user.objects objectForKey:@"fleurs"] boolValue])
				{
					msgValue = @"Il y a déjà suffisamment de fleurs dans votre sac ! Elles vont finir par se faner.";
				}
				else
				{
					msgValue = @"Vous passez un agréable moment dans les champs à choisir les plus jolies fleurs que vous ayez vues depuis bien longtemps. Leurs couleurs et leur odeur vous enchantent.";
					[user.objects setValue:[NSNumber numberWithBool:YES] forKey:@"fleurs"];
				}
				
				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];
			}
		}
		else if([user.cardID isEqualToString:@"11322"])
		{
			if([currentAction isEqualToString:@"atlas_sage"] && [[user.objects objectForKey:@"atlas"] boolValue])
			{
				NSString* msgValue = @"";
				if([[user.adventures objectForKey:@"atlas_sage"] boolValue])
				{
					msgValue = [msgValue stringByAppendingString:@"Vous n'avez guère de mémoire ! Vous avez déjà vendu un atlas "];
					msgValue = [msgValue stringByAppendingString:@"semblable au sage il n'y a pas si longtemps. Il vous explique qu'un "];
					msgValue = [msgValue stringByAppendingString:@"deuxième exemplaire du même ouvrage ne présente guère d'intérêt "];
					msgValue = [msgValue stringByAppendingString:@"pour lui et vous conseille de garder ce nouvel atlas pour un "];
					msgValue = [msgValue stringByAppendingString:@"meilleur usage. Il pense d'ailleurs que cela pourrait vous "];
					msgValue = [msgValue stringByAppendingString:@"servir sur l'île d'Histora."];
				}
				else
				{
					msgValue = [msgValue stringByAppendingString:@"Votre atlas intéresse le sage au plus haut point. Il vous en "];
					msgValue = [msgValue stringByAppendingString:@"donne 5 pièces d'or, ce qui vous fait un bon bénéfice. Il formule "];
					msgValue = [msgValue stringByAppendingString:@"l'espoir que cet atlas ne vous manquera pas dans le reste de votre périple."];
					
					[user.objects setValue:[NSNumber numberWithBool:NO] forKey:@"atlas"];
					[user setGold:user.gold + 5];
					[user.adventures setValue:[NSNumber numberWithBool:YES] forKey:@"atlas_sage"];
					
					NSString* actionValue = [boxViewMessages objectForKey:actionView];
					actionValue = [actionValue stringByReplacingOccurrencesOfString:@"\n#proposer votre atlas au sage.#" withString:@""];
					[boxViewMessages setObject:actionValue forKey:actionView];
				}

				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];
			}
		}
		else if([user.cardID isEqualToString:@"4929"])
		{
			if([currentAction isEqualToString:@"lueur"] && [[user.adventures objectForKey:@"lueur_pepite"] boolValue])
			{
				[user.adventures setValue:[NSNumber numberWithBool:NO] forKey:@"lueur_pepite"];
				[user.objects setValue:[NSNumber numberWithBool:YES] forKey:@"pepite"];
				
				NSString* description = [boxViewMessages objectForKey:descriptionView];
				description = [description stringByReplacingOccurrencesOfString:@"Une vive lueur sur le bord du chemin attire votre attention. " withString:@""];
				[boxViewMessages setObject:description forKey:descriptionView];
				
				NSString* action = [boxViewMessages objectForKey:actionView];
				action = [action stringByReplacingOccurrencesOfString:@"\\n#examiner cette lueur.#" withString:@""];
				[boxViewMessages setObject:action forKey:actionView];
				
				NSString* msgValue = @"En fouillant bien le fossé, vous découvrez ce qui avait attiré votre attention : une pépite !";
				msgValue = [msgValue stringByAppendingString:@" Cette découverte vous paraît suffisamment intéressante et vous la mettez dans votre sac."];
				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];
			}
		}
		else if([user.cardID isEqualToString:@"15536"])
		{
			if([currentAction isEqualToString:@"lit"])
			{
				NSString* msgValue = @"A peine allongé, vous vous endormez. Vous êtes victime d'un affreux cauchemar dans lequel un professeur sadique vous oblige";
				msgValue = [msgValue stringByAppendingString:@" à accomplir un périlleux voyage dans un pays imaginaire."];
				msgValue = [msgValue stringByAppendingString:@" Heureusement, l'air frais vous réveille et vous réalisez que tout ceci n'était qu'un rêve."];
				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];
			}
			else if([currentAction isEqualToString:@"armoire"])
			{
				if([[user.objects objectForKey:@"sac_or"] boolValue])
				{
					NSString* msgValue = @"Vous avez déjà fouillé cette armoire et vous avez déjà pris le sac d'or qui s'y trouve. Il n'y a plus rien à l'intérieur.";
					msgValue = [msgValue stringByAppendingString:@"\nVous n'espériez tout de même pas en trouver un deuxième, non ?"];
					[boxViewMessages setObject:msgValue forKey:msgView];
					[msgView show];
				}
				else
				{
					[self goCard:@"22568"];
				}
			}
			else if([currentAction isEqualToString:@"coffre"])
			{
				if([[user.adventures objectForKey:@"gnome"] intValue] > 1)
				{
					NSString* msgValue = @"Vous avez fait fuir le gnome ! Ne vous en souvenez-vous pas ? Il aurait fallu être un peu plus gentil avec lui.";
					msgValue = [msgValue stringByAppendingString:@" Maintenant, il n'y a plus personne dans le coffre. Il est donc parfaitement inutile de vous escrimer dessus."];
					[boxViewMessages setObject:msgValue forKey:msgView];
					[msgView show];
				}
				else
				{
					[self goCard:@"22179"];
				}

			}
		}
		else if([user.cardID isEqualToString:@"22179"])
		{
			if([currentAction isEqualToString:@"saisir_gnome"])
			{
				NSInteger nbSaisie = [[user.adventures objectForKey:@"gnome"] intValue];
				NSString* description = @"";
				
				if(nbSaisie > 0)
				{
					[soundManager loadAndPlaySound:[data soundDatasForKey:@"pascourant"] loop:NO];
					
					description = [description stringByAppendingString:@"Cette fois-ci, le gnome vous a vu arriver à temps, il s'est mis rapidement hors de votre portée, puis il s'est sauvé au plus"];
					description = [description stringByAppendingString:@" profond de la forêt environnante. Vous risquez de ne jamais le revoir !"];
					[boxViewMessages setObject:description forKey:descriptionView];
				}
				else if(nbSaisie == 0)
				{
					[soundManager loadAndPlaySound:[data soundDatasForKey:@"argn"] loop:NO];
					
					description = [description stringByAppendingString:@"Le gnome ne s'est pas laissé faire facilement ! Il vous a mordu le petit doigt pendant la bagarre.\nVous allez souffrir pendant "];
					description = [description stringByAppendingString:@"plusieurs heures. Il vaudrait mieux ne pas recommencer ce genre de plaisanteries !"];
					[boxViewMessages setObject:description forKey:descriptionView];
				}
				
				[user.adventures setObject:[NSNumber numberWithInteger:(nbSaisie+1)] forKey:@"gnome"];
				
				[boxViewMessages setObject:description forKey:descriptionView];
				[boxViewMessages setObject:@"#Suite...#" forKey:actionView];
				
				[actions setValue:[[[LGSAction alloc] initWithType:@"goCard" andValue:@"15536"] autorelease] forKey:@"Suite..."];
			}
		}
		else if([user.cardID isEqualToString:@"9383"])
		{
			if([currentAction isEqualToString:@"pommes"])
			{
				if([[user.objects objectForKey:@"pommes"] boolValue])
				{
					NSString* msgValue = @"Vous avez déjà plusieurs de ces pommes dans votre sac. Il n'est pas nécessaire de tout prendre !";
					[boxViewMessages setObject:msgValue forKey:msgView];
					[msgView show];
				}
				else
				{
					NSString* msgValue = @"Après avoir goûté un de ces merveilleux fruits, vous décidez d'en emporter avec vous pour le reste de votre périple. Vous mettez quelques pommes au fond de votre sac.";
					[boxViewMessages setObject:msgValue forKey:msgView];
					[msgView show];
					
					[user.objects setObject:[NSNumber numberWithBool:YES] forKey:@"pommes"];
				}
			}
		}
		else if([user.cardID isEqualToString:@"27845"])
		{
			if([currentAction isEqualToString:@"pommes_ermite"])
			{
				[user.objects setObject:[NSNumber numberWithBool:NO] forKey:@"pommes"];
				
				NSString* action = [boxViewMessages objectForKey:actionView];
				action = [action stringByReplacingOccurrencesOfString:@"\\n#donner vos pommes à l'ermite.#" withString:@""];
				[boxViewMessages setObject:action forKey:actionView];
				
				NSString* msgValue = @"Le vieil ermite vous remercie de votre don et range soigneusement les pommes dans un coin de sa grotte.";
				msgValue = [msgValue stringByAppendingString:@" Pour vous remercier de votre générosité, il vous promet de choisir parmi les questions les plus faciles"];
				msgValue = [msgValue stringByAppendingString:@" si vous décidez de tenter votre chance auprès de lui."];
				
				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];
			}
		}
		else if([user.cardID isEqualToString:@"31118"])
		{
			if([msgView isHidden] == YES)
			{
				[self goCard:@"2921"];
			}
		}
		else if([user.cardID isEqualToString:@"4548"])
		{
			if([currentAction isEqualToString:@"pepite_joaillier"])
			{
				[user.objects setValue:[NSNumber numberWithBool:NO] forKey:@"pepite"];
				[user.objects setValue:[NSNumber numberWithBool:YES] forKey:@"collier"];
				[user setGold:(user.gold + 3)];
				
				NSString* msgValue = @"Le joaillier confirme ce que vous pensiez : il s'agit bien d'une pépite d'or ! Elle semble d'ailleurs contenir une masse ";
				msgValue = [msgValue stringByAppendingString:@"importante du précieux métal. En échange, le joaillier vous remet"];
				msgValue = [msgValue stringByAppendingString:@" trois pièces d'or et un collier de pierres serties."];
				
				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];
				
				NSString* action = [boxViewMessages objectForKey:actionView];
				action = [action stringByReplacingOccurrencesOfString:@"\\n#montrer votre pépite au joaillier.#" withString:@""];
				[boxViewMessages setObject:action forKey:actionView];
			}
			else if([currentAction isEqualToString:@"acheter_collier"])
			{
				NSString* msgValue = @"";
				
				if(user.gold >= 2)
				{
					msgValue = [msgValue stringByAppendingString:@"Le joaillier vous montre une impressionnante collection de"];
					msgValue = [msgValue stringByAppendingString:@" superbes colliers de pierres serties qu'il a créés lui-même."];
					msgValue = [msgValue stringByAppendingString:@" vous en choisissez un, aux reflets argentés, que vous payez deux pièces d'or."];
					
					[user.objects setValue:[NSNumber numberWithBool:YES] forKey:@"collier"];
					[user setGold:(user.gold - 2)];
				}
				else
				{
					msgValue = [msgValue stringByAppendingString:@"Vous n'avez pas assez de pièces d'or pour cela."];
				}
				
				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];

				NSString* action = [boxViewMessages objectForKey:actionView];
				action = [action stringByReplacingOccurrencesOfString:@"\\n#acheter un collier.#" withString:@""];
				[boxViewMessages setObject:action forKey:actionView];
			}
			else if([currentAction isEqualToString:@"chat"])
			{
				NSString* msgValue = @"Miiiaaaahhhhhh !";
				
				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];
			}
			else if([currentAction isEqualToString:@"diplome"])
			{
				NSString* msgValue = @"Ceci est un diplôme du meilleur bijoutier de Matem. Aucun intérêt pour vous.";
				
				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];
			}
		}
		else if([user.cardID isEqualToString:@"4686"])
		{
			if([currentAction isEqualToString:@"pieceor_servante"] && user.gold >= 1)
			{
				[user setGold:(user.gold - 1)];
				
				NSString* msgValue = @"La servante vous remercie de votre générosité. Elle va pouvoir enfin s'acheter les bijoux dont elle rêvait et";
				msgValue = [msgValue stringByAppendingString:@" qu'elle a vu chez son voisin le joaillier. Pour vous remercier, elle vous "];
				msgValue = [msgValue stringByAppendingString:@"indique qu'on peut trouver un boulier dans la boutique qui "];
				msgValue = [msgValue stringByAppendingString:@"se trouve au sud de l'abbaye d'Encyclopia."];
				
				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];
				
				NSString* action = [boxViewMessages objectForKey:actionView];
				action = [action stringByReplacingOccurrencesOfString:@"\\n#donner une pièce d'or#\\n#à la servante.#" withString:@""];
				[boxViewMessages setObject:action forKey:actionView];
			}
			else if([currentAction isEqualToString:@"fenetre"])
			{
				NSString* msgValue = @"Par la fenêtre, vous voyez une place de Matem.";
				
				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];
			}
		}
		else if([user.cardID isEqualToString:@"7100"])
		{
			if([currentAction isEqualToString:@"acheter_bouteille"])
			{
				if(user.gold >= 2 && ![[user.objects objectForKey:@"bouteille"] boolValue])
				{
					[user setGold:(user.gold - 2)];
					[user.objects setObject:[NSNumber numberWithBool:YES] forKey:@"bouteille"];
					
					NSString* msgValue = @"Le patron de la taverne semble très surpris de voir un jeune moine lui faire une telle demande.";
					msgValue = [msgValue stringByAppendingString:@" Mais il ne peut plus refuser de vous vendre son vin lorsque vous"];
					msgValue = [msgValue stringByAppendingString:@" lui expliquez que ce n'est pas pour vous. Cela vous coûte 2 pièces d'or."];
					
					[boxViewMessages setObject:msgValue forKey:msgView];
					[msgView show];
					
					NSString* action = [boxViewMessages objectForKey:actionView];
					action = [action stringByReplacingOccurrencesOfString:@"\\n#acheter une bouteille de vin.#" withString:@""];
					[boxViewMessages setObject:action forKey:actionView];
				}
			}
			else if([currentAction isEqualToString:@"acheter_tonneau"])
			{
				NSString* msgValue = @"Une bouteille de vin suffira largement. Vous n'allez tout de même pas acheter un tonneau !";
				
				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];
			}
		}
		else if([user.cardID isEqualToString:@"82770"])
		{
			if([currentAction isEqualToString:@"vepres"])
			{
				[soundManager loadAndPlaySound:[data soundDatasForKey:@"deogratias"] loop:NO];
				
				NSString* msgValue = @"Vous assistez, avec votre habituel émerveillement, à l'office vespral. Les chants grégoriens qui l'accommpagnent sont d'une ";
				msgValue = [msgValue stringByAppendingString:@"pureté que vous avez rarement rencontrée. Lorsque le Deo Gratias "];
				msgValue = [msgValue stringByAppendingString:@"final rententit dans la grande église de Matem, vous avez les larmes aux yeux."];
				
				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];
			}
			else if([currentAction isEqualToString:@"lexique_prete"] && [[user.objects objectForKey:@"lexique"] boolValue])
			{
				if([[user.adventures objectForKey:@"lexique_prete"] boolValue])
				{
					NSString* msgValue = @"Vous n'avez guère de mémoire ! Vous avez déjà vendu un lexique semblable au prêtre. Un seul lexique lui suffit amplement et ";
					msgValue = [msgValue stringByAppendingString:@"il n'a vraiment pas besoin de ce deuxième ouvrage. Vous en "];
					msgValue = [msgValue stringByAppendingString:@"trouverez sûrement un meilleur usage. Allez donc voir à Litter."];
					
					[boxViewMessages setObject:msgValue forKey:msgView];
					[msgView show];
				}
				else
				{
					[user setGold:(user.gold + 5)];
					[user.objects setObject:[NSNumber numberWithBool:NO] forKey:@"lexique"];
					[user.adventures setObject:[NSNumber numberWithBool:YES] forKey:@"lexique_prete"];
					
					NSString* msgValue = @"Voilà qui va permettre au prêtre de vérifier les traductions de ses clercs.";
					msgValue = [msgValue stringByAppendingString:@" Il vous offre 5 pièces d'or de ce lexique. Vous faites une bonne affaire."];
					msgValue = [msgValue stringByAppendingString:@" Sauf, peut-être, si ce lexique vous est nécessaire ailleurs."];
					
					[boxViewMessages setObject:msgValue forKey:msgView];
					[msgView show];
					
					NSString* action = [boxViewMessages objectForKey:actionView];
					action = [action stringByReplacingOccurrencesOfString:@"\\n#proposer votre lexique au prêtre.#" withString:@""];
					[boxViewMessages setObject:action forKey:actionView];
				}
			}
		}
		else if([user.cardID isEqualToString:@"6197"])
		{
			if([currentAction isEqualToString:@"entrer_caserne"])
			{
				if([[user.objects objectForKey:@"bouteille"] boolValue])
				{
					[user.objects setObject:[NSNumber numberWithBool:NO] forKey:@"bouteille"];
					
					NSString* description = @"Le garde vous laisse passer en échange de votre bouteille de vin.\nBien entendu, vous ne devez pas en parler aux chevaliers !";
					[boxViewMessages setObject:description forKey:descriptionView];
					[boxViewMessages setObject:@"#Suite...#" forKey:actionView];
					
					[actions setValue:[[[LGSAction alloc] initWithType:@"goCard" andValue:@"7533"] autorelease] forKey:@"Suite..."];
				}
				else
				{
					NSString* msgValue = @"Le garde refuse de vous laisser passer. Vous essayez de parlementer avec lui mais il est inflexible car, dit-il, ";
					msgValue = [msgValue stringByAppendingString:@"les consignes que lui ont données les chevaliers sont très strictes."];
					msgValue = [msgValue stringByAppendingString:@" Par exemple, il n'a rien à boire pendant toute la durée de sa garde et cela lui est très pénible."];
					[boxViewMessages setObject:msgValue forKey:msgView];
					[msgView show];
				}
			}
		}
		else if([user.cardID isEqualToString:@"7533"])
		{
			if([currentAction isEqualToString:@"aaarghh"])
			{
				NSString* msgValue = @"Aaaarghh !";
				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];
			}
		}
		else if([user.cardID isEqualToString:@"7855"])
		{
			if([currentAction isEqualToString:@"retourner_entrer"])
			{
				if([[user.points objectForKey:@"Matem"] intValue] > 20)
				{
					[self goCard:@"9150"];
				}
				else
				{
					[self goCard:@"6581"];
				}
			}
		}
		else if([user.cardID isEqualToString:@"9150"])
		{
			if([currentAction isEqualToString:@"matica"])
			{
				NSString* msgValue = @"";
				
				if([[user.objects objectForKey:@"sablier"] boolValue])
				{
					msgValue = [msgValue stringByAppendingString:@"Ah, c'est toi, @user. Je vois que tu continues ta quête."];
					msgValue = [msgValue stringByAppendingString:@" Je n'ai malheureusement pas le temps de m'occuper de toi en ce"];
					msgValue = [msgValue stringByAppendingString:@" moment. Depuis que tu m'as apporté ce merveilleux boulier, je"];
					msgValue = [msgValue stringByAppendingString:@" travaille sans arrêter.\nBon courage, @user !"];
				}
				else if([[user.objects objectForKey:@"boulier"] boolValue])
				{
					msgValue = [msgValue stringByAppendingString:@"Bonjour, @user. Je vois que tu m'as apporté le boulier que"];
					msgValue = [msgValue stringByAppendingString:@" je cherchais depuis si longtemps.\nJe vais enfin "];
					msgValue = [msgValue stringByAppendingString:@"pouvoir terminer mes recherches !\nPour te récompenser,"];
					msgValue = [msgValue stringByAppendingString:@" je t'offre un talisman qui te permettra d'entrer dans l'abbaye d'Encyclopia."];
				}
				else
				{
					msgValue = [msgValue stringByAppendingString:@"Qui vient me déranger pendant mon travail ?"];
					msgValue = [msgValue stringByAppendingString:@"\nC'est toi, @user ! M'as-tu apporté l'objet que j'ai envoyé quérir ?"];
					msgValue = [msgValue stringByAppendingString:@"\nNon !?!\nAlors, ne reviens que lorsque tu l'auras trouvé !"];
				}

				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];
			}
			else if([currentAction isEqualToString:@"action_message"])
			{
				if([[user.objects objectForKey:@"sablier"] boolValue])
				{
					[self goCard:@"7855"];
				}
				else if([[user.objects objectForKey:@"boulier"] boolValue])
				{
					[user.objects setObject:[NSNumber numberWithBool:NO] forKey:@"boulier"];
					[user.objects setObject:[NSNumber numberWithBool:YES] forKey:@"sablier"];
					[self goCard:@"2183"];
				}
				else
				{
					[self goCard:@"7855"];
				}
			}
		}
		else if([user.cardID isEqualToString:@"8027"])
		{
			if([currentAction isEqualToString:@"parler_dame"])
			{
				NSString* msgValue = @"Bonjour mignon moinillon... Que la chance soit avec toi dans ta quête.";
				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];
			}
			else if([currentAction isEqualToString:@"caresser_chien"])
			{
				NSString* msgValue = @"Ce chien ne semble pas très propre. Méfiez-vous.";
				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];
			}
			else if([currentAction isEqualToString:@"fleurs_dame"])
			{
				NSString* msgValue = @"La dame est très flattée de l'hommage que vous lui rendez par ce magnifique bouquet de fleurs. Pour vous ";
				
				msgValue = [msgValue stringByAppendingString:@" remercier, elle vous recommande d'aller voir de sa part le chevalier"];
				msgValue = [msgValue stringByAppendingString:@" dans sa caserne. Elle vous précise que le garde à l'entrée se laisse"];
				msgValue = [msgValue stringByAppendingString:@" facilement soudoyer par une bouteille de vin."];
				
				if(user.gold < 2)
				{
					msgValue = [msgValue stringByAppendingString:@" De plus, elle vous donne 3 pièces d'or pour votre peine."];
					[user setGold:(user.gold + 3)];
				}
				
				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];
				
				[user.objects setObject:[NSNumber numberWithBool:NO] forKey:@"fleurs"];
				
				NSString* action = [boxViewMessages objectForKey:actionView];
				action = [action stringByReplacingOccurrencesOfString:@"\\n#Donner vos fleurs#\\n#à la dame de la fenêtre.#" withString:@""];
				[boxViewMessages setObject:action forKey:actionView];
			}
		}
		else if([user.cardID isEqualToString:@"5497"])
		{
			if([currentAction isEqualToString:@"pencher_rambarde"])
			{
				NSString* msgValue = @"Vue d'ici, l'île d'Histora paraît magnifique.";
				
				if([[user.objects objectForKey:@"lexique"] boolValue] || [[user.objects objectForKey:@"boulier"] boolValue] || [[user.objects objectForKey:@"atlas"] boolValue])
				{
					msgValue = [msgValue stringByAppendingString:@" Pour mieux voir, vous vous penchez un peu trop et vous vous apercevez "];
					msgValue = [msgValue stringByAppendingString:@"que votre sac s'est ouvert au-dessus du vide. En essayant de le ramener vers vous, vous voyez"];
					
					NSInteger objectsFallen = 0;
					NSString* tempMsgValue = @"";
					if([[user.objects objectForKey:@"lexique"] boolValue])
					{
						[user.objects setObject:[NSNumber numberWithBool:NO] forKey:@"lexique"];
						
						tempMsgValue = [tempMsgValue stringByAppendingString:@", votre lexique"];
						objectsFallen ++;
					}
					if([[user.objects objectForKey:@"boulier"] boolValue])
					{
						[user.objects setObject:[NSNumber numberWithBool:NO] forKey:@"boulier"];
						
						tempMsgValue = [tempMsgValue stringByAppendingString:@", votre boulier"];
						objectsFallen ++;
					}
					if([[user.objects objectForKey:@"atlas"] boolValue])
					{
						[user.objects setObject:[NSNumber numberWithBool:NO] forKey:@"atlas"];
						
						tempMsgValue = [tempMsgValue stringByAppendingString:@", votre atlas"];
						objectsFallen ++;
					}
					
					if(objectsFallen == 1)
					{
						tempMsgValue = [tempMsgValue stringByReplacingOccurrencesOfString:@"," withString:@""];
					}
					else if(objectsFallen == 2)
					{
						tempMsgValue = [tempMsgValue stringByReplacingOccurrencesOfString:@"," withString:@" et"];
						tempMsgValue = [tempMsgValue stringByReplacingOccurrencesOfString:@" et" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, 3)];
					}
					else if(objectsFallen == 3)
					{
						tempMsgValue = [tempMsgValue stringByReplacingOccurrencesOfString:@"," withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, 1)];
						tempMsgValue = [tempMsgValue stringByReplacingOccurrencesOfString:@"," withString:@" et" options:NSCaseInsensitiveSearch range:NSMakeRange(28, 5)];
					}
					
					msgValue = [msgValue stringByAppendingString:tempMsgValue];
					msgValue = [msgValue stringByAppendingString:@" tomber au milieu des vagues, cinquante mètres plus bas."];
				}
				
				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];
			}
		}
		else if([user.cardID isEqualToString:@"12941"] || [user.cardID isEqualToString:@"15930"])
		{
			if([currentAction isEqualToString:@"aller_nord"] || [currentAction isEqualToString:@"aller_ouest"]|| [currentAction isEqualToString:@"aller_est"])
			{
				NSString* description = @"Après une traversée sans problème, vous débarquez ";
				if([currentAction isEqualToString:@"aller_nord"])
				{
					description = [description stringByAppendingString:@"sur l'île d'Histora."];
				}
				else if([currentAction isEqualToString:@"aller_ouest"])
				{
					description = [description stringByAppendingString:@"dans la ville de Litter."];
				}
				else if([currentAction isEqualToString:@"aller_est"])
				{
					description = [description stringByAppendingString:@"dans la ville de Matem."];
				}
				
				description = [description stringByAppendingString:@" Le vaisseau est déjà reparti au loin."];
				
				if(user.gold >= 2)
				{
					[user setGold:(user.gold - 2)];
					description = [description stringByAppendingString:@" Cela vous a coûté deux pièces d'or."];
				}
				else
				{
					description = [description stringByAppendingString:@" Vous n'avez pas pu payer votre traversée, vous avez été obligé de laver le pont et la soute."];
				}
				
				[boxViewMessages setObject:description forKey:descriptionView];
				[boxViewMessages setObject:@"#Suite...#" forKey:actionView];
				
				if([currentAction isEqualToString:@"aller_nord"])
				{
					[actions setValue:[[[LGSAction alloc] initWithType:@"goCard" andValue:@"10084"] autorelease] forKey:@"Suite..."];
				}
				else if([currentAction isEqualToString:@"aller_ouest"])
				{
					[actions setValue:[[[LGSAction alloc] initWithType:@"goCard" andValue:@"7004"] autorelease] forKey:@"Suite..."];
				}
				else if([currentAction isEqualToString:@"aller_est"])
				{
					[actions setValue:[[[LGSAction alloc] initWithType:@"goCard" andValue:@"9627"] autorelease] forKey:@"Suite..."];
				}
			}
		}
		else if([user.cardID isEqualToString:@"10084"])
		{
			if([currentAction isEqualToString:@"barque_litter"] || [currentAction isEqualToString:@"barque_matem"])
			{
				NSString* description = @"Après une longue traversée, vous arrivez enfin ";
				if([currentAction isEqualToString:@"barque_litter"])
				{
					description = [description stringByAppendingString:@"sur le port de Litter. Un marin qui se trouve là accepte de rapporter la barque à Histora."];
				}
				else if([currentAction isEqualToString:@"barque_matem"])
				{
					description = [description stringByAppendingString:@"sur le port de Matem. Un pêcheur qui se trouve là accepte de rapporter la barque à Histora."];
				}
				
				description = [description stringByAppendingString:@" Le vaisseau est déjà reparti au loin."];
				
				if(user.gold >= 1)
				{
					[user setGold:(user.gold - 1)];
					description = [description stringByAppendingString:@" Vous le payez d'une pièce d'or."];
				}
				
				[boxViewMessages setObject:description forKey:descriptionView];
				[boxViewMessages setObject:@"#Suite...#" forKey:actionView];
				
				if([currentAction isEqualToString:@"barque_litter"])
				{
					[actions setValue:[[[LGSAction alloc] initWithType:@"goCard" andValue:@"7004"] autorelease] forKey:@"Suite..."];
				}
				else if([currentAction isEqualToString:@"barque_matem"])
				{
					[actions setValue:[[[LGSAction alloc] initWithType:@"goCard" andValue:@"9627"] autorelease] forKey:@"Suite..."];
				}
			}
		}
		else if([user.cardID isEqualToString:@"12274"])
		{
			if([currentAction isEqualToString:@"joncs"])
			{
				if([[user.objects objectForKey:@"joncs"] boolValue])
				{
					NSString* msgValue = @"A force de bourrer votre sac avec ces joncs, vous allez finir par le faire craquer.";
					[boxViewMessages setObject:msgValue forKey:msgView];
					[msgView show];
				}
				else
				{
					[user.objects setObject:[NSNumber numberWithBool:YES] forKey:@"joncs"];
					
					NSString* msgValue = @"Avec bien des difficultés, vous réussissez finalement à couper quelques tiges dures et sèches de ces joncs.";
					msgValue = [msgValue stringByAppendingString:@" Vous les tressez avant de les mettre dans votre sac."];
					[boxViewMessages setObject:msgValue forKey:msgView];
					[msgView show];
				}
			}
		}
		else if([user.cardID isEqualToString:@"11997"])
		{
			if([currentAction isEqualToString:@"frapper_porte"])
			{
				[soundManager loadAndPlaySound:[data soundDatasForKey:@"knock"] loop:NO];
			}
		}
		else if([user.cardID isEqualToString:@"13183"])
		{
			if([currentAction isEqualToString:@"piece_or"] && user.gold >= 1)
			{
				[user setGold:(user.gold - 1)];
				
				NSString* msgValue = @"Le pêcheur, tout étonné de votre générosité, se remet de ses émotions et pense déjà au nouveau filet qu'il va pouvoir ";
				msgValue = [msgValue stringByAppendingString:@"s'acheter avec cet argent. Pour vous remercier, il vous "];
				msgValue = [msgValue stringByAppendingString:@"indique qu'on peut trouver un atlas dans la boutique qui "];
				msgValue = [msgValue stringByAppendingString:@"se trouve au sud de l'abbaye d'Encyclopia."];
				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];
				
				if(user.gold >= 1)
				{
					NSString* action = [boxViewMessages objectForKey:actionView];
					action = [action stringByReplacingOccurrencesOfString:@"\\n#donner une pièce d'or au pêcheur#\\n#pour le réconforter.#" withString:@""];
					[boxViewMessages setObject:action forKey:actionView];
				}
			}
		}
		else if([user.cardID isEqualToString:@"12302"])
		{
			[soundManager stopSounds];
			[soundManager loadAndPlaySound:[data soundDatasForKey:@"vache"] loop:YES];
			if([currentAction isEqualToString:@"traire_vache"])
			{
				if([[user.objects objectForKey:@"lait"] boolValue])
				{
					NSString* msgValue = @"Vous avez déjà rempli votre pot de lait et vous n'avez aucun autre récipient.";
					msgValue = [msgValue stringByAppendingString:@" De toutes façons, on ne trait pas une vache toutes les cinq minutes !"];
					[boxViewMessages setObject:msgValue forKey:msgView];
					[msgView show];
				}
				else
				{
					[soundManager stopSounds];
					[soundManager loadAndPlaySound:[data soundDatasForKey:@"traite"] loop:YES];
					[user.objects setObject:[NSNumber numberWithBool:YES] forKey:@"lait"];
					
					NSString* msgValue = @"Un pot se trouvait justement sur le sol, au bord du chemin. Vous vous installez, et vous trayez la vache. Le lait que";
					msgValue = [msgValue stringByAppendingString:@" vous en tirez semble riche et onctueux. Il est vrai que les pâturages"];
					msgValue = [msgValue stringByAppendingString:@" alentour sont três verts. Aprês vous être délecté de ce breuvage"];
					msgValue = [msgValue stringByAppendingString:@", vous décidez d'en garder un peu avec vous pour la route."];
					[boxViewMessages setObject:msgValue forKey:msgView];
					[msgView show];
				}
			}
		}
		else if([user.cardID isEqualToString:@"15565"])
		{
			if([currentAction isEqualToString:@"dechiffrer_inscriptions"])
			{
				if([[user.objects objectForKey:@"torche"] boolValue])
				{
					NSString* description = @"Effectivement, votre briquet d'amadou a réussi sans problème a enflammer la torche de jonc.";
					description = [description stringByAppendingString:@" On y voit tout de suite plus clair ! Voyons donc ces inscriptions..."];
					
					[user.objects setObject:[NSNumber numberWithBool:NO] forKey:@"torche"];
					
					[boxViewMessages setObject:description forKey:descriptionView];
					[boxViewMessages setObject:@"#Suite...#" forKey:actionView];
					[actions setValue:[[[LGSAction alloc] initWithType:@"goCard" andValue:@"15762"] autorelease] forKey:@"Suite..."];
				}
				else if([[user.objects objectForKey:@"joncs"] boolValue])
				{
					NSString* msgValue = @"Il fait bien trop sombre dans cette caverne !";
					[boxViewMessages setObject:msgValue forKey:msgView];
					[msgView show];
				}
				else
				{
					NSString* msgValue = @"Il fait bien trop sombre dans cette caverne ! Même avec votre briquet d'amadou, vous ne pouvez pas déchiffrer";
					msgValue = [msgValue stringByAppendingString:@" ce qui est écrit sur la paroi. Il vous faudrait une torche..."];
					[boxViewMessages setObject:msgValue forKey:msgView];
					[msgView show];
				}
			}
			else if([currentAction isEqualToString:@"confectionner_torche"])
			{
				if([[user.objects objectForKey:@"torche"] boolValue])
				{
					NSString* msgValue = @"Une seule torche suffira largement !";
					[boxViewMessages setObject:msgValue forKey:msgView];
					[msgView show];
				}
				else
				{
					[user.objects setObject:[NSNumber numberWithBool:YES] forKey:@"torche"];
					[user.objects setObject:[NSNumber numberWithBool:NO] forKey:@"joncs"];
					
					NSString* msgValue = @"Avec votre briquet d'amadou, il vous sera facile d'enflammer cette torche improviste.";
					msgValue = [msgValue stringByAppendingString:@" Vous avez encore des joncs au fond de votre sac."];
					[boxViewMessages setObject:msgValue forKey:msgView];
					[msgView show];
				}

			}
		}
		else if([user.cardID isEqualToString:@"13877"])
		{
			if([currentAction isEqualToString:@"retourner_entrer"])
			{
				if([[user.points objectForKey:@"Histora"] intValue] > 20)
				{
					[self goCard:@"15213"];
				}
				else
				{
					[self goCard:@"12591"];
				}
			}
		}
		else if([user.cardID isEqualToString:@"15213"])
		{
			if([currentAction isEqualToString:@"kronolos"])
			{
				NSString* msgValue = @"";
				
				if([[user.objects objectForKey:@"piece_roi"] boolValue])
				{
					msgValue = [msgValue stringByAppendingString:@"Ah, c'est toi, @user. Je vois que tu continues ta quête."];
					msgValue = [msgValue stringByAppendingString:@" Je n'ai malheureusement pas le temps de m'occuper de toi en ce"];
					msgValue = [msgValue stringByAppendingString:@" moment. Depuis que tu m'as apporté ce merveilleux atlas, je"];
					msgValue = [msgValue stringByAppendingString:@" travaille sans arrêter.\nBon courage, @user !"];
				}
				else if([[user.objects objectForKey:@"atlas"] boolValue])
				{
					msgValue = [msgValue stringByAppendingString:@"Bonjour, @user. Je vois que tu m'as apporté l'atlas que"];
					msgValue = [msgValue stringByAppendingString:@" je cherchais depuis si longtemps.\nJe vais enfin "];
					msgValue = [msgValue stringByAppendingString:@"pouvoir terminer mes recherches !\nPour te récompenser,"];
					msgValue = [msgValue stringByAppendingString:@" je t'offre un talisman qui te permettra d'entrer dans l'abbaye d'Encyclopia."];
				}
				else
				{
					msgValue = [msgValue stringByAppendingString:@"Qui vient me déranger pendant mon travail ?"];
					msgValue = [msgValue stringByAppendingString:@"\nC'est toi, @user ! M'as-tu apporté l'objet que j'ai envoyé quérir ?"];
					msgValue = [msgValue stringByAppendingString:@"\nNon !?!\nAlors, ne reviens que lorsque tu l'auras trouvé !"];
				}
				
				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];
			}
			else if([currentAction isEqualToString:@"action_message"])
			{
				if([[user.objects objectForKey:@"piece_roi"] boolValue])
				{
					[self goCard:@"13877"];
				}
				else if([[user.objects objectForKey:@"atlas"] boolValue])
				{
					[user.objects setObject:[NSNumber numberWithBool:NO] forKey:@"atlas"];
					[user.objects setObject:[NSNumber numberWithBool:YES] forKey:@"piece_roi"];
					[self goCard:@"29757"];
				}
				else
				{
					[self goCard:@"13877"];
				}
			}
		}
		else if([user.cardID isEqualToString:@"5079"])
		{
			if([currentAction isEqualToString:@"caresser_chat"])
			{
				NSInteger nbStepsCat = [[user.adventures objectForKey:@"nbStepsCat"] integerValue];
				
				NSString* msgValue = @"";
				if(nbStepsCat > 0)
				{
					msgValue = [msgValue stringByAppendingString:@"Le chat refuse de se laisser approcher. Vous courez après lui"];
					msgValue = [msgValue stringByAppendingString:@" pendant quelques instants sans jamais pouvoir le toucher. Lassé,"];
					msgValue = [msgValue stringByAppendingString:@" vous finissez par abandonner. C'est aussi bien, vu ce qui vous "];
					msgValue = [msgValue stringByAppendingString:@"est arrivé la dernière fois."];
				}
				else
				{
					[soundManager loadAndPlaySound:[data soundDatasForKey:@"chat"] loop:NO];
					
					msgValue = [msgValue stringByAppendingString:@"Vous caressez le chat pendant quelques instants. Celui-ci se "];
					msgValue = [msgValue stringByAppendingString:@"laisse faire sans réaction apparente. Tout à coup, vous sursautez "];
					msgValue = [msgValue stringByAppendingString:@"et jetez le chat loin de vous ! horreur ! Il grouille de puces !"];
					msgValue = [msgValue stringByAppendingString:@" vous voilà infesté vous-même."];
				}
				
				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];
				
				[user.adventures setObject:[NSNumber numberWithInteger:15] forKey:@"nbStepsCat"]; //15 = temps de se débarrasser des puces
			}
			else if([currentAction isEqualToString:@"coup_de_pied_chien"])
			{
				NSInteger nbCoupDePieds = [[user.adventures objectForKey:@"coupDePied_chien"] integerValue];
				
				NSString* msgValue = @"";
				
				if(nbCoupDePieds % 3 == 0)
				{
					msgValue = [msgValue stringByAppendingString:@"Sous le coup, le chien se sauve le long de la rue en hurlant de douleur."];
					[soundManager loadAndPlaySound:[data soundDatasForKey:@"ouah5"] loop:NO];
				}
				else if(nbCoupDePieds % 3 == 1)
				{
					msgValue = [msgValue stringByAppendingString:@"Sous le coup, le chien est projeté à deux mêtres et reste inerte comme si vous aviez tapé dans  un caillou."];
					[soundManager loadAndPlaySound:[data soundDatasForKey:@"claps"] loop:NO];
				}
				else if(nbCoupDePieds % 3 == 2)
				{
					msgValue = [msgValue stringByAppendingString:@"Le chien s'accroche à votre mollet et tout en poussant de féroces grognements, "];
					msgValue = [msgValue stringByAppendingString:@"il  vous mord sauvagement. Vous risquez d'en avoir une marque pour longtemps !"];
					[soundManager loadAndPlaySound:[data soundDatasForKey:@"grognements"] loop:NO];
				}
				
				if(nbCoupDePieds >= 3)
				{
					msgValue = [msgValue stringByAppendingString:@" Quelques minutes plus tard, il revient, semblant avoir tout oublié."];
				}
				
				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];
				[user.adventures setObject:[NSNumber numberWithInteger:(nbCoupDePieds + 1)] forKey:@"coupDePied_chien"];
			}
		}
		else if([user.cardID isEqualToString:@"9635"])
		{
			if([currentAction isEqualToString:@"boulier_notable"])
			{
				NSString* msgValue = @"";
				
				if([[user.adventures objectForKey:@"boulier_notable"] boolValue])
				{
					msgValue = [msgValue stringByAppendingString:@"Auriez-vous perdu la mémoire ! Vous avez déjà vendu un boulier "];
					msgValue = [msgValue stringByAppendingString:@"semblable au notable. Le premier "];
					msgValue = [msgValue stringByAppendingString:@"lui convient parfaitement et il n'a nul besoin d'un autre boulier. Gardez-le "];
					msgValue = [msgValue stringByAppendingString:@"donc sur vous, il pourra sûrement vous être utile. Surtout si "];
					msgValue = [msgValue stringByAppendingString:@"vous devez encore aller à Matem."];
				}
				else
				{
					msgValue = [msgValue stringByAppendingString:@"Le notable est enchanté par la qualité de votre boulier."];
					msgValue = [msgValue stringByAppendingString:@" Vous n'avez même pas besoin de parlementer pour en tirer 5 belles "];
					msgValue = [msgValue stringByAppendingString:@"pièces d'or. Espérons que cet objet ne vous manquera pas par la suite."];
					
					[user setGold:(user.gold + 5)];
					[user.objects setObject:[NSNumber numberWithBool:NO] forKey:@"boulier"];
					[user.adventures setObject:[NSNumber numberWithBool:YES] forKey:@"boulier_notable"];
					
					NSString* action = [boxViewMessages objectForKey:actionView];
					action = [action stringByReplacingOccurrencesOfString:@"\\n#Proposer votre boulier au notable.#" withString:@""];
					[boxViewMessages setObject:action forKey:actionView];
				}
				
				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];
			}
		}
		else if([user.cardID isEqualToString:@"9914"])
		{
			if([currentAction isEqualToString:@"pieceor_femme"])
			{
				NSString* msgValue = @"La vieille femme se jette à genoux devant vous et rend grâce à votre générosité. Elle va pouvoir embellir le trousseau de";
				msgValue = [msgValue stringByAppendingString:@" sa fille qui danse en ce moment même à la fête organisée chez "];
				msgValue = [msgValue stringByAppendingString:@" ses voisins de derrière. Pour vous remercier, elle vous "];
				msgValue = [msgValue stringByAppendingString:@"indique qu'on peut trouver un lexique dans la boutique qui "];
				msgValue = [msgValue stringByAppendingString:@"se trouve au sud de l'abbaye d'Encyclopia."];
				
				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];
				
				[user setGold:(user.gold - 1)];
				
				if(user.gold == 0)
				{
					NSString* action = [boxViewMessages objectForKey:actionView];
					action = [action stringByReplacingOccurrencesOfString:@"\\n#donner une pièce d'or#\\n#à la vieille femme." withString:@""];
					[boxViewMessages setObject:action forKey:actionView];
				}
			}
		}
		else if([user.cardID isEqualToString:@"7872"])
		{
			if([currentAction isEqualToString:@"cueillir_herbes"])
			{
				NSString* msgValue = @"";
				
				if([[user.adventures objectForKey:@"vente_herbes"] intValue] == 2)
				{
					msgValue = [msgValue stringByAppendingString:@"Vous avez déjà revendu deux fois votre cueillette ! Ce qui"];
					msgValue = [msgValue stringByAppendingString:@" reste au bord du chemin n'est pas suffisant pour une autre revente. De toutes"];
					msgValue = [msgValue stringByAppendingString:@" façons, vous n'êtes pas là pour faire du commerce ! Laissez"];
					msgValue = [msgValue stringByAppendingString:@" donc cette herbe à sa place !"];
				}
				else if([[user.objects objectForKey:@"herbes"] boolValue])
				{
					msgValue = [msgValue stringByAppendingString:@"Il y a déjà suffisamment d'herbes dans votre sac !"];
				}
				else
				{
					[user.objects setObject:[NSNumber numberWithBool:YES] forKey:@"herbes"];
					
					msgValue = [msgValue stringByAppendingString:@"Vous cueillez quelques brins de cette herbe dont l'odeur est"];
					msgValue = [msgValue stringByAppendingString:@" envoûtante. Vous décidez de garder un peu de votre cueillette "];
					msgValue = [msgValue stringByAppendingString:@" dans votre sac."];
				}
				
				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];
			}
		}
		else if([user.cardID isEqualToString:@"4269"])
		{
			if([[user.adventures objectForKey:@"mendiant"] boolValue])
			{
				[self goCard:@"11594"];
			}
		}
		else if([user.cardID isEqualToString:@"6164"])
		{
			if([[user.adventures objectForKey:@"mendiant"] boolValue])
			{
				[self goCard:@"11594"];
			}
			
			if([currentAction isEqualToString:@"une_piece"] || [currentAction isEqualToString:@"deux_pieces"])
			{
				[user.adventures setObject:[NSNumber numberWithBool:YES] forKey:@"mendiant"];
				
				NSString* msgValue = @"Le mendiant vous remercie de votre générosité et il vous";
				msgValue = [msgValue stringByAppendingString:@" indique que la maison du seigneur Lingus se trouve un peu plus loin au nord."];
				
				if([currentAction isEqualToString:@"une_piece"] && user.gold >= 1)
				{
					msgValue = [msgValue stringByAppendingString:@"Il se lève et disparaît en claudiquant."];
					[user setGold:(user.gold - 1)];
				}
				else if([currentAction isEqualToString:@"deux_pieces"] && user.gold >= 2)
				{
					msgValue = [msgValue stringByAppendingString:@"Il ajoute que l'un des gardes lui a dit que la possession "];
					msgValue = [msgValue stringByAppendingString:@"d'un lexique est très utile dans la demeure de ce seigneur."];
					msgValue = [msgValue stringByAppendingString:@"\nIl se lève et disparaît en claudiquant."];
					[user setGold:(user.gold - 2)];
				}
				else
				{
					msgValue = [msgValue stringByAppendingString:@"Vous n'avez pas assez de pièces pour cela."];
				}
				
				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];
			}
			else if([currentAction isEqualToString:@"travailler"])
			{
				[user.adventures setObject:[NSNumber numberWithBool:YES] forKey:@"mendiant"];
				
				NSString* msgValue = @"Le mendiant se précipite sur vous en vous abreuvant d'insultes.";
				msgValue = [msgValue stringByAppendingString:@" Vous vous défendez du mieux que vous pouvez. Dans la bagarre, "];
				msgValue = [msgValue stringByAppendingString:@"vous êtes étourdi par un choc."];
				
				if([[user.objects objectForKey:@"pepite"] boolValue])
				{
					msgValue = [msgValue stringByAppendingString:@"Le mendiant profite de votre étourdissement pour vous voler votre pépite et"];
					
					[user.objects setObject:[NSNumber numberWithBool:NO] forKey:@"pepite"];
				}
				else
				{
					msgValue = [msgValue stringByAppendingString:@"Le mendiant vous voyant groggy prend peur et"];
				}
				
				msgValue = [msgValue stringByAppendingString:@"se sauve en courant.\nIl aurait mieux valu lui faire l'aumône."];
				
				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];
			}
		}
		else if([user.cardID isEqualToString:@"5974"])
		{
			if([currentAction isEqualToString:@"entrer"])
			{
				if([[user.points objectForKey:@"Litter"] intValue] > 20)
				{
					[self goCard:@"8607"];
				}
			}
		}
		else if([user.cardID isEqualToString:@"8607"])
		{
			if([currentAction isEqualToString:@"lingus"])
			{
				NSString* msgValue = @"";
				
				if([[user.objects objectForKey:@"croix_celtique"] boolValue])
				{
					msgValue = [msgValue stringByAppendingString:@"Ah, c'est toi, @user. Je vois que tu continues ta quête."];
					msgValue = [msgValue stringByAppendingString:@" Je n'ai malheureusement pas le temps de m'occuper de toi en ce"];
					msgValue = [msgValue stringByAppendingString:@" moment. Depuis que tu m'as apporté ce merveilleux lexique, je"];
					msgValue = [msgValue stringByAppendingString:@" travaille sans arrêter.\nBon courage, @user !"];
				}
				else if([[user.objects objectForKey:@"lexique"] boolValue])
				{
					msgValue = [msgValue stringByAppendingString:@"Bonjour, @user. Je vois que tu m'as apporté le lexique que"];
					msgValue = [msgValue stringByAppendingString:@" je cherchais depuis si longtemps.\nJe vais enfin "];
					msgValue = [msgValue stringByAppendingString:@"pouvoir terminer mes recherches !\nPour te récompenser,"];
					msgValue = [msgValue stringByAppendingString:@" je t'offre un talisman qui te permettra d'entrer dans l'abbaye d'Encyclopia."];
				}
				else
				{
					msgValue = [msgValue stringByAppendingString:@"Qui vient me déranger pendant mon travail ?"];
					msgValue = [msgValue stringByAppendingString:@"\nC'est toi, @user ! M'as-tu apporté l'objet que j'ai envoyé quérir ?"];
					msgValue = [msgValue stringByAppendingString:@"\nNon !?!\nAlors, ne reviens que lorsque tu l'auras trouvé !"];
				}
				
				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];
			}
			else if([currentAction isEqualToString:@"action_message"])
			{
				if([[user.objects objectForKey:@"croix_celtique"] boolValue])
				{
					[self goCard:@"5974"];
				}
				else if([[user.objects objectForKey:@"lexique"] boolValue])
				{
					[user.objects setObject:[NSNumber numberWithBool:NO] forKey:@"lexique"];
					[user.objects setObject:[NSNumber numberWithBool:YES] forKey:@"croix_celtique"];
					[self goCard:@"10697"];
				}
				else
				{
					[self goCard:@"5974"];
				}
			}
		}
		else if([user.cardID isEqualToString:@"8034"])
		{
			if([currentAction isEqualToString:@"vendre_lait"])
			{
				NSString* msgValue = @"Le damoiseau vous remercie fort pour ce bon lait qui provient,";
				msgValue = [msgValue stringByAppendingString:@" à n'en pas douter, de l'île d'Histora. Il vous le paie de trois"];
				msgValue = [msgValue stringByAppendingString:@" pièces d'or qui se rajoutent à votre fortune. Vous avez donc "];
				msgValue = [msgValue stringByAppendingString:@"maintenant @gold @pieceor."];
				
				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];
				
				NSString* action = [boxViewMessages objectForKey:actionView];
				action = [action stringByReplacingOccurrencesOfString:@"\\n#Vendre votre pot de lait.#" withString:@""];
				[boxViewMessages setObject:action forKey:actionView];
				
				[user.objects setObject:[NSNumber numberWithBool:NO] forKey:@"lait"];
				[user setGold:(user.gold + 3)];
			}
			else if([currentAction isEqualToString:@"regarder_mirroir"])
			{
				NSString* msgValue = @"Vous voyez dans le miroir l'image d'un moinillon harassé par sa déjà longue marche. Devinez de qui il s'agit...";
				
				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];
			}
		}
		else if([user.cardID isEqualToString:@"8277"])
		{
			if([currentAction isEqualToString:@"montrer_herbes"])
			{
				NSString* msgValue = @"L'herboriste est extrèmement satisfait de la qualité des ";
				msgValue = [msgValue stringByAppendingString:@"herbes que vous lui apportez. Il vous en offre 3 pièces d'or."];
				
				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];
				
				NSString* action = [boxViewMessages objectForKey:actionView];
				action = [action stringByReplacingOccurrencesOfString:@"\\n#montrer vos herbes.#" withString:@""];
				[boxViewMessages setObject:action forKey:actionView];
				
				[user.objects setObject:[NSNumber numberWithBool:NO] forKey:@"herbes"];
				[user setGold:(user.gold + 3)];
			}
			else if([currentAction isEqualToString:@"sonner_clochettes"])
			{
				[soundManager loadAndPlaySound:[data soundDatasForKey:@"clochettes2"] loop:NO];
			}
		}
		else if([user.cardID isEqualToString:@"10465"])
		{
			if([currentAction isEqualToString:@"sonner_clochettes"])
			{
				[soundManager loadAndPlaySound:[data soundDatasForKey:@"clochettes2"] loop:NO];
			}
		}
		else if([user.cardID isEqualToString:@"6640"])
		{
			if([currentAction isEqualToString:@"prier"])
			{
				NSString* msgValue = @"Une musique céleste retentit dans votre esprit.\n";
				msgValue = [msgValue stringByAppendingString:@"Un calme impressionnant vous envahit.\nVous allez "];
				msgValue = [msgValue stringByAppendingString:@"pouvoir reprendre votre parcours, l'esprit serein, prêt à affronter"];
				msgValue = [msgValue stringByAppendingString:@" les nombreuses épreuves qui vous attendent."];
				
				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];
				
				[soundManager loadAndPlaySound:[data soundDatasForKey:@"gloria"] loop:NO];
			}
			else if([currentAction isEqualToString:@"piece_tronc"])
			{
				NSString* msgValue = @"";
				if(user.gold >= 1)
				{
					msgValue = [msgValue stringByAppendingString:@"Le bedeau vous remercie, et vous assure que le Bon Dieu "];
					msgValue = [msgValue stringByAppendingString:@"vous le rendra au centuple."];
					
					[user setGold:(user.gold - 1)];
				}
				else
				{
					msgValue = [msgValue stringByAppendingString:@"Vous n'avez plus de pièce !\n(mais c'était une bonne intention)"];
				}
				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];
				
				[soundManager loadAndPlaySound:[data soundDatasForKey:@"piece_tronc"] loop:NO];
			}
		}
		else if([user.cardID isEqualToString:@"6740"])
		{
			if([currentAction isEqualToString:@"commander_boire"])
			{
				NSString* msgValue = @"";
				if([[user.adventures objectForKey:@"taverne"] intValue] > 2)
				{
					[user.adventures setObject:[NSNumber numberWithInteger:4] forKey:@"taverne"];
					
					msgValue = [msgValue stringByAppendingString:@"Le tavernier refuse de vous donner une troisième fois à"];
					msgValue = [msgValue stringByAppendingString:@" boire de son vin. Il vous jette dehors comme un ivrogne."];
				}
				else if(user.gold >= 1)
				{
					msgValue = [msgValue stringByAppendingString:@"Le tavernier vous sert le plus délicieux des vins de pays."];
					msgValue = [msgValue stringByAppendingString:@"\nVous vous délectez de ce nectar, et c'est la joie"];
					msgValue = [msgValue stringByAppendingString:@" au coeur que vous continuez votre périple.\n"];
					msgValue = [msgValue stringByAppendingString:@"Il vous en a coûté une pièce d'or, mais cela valait la peine !"];
					
					[user.adventures setObject:[NSNumber numberWithInteger:([[user.adventures objectForKey:@"taverne"] integerValue] + 1)] forKey:@"taverne"];
					
					[soundManager loadAndPlaySound:[data soundDatasForKey:@"bierre"] loop:NO];
				}
				else
				{
					msgValue = [msgValue stringByAppendingString:@"Vous commandez à boire au tavernier. Celui-ci vous demande"];
					msgValue = [msgValue stringByAppendingString:@" d'abord votre argent. Malheureusement vous n'avez plus de "];
					msgValue = [msgValue stringByAppendingString:@"pièce.\nLe tavernier refuse donc de vous servir."];
				}
				
				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];
			}
			else if([currentAction isEqualToString:@"action_message"] && [[user.adventures objectForKey:@"taverne"] intValue] > 3)
			{
				[self goCard:@"4710"];
			}
			else if([currentAction isEqualToString:@"spiritueux"])
			{
				if([[user.adventures objectForKey:@"taverne"] intValue] > 3)
				{
					[user.adventures setObject:[NSNumber numberWithInteger:3] forKey:@"taverne"];
				}
				NSString* msgValue = @"Un jeune moine comme vous ne devrait pas toucher à ce genre de spiritueux.";
				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];
			}
			else if([currentAction isEqualToString:@"assoir"])
			{
				if([[user.adventures objectForKey:@"taverne"] intValue] > 3)
				{
					[user.adventures setObject:[NSNumber numberWithInteger:3] forKey:@"taverne"];
				}
				NSString* msgValue = @"D'accord. Rien ne vous empêche de vous mettre assis un instant.";
				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];
			}
		}
		else if([user.cardID isEqualToString:@"6816"])
		{
			if([currentAction isEqualToString:@"entrer_abbaye"])
			{
				if([[user.objects objectForKey:@"croix_celtique"] boolValue] && [[user.objects objectForKey:@"sablier"] boolValue] && [[user.objects objectForKey:@"piece_roi"] boolValue])
				{
					[self goCard:@"8813"];
				}
				else
				{
					NSString* msgValue = @"Le frère portier vous demande de lui montrer vos Talismans, gages de vos mérites.";
					msgValue = [msgValue stringByAppendingString:@" Comme vous ne possédez pas les trois Talismans qui sont indispensables,"];
					msgValue = [msgValue stringByAppendingString:@" il vous reconduit sans ménagement à la sortie."];
					[boxViewMessages setObject:msgValue forKey:msgView];
					[msgView show];
				}

			}
		}
		else if([user.cardID isEqualToString:@"11876"])
		{
			if([currentAction isEqualToString:@"fleurs_nonne"])
			{
				[user.objects setObject:[NSNumber numberWithBool:NO] forKey:@"fleurs"];
				
				NSString* msgValue = @"La nonne vous remercie grandement de ce charmant bouquet qui va lui permettre de décorer l'autel de façon magnifique. Pour vous ";
				msgValue = [msgValue stringByAppendingString:@"remercier, elle vous recommande d'aller voir de sa part la soeur "];
				msgValue = [msgValue stringByAppendingString:@"cuisinière dans la tour Est de l'abbaye pour lui demander un peu de sa fameuse soupe."];
				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];
				
				NSString* action = [boxViewMessages objectForKey:actionView];
				action = [action stringByReplacingOccurrencesOfString:@"\\n#Donner vos fleurs à la nonne.#" withString:@""];
				[boxViewMessages setObject:action forKey:actionView];
			}
		}
		else if([user.cardID isEqualToString:@"12973"])
		{
			if([currentAction isEqualToString:@"entrer_bibliotheque"])
			{
				if([[user.points objectForKey:@"Encyclopia"] intValue] > 20)
				{
					[self goCard:@"18460"];
				}
				else
				{
					NSString* msgValue = @"Vous n'avez pas récolté suffisament de Talents pour pouvoir entrer dans ce lieu.";
					msgValue = [msgValue stringByAppendingString:@" Il vous faut encore subir quelques épreuves."];
					[boxViewMessages setObject:msgValue forKey:msgView];
					[msgView show];
				}
				
			}
		}
		else if([user.cardID isEqualToString:@"25754"])
		{
			if([currentAction isEqualToString:@"donner_lait"])
			{
				[user.objects setObject:[NSNumber numberWithBool:NO] forKey:@"lait"];
				
				NSString* msgValue = @"La cuisinière vous remercie de votre présent qui ne pouvait pas mieux tomber, et, en échange,";
				msgValue = [msgValue stringByAppendingString:@" vous donne un bol de la soupe de légumes qu'elle vient juste"];
				msgValue = [msgValue stringByAppendingString:@" de préparer. Avec une cuillère de lait pour la rendre encore plus"];
				msgValue = [msgValue stringByAppendingString:@" onctueuse, cette soupe est savoureuse. Vous vous régalez !"];
				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];
				
				NSString* action = [boxViewMessages objectForKey:actionView];
				action = [action stringByReplacingOccurrencesOfString:@"\\n#donner votre pot de lait#\\n#à la cuisinière.#" withString:@""];
				[boxViewMessages setObject:action forKey:actionView];
			}
		}
		else if([user.cardID isEqualToString:@"18460"])
		{
			if([currentAction isEqualToString:@"saluer_encyclopia"])
			{
				NSString* msgValue = @"Bravo, @user. Tu as fini ton périple et tu as pu me rapporter";
				msgValue = [msgValue stringByAppendingString:@" les trois Talismans. Grâce à tes connaissances, tu as récolté @totalPoints Talents, durant ta quête."];
				msgValue = [msgValue stringByAppendingString:@"\nJe pense donc que tu es capable de prendre ma difficile succession au poste de Gardien du Savoir."];
				msgValue = [msgValue stringByAppendingString:@"\nEn signe de ta nomination, je vais maintenant te donner le Livre du Savoir."];
				[boxViewMessages setObject:msgValue forKey:msgView];
				[msgView show];
			}
			else if([currentAction isEqualToString:@"action_message"])
			{
				//end game!!
				//go to endViewController
				[appDelegate changeLGSController:@"PlatformEnd"];
			}
		}
		break;

	  case LGSGameActionCloseCard :
		if([user.cardID isEqualToString:@"22568"])
		{
			[soundManager loadAndPlaySound:[data soundDatasForKey:@"fermeporte"] loop:NO];
		}

		  break;
	}
}

-(void) dealloc
{
	[mode release];
	[actions release];
	[boxViewMessages release];
	[boxOriginalViewMessages release];
	[super dealloc];
}

@end
