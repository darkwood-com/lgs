/**
 *  LGSMainViewController.m
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
#import "LGSMainViewController.h"
#import "LGSSoundManager.h"

@implementation LGSMainViewController

-(BOOL) start
{
	LGSSoundManager* soundManager = [LGSSoundManager sharedSoundManager];
	[soundManager loadAndPlaySound:[data soundDatasForKey:@"lgs"] loop:NO];
	
	NSString* textValue = @"Le gardien du Savoir                 Version 1.0\n\n      Adapté sur Mac OS X, iPhone et iPad\n";
	textValue = [textValue stringByAppendingString:@"              par Mathieu Ledru\n\n"];
	textValue = [textValue stringByAppendingString:@"    Version originale sur Hypercard (Mac OS 9)\n"];
	textValue = [textValue stringByAppendingString:@"       par Monic et Bernard Grienenberger"];
	[infoMsgView setTextValue:textValue];
	
	return YES;
}

-(void) lgsActions:(LGSControl*) sender
{
	//bock other actions when dialog prompt
	if(([newUserPromptView isHidden] == NO) && (sender != newUserPromptView))
	{
		return;
	}

	//control actions
	if(sender == studentView)
	{
		[studentMenuView toggle];
	}
	else if(sender == studentMenuView)
	{
		NSString* action = [studentMenuView currentAction];

		if([action isEqualToString:@"Commencer une nouvelle aventure."])
		{
			[newUserPromptView show];
		}
		else if([action isEqualToString:@"Reprendre une ancienne."])
		{
      		NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
      		NSString* loadPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"save.lgs"];
			NSDictionary* rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile:loadPath];
			if(rootObject)
			{
				//load success
				NSString* promptValue = @"Voulez vous charger le périple du ";
				NSDate* saveDate = [rootObject valueForKey:@"savedate"];
				NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
				[dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"] autorelease]];
				[dateFormatter setDateFormat:@"EEEE d MMMM 'à' HH:mm"];
				promptValue = [promptValue stringByAppendingString:[dateFormatter stringFromDate:saveDate]];
				[loadUserPromptView setTextValue:promptValue];
				[loadUserPromptView setPromptMode:LGSPromptViewModeYesNo];
			}
			else
			{
				//load fail
				[loadUserPromptView setTextValue:@"Aucune sauvegarde n'a été trouvée."];
				[loadUserPromptView setPromptMode:LGSPromptViewModeOk];
			}

			[loadUserPromptView show];
		}
		else if([action isEqualToString:@"Charger les fichiers de questions."])
		{
		}
		else if([action isEqualToString:@"Annuler."])
		{
		}

		[studentMenuView hide];
	}
	else if(sender == newUserPromptView)
	{
		[newUserPromptView hide];

		NSString* userName = [newUserPromptView textValue];
		if([newUserPromptView currentPromptAction] == YES && userName != nil && ![userName isEqualToString:@""])
		{
			//start a new game
			LGSUser* newUser = [[[LGSUser alloc] init] autorelease];
			[newUser setName:userName];
			[newUser setCardID:[[self initDatas] valueForKey:@"statupCard"]];
			[LGSUser setSharedUser:newUser];
			
			[appDelegate changeLGSController:@"PlatformIntro"];
		}
	}
	else if(sender == loadUserPromptView)
	{
		[loadUserPromptView hide];
		
		if([loadUserPromptView currentPromptAction] == YES)
		{
			NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
      		NSString* loadPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"save.lgs"];
			NSDictionary* rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile:loadPath];
			if(rootObject)
			{
				//load a game
				[LGSUser setSharedUser:[rootObject valueForKey:@"user"]];
				[appDelegate changeLGSController:@"PlatformGame"];
			}
		}
	}
	else if(sender == infoView)
	{
		[infoMsgView toggle];
	}
	else if(sender == infoMsgView)
	{
		[infoMsgView hide];
	}

	[self.view reDisplay];
}

@end
