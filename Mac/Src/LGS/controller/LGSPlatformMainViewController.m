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

#import "LGSPlatformMainViewController.h"

#import "LGSPlatformBoxView.h"
#import "LGSPlatformPromptTextView.h"

@implementation LGSPlatformMainViewController

-(BOOL) start
{
	NSView* contentWindowView = [[self.view window] contentView];
	if(![super start] || contentWindowView == nil)
	{
		return NO;
	}
	
	NSSize frameRatio = NSMakeSize(contentWindowView.frame.size.width / 512, contentWindowView.frame.size.height / 342); //ratio scale according to original window size (512x342)
	
	//background image
	NSString* backgroundImagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:[[self initDatas] valueForKey:@"backgroundImage"]];
	NSImage* backgroundImage = [[[NSImage alloc] initWithContentsOfFile:backgroundImagePath] autorelease];
	NSImageView* backgroundImageView = [[[NSImageView alloc] initWithFrame:self.view.bounds] autorelease];

	[backgroundImageView setImage:backgroundImage];
	[backgroundImageView setImageScaling:NSScaleToFit];
	[backgroundImageView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];

	[self.view addSubview:backgroundImageView];
	
	//info view
	NSString* infoImagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/Datas/Images/19678.png"];
	NSImage* infoImage = [[[NSImage alloc] initWithContentsOfFile:infoImagePath] autorelease];
	NSImageView* infoViewImage = [[[NSImageView alloc] initWithFrame:LGSMakeResizeRect(512 - 24, 342 - 20, 20, 16, frameRatio)] autorelease];
	
	[infoViewImage setImage:infoImage];
	[infoViewImage setImageScaling:NSScaleToFit];
	[infoViewImage setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin | NSViewWidthSizable | NSViewMinYMargin | NSViewMaxYMargin | NSViewHeightSizable];
	
	[infoViewImage addToView:self.view withTarget:self isHidden:NO];
	
	infoView = infoViewImage;

	infoMsgView = [LGSPlatformBoxView viewWithFrame:NSMakeRect(185, 185, 300, 125) andText:@"" andType:LGSBoxViewTypeButtonText];
	
	[infoMsgView addToView:self.view withTarget:self isHidden:YES];
	[infoMsgView resizeWithOldSuperviewSize:NSMakeSize(512, 342)];
	
	//buttons and texts
	/** not available now
	teacherView = [LGSPlatformBoxView viewWithFrame:NSMakeRect(12, 4, 113, 27) andText:@"professeur" andType:LGSBoxViewTypeButton];
	studentView = [LGSPlatformBoxView viewWithFrame:NSMakeRect(137, 4, 113, 27) andText:@"élève" andType:LGSBoxViewTypeButton];
	studentMenuView = [LGSPlatformBoxView viewWithFrame:NSMakeRect(90, 44, 203, 101) andText:@"#Commencer une nouvelle aventure.#\n#Reprendre une ancienne.#\n\n#Charger les fichiers de questions.#\n\n#Annuler.#"];
	newUserPromptView = [LGSPlatformPromptTextView viewWithFrame:NSMakeRect(106, 131, 300, 80) andText:@"Quel est ton prénom, aventurier."];

	[teacherView addToView:self.view withTarget:self isHidden:NO];
	[studentView addToView:self.view withTarget:self isHidden:NO];
	[studentMenuView addToView:self.view withTarget:self isHidden:YES];
	[newUserPromptView addToView:self.view withTarget:self isHidden:YES];
	 */

	studentView = [LGSPlatformBoxView viewWithFrame:NSMakeRect(12, 4, 113, 27) andText:@"Menu" andType:LGSBoxViewTypeButton];
	studentMenuView = [LGSPlatformBoxView viewWithFrame:NSMakeRect(12, 44, 203, 71) andText:@"#Commencer une nouvelle aventure.#\n#Reprendre une ancienne.#\n\n#Annuler.#"];
	newUserPromptView = [LGSPlatformPromptTextView viewWithFrame:NSMakeRect(106, 131, 300, 80) andText:@"Quel est ton prénom, aventurier."];
	loadUserPromptView = [LGSPlatformPromptView viewWithFrame:NSMakeRect(106, 131, 300, 80) andText:@""];
	
	[studentView addToView:self.view withTarget:self isHidden:NO];
	[studentMenuView addToView:self.view withTarget:self isHidden:YES];
	[newUserPromptView addToView:self.view withTarget:self isHidden:YES];
	[loadUserPromptView addToView:self.view withTarget:self isHidden:YES];
	
	[studentView resizeWithOldSuperviewSize:NSMakeSize(512, 342)];
	[studentMenuView resizeWithOldSuperviewSize:NSMakeSize(512, 342)];
	[newUserPromptView resizeWithOldSuperviewSize:NSMakeSize(512, 342)];
	[loadUserPromptView resizeWithOldSuperviewSize:NSMakeSize(512, 342)];
	
	if(![super start])
	{
		return NO;
	}
	
	return YES;
}

@end
