/**
 *  LGSPlatformMainViewController.m
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

#import "UKImage.h"

#import "LGSPlatformMainViewController.h"

#import "LGSPlatformBoxView.h"
#import "LGSPlatformPromptTextView.h"

@implementation LGSPlatformMainViewController

-(BOOL) start
{
	//background image
	NSString* backgroundImagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:[[self initDatas] valueForKey:@"backgroundImage"]];
	UIImage* backgroundImage = [[[[UIImage alloc] initWithContentsOfFile:backgroundImagePath] autorelease] rotate:UIImageOrientationRight];
	UIImageView* backgroundImageView = [[[UIImageView alloc] initWithFrame:self.view.bounds] autorelease];

	[backgroundImageView setImage:backgroundImage];

	[self.view addSubview:backgroundImageView];

	//info view
	NSString* infoImagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/Datas/Images/19678.png"];
	UIImage* infoImage = [[[[UIImage alloc] initWithContentsOfFile:infoImagePath] autorelease] rotate:UIImageOrientationRight];
	UIImageView* infoViewImage = [[[UIImageView alloc] initWithFrame:CGRectMake(320 - 24, 480 - 30, 16, 20)] autorelease];
	
	[infoViewImage setUserInteractionEnabled:YES];
	[infoViewImage setImage:infoImage];
	
	[self.view addSubview:infoViewImage];
	
	//notes : UIImageView do not handle events (inherit from UIView), so we add an invisible UIControl inside the UIImageView to manage touch events
	infoView = [[[UIControl alloc] initWithFrame:CGRectMake(0, 0, 16, 20)] autorelease];
	[infoView addToView:infoViewImage withTarget:self isHidden:NO];
	
	infoMsgView = [LGSPlatformBoxView viewWithFrame:CGRectMake(165, 155, 300, 125) andText:@"" rotate:LGSBoxViewOrientationRight andType:LGSBoxViewTypeText];
	
	[infoMsgView addToView:self.view withTarget:self isHidden:YES];
	
	//buttons and texts
	/** not available now
	teacherView = [LGSPlatformBoxView viewWithFrame:CGRectMake(4, 12, 113, 27) andText:@"professeur" rotate:LGSBoxViewOrientationRight andType:LGSBoxViewTypeButton];
	studentView = [LGSPlatformBoxView viewWithFrame:CGRectMake(4, 137, 113, 27) andText:@"élève" rotate:LGSBoxViewOrientationRight andType:LGSBoxViewTypeButton];
	studentMenuView = [LGSPlatformBoxView viewWithFrame:CGRectMake(44, 90, 203, 101) andText:@"#Commencer une nouvelle aventure.#\n#Reprendre une ancienne.#\n\n#Charger les fichiers de questions.#\n\n#Annuler.#" rotate:LGSBoxViewOrientationRight];
	newUserPromptView = [LGSPlatformPromptTextView viewWithFrame:CGRectMake(120, 90, 300, 80) andText:@"Quel est ton prénom, aventurier." rotate:LGSBoxViewOrientationRight];

	[teacherView addToView:self.view withTarget:self isHidden:NO];
	[studentView addToView:self.view withTarget:self isHidden:NO];
	[studentMenuView addToView:self.view withTarget:self isHidden:YES];
	[newUserPromptView addToView:self.view withTarget:self isHidden:YES];
	 */

	studentView = [LGSPlatformBoxView viewWithFrame:CGRectMake(4, 12, 113, 27) andText:@"élève" rotate:LGSBoxViewOrientationRight andType:LGSBoxViewTypeButton];
	studentMenuView = [LGSPlatformBoxView viewWithFrame:CGRectMake(44, 12, 203, 71) andText:@"#Commencer une nouvelle aventure.#\n#Reprendre une ancienne.#\n\n#Annuler.#" rotate:LGSBoxViewOrientationRight];
	newUserPromptView = [LGSPlatformPromptTextView viewWithFrame:CGRectMake(150, 90, 300, 80) andText:@"Quel est ton prénom, aventurier." rotate:LGSBoxViewOrientationRight];
	loadUserPromptView = [LGSPlatformPromptView viewWithFrame:CGRectMake(150, 90, 300, 80) andText:@"" rotate:LGSBoxViewOrientationRight];

	[studentView addToView:self.view withTarget:self isHidden:NO];
	[studentMenuView addToView:self.view withTarget:self isHidden:YES];
	[newUserPromptView addToView:self.view withTarget:self isHidden:YES];
	[loadUserPromptView addToView:self.view withTarget:self isHidden:YES];
	
	if(![super start])
	{
		return NO;
	}
	
	return YES;
}

@end
