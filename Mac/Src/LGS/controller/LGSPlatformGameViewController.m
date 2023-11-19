/**
 *  LGSPlatformGameViewController.m
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

#import "LGSPlatformGameViewController.h"

#import "LGSPlatformBoxView.h"
#import "LGSPlatformSurfaceView.h"

@implementation LGSPlatformGameViewController

-(BOOL) start
{
	NSView* contentWindowView = [[self.view window] contentView];
	if(![super start] || contentWindowView == nil)
	{
		return NO;
	}
	
	NSSize frameRatio = NSMakeSize(contentWindowView.frame.size.width / 512, contentWindowView.frame.size.height / 342); //ratio scale according to original window size (512x342)
	
	//background image
	NSString* backgroundImagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/Datas/Images/8980.png"];
	NSImage* backgroundImage = [[[NSImage alloc] initWithContentsOfFile:backgroundImagePath] autorelease];
	NSImageView* backgroundImageView = [[[NSImageView alloc] initWithFrame:self.view.bounds] autorelease];

	[backgroundImageView setImage:backgroundImage];
	[backgroundImageView setImageScaling:NSScaleToFit];
	[backgroundImageView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];

	[self.view addSubview:backgroundImageView];

	//camera view
	cameraView = [[[NSImageView alloc] initWithFrame:LGSMakeResizeRect(167, 127, 344, 214, frameRatio)] autorelease];
	
	[cameraView setImageScaling:NSScaleToFit];
	[cameraView setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin | NSViewWidthSizable | NSViewMinYMargin | NSViewMaxYMargin | NSViewHeightSizable];
	
	[backgroundImageView addSubview:cameraView];

	//angel view
	NSString* angelImagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/Datas/Images/10564.png"];
	NSImage* angelImage = [[[NSImage alloc] initWithContentsOfFile:angelImagePath] autorelease];
	NSImageView* angelViewImage = [[[NSImageView alloc] initWithFrame:LGSMakeResizeRect(135, 2, 32, 32, frameRatio)] autorelease];

	[angelViewImage setImage:angelImage];
	[angelViewImage setImageScaling:NSScaleToFit];
	[angelViewImage setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin | NSViewWidthSizable | NSViewMinYMargin | NSViewMaxYMargin | NSViewHeightSizable];

	[angelViewImage addToView:self.view withTarget:self isHidden:YES];

	angelView = angelViewImage;
	
	//bag view
	NSString* bagImagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/Datas/Images/10311.png"];
	NSImage* bagImage = [[[NSImage alloc] initWithContentsOfFile:bagImagePath] autorelease];
	NSImageView* bagViewImage = [[[NSImageView alloc] initWithFrame:LGSMakeResizeRect(78, 6, 49, 28, frameRatio)] autorelease];
	
	[bagViewImage setImage:bagImage];
	[bagViewImage setImageScaling:NSScaleToFit];
	[bagViewImage setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin | NSViewWidthSizable | NSViewMinYMargin | NSViewMaxYMargin | NSViewHeightSizable];
	
	[bagViewImage addToView:self.view withTarget:self isHidden:NO];
	
	bagView = bagViewImage;
	
	//save view
	NSString* saveImagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/Datas/Images/13710.png"];
	NSImage* saveImage = [[[NSImage alloc] initWithContentsOfFile:saveImagePath] autorelease];
	NSImageView* saveViewImage = [[[NSImageView alloc] initWithFrame:LGSMakeResizeRect(28, 1, 39, 34, frameRatio)] autorelease];
	
	[saveViewImage setImage:saveImage];
	[saveViewImage setImageScaling:NSScaleToFit];
	[saveViewImage setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin | NSViewWidthSizable | NSViewMinYMargin | NSViewMaxYMargin | NSViewHeightSizable];
	
	[saveViewImage addToView:self.view withTarget:self isHidden:NO];
	
	saveView = saveViewImage;
	
	//map view
	NSString* mapImagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/Datas/Images/16012.png"];
	NSImage* mapImage = [[[NSImage alloc] initWithContentsOfFile:mapImagePath] autorelease];
	NSImageView* mapViewImage = [[[NSImageView alloc] initWithFrame:LGSMakeResizeRect(0, 205, 162, 137, frameRatio)] autorelease];
	
	[mapViewImage setImage:mapImage];
	[mapViewImage setImageScaling:NSScaleToFit];
	[mapViewImage setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin | NSViewWidthSizable | NSViewMinYMargin | NSViewMaxYMargin | NSViewHeightSizable];
	
	[mapViewImage addToView:self.view withTarget:self isHidden:NO];
	
	mapView = mapViewImage;

	//hero view
	NSString* heroImagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/Datas/Images/5738.png"];
	NSImage* heroImage = [[[NSImage alloc] initWithContentsOfFile:heroImagePath] autorelease];
	heroView = [[[NSImageView alloc] initWithFrame:LGSMakeResizeRect(0, 342 - 15, 15, 15, frameRatio)] autorelease];
	
	[heroView setImage:heroImage];
	[heroView setImageScaling:NSScaleToFit];
	[heroView setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin | NSViewWidthSizable | NSViewMinYMargin | NSViewMaxYMargin | NSViewHeightSizable];
	
	[self.view addSubview:heroView];
	
	//buttons and texts
	positionView = [LGSPlatformBoxView viewWithFrame:LGSMakeRect(2, 342 - 217, 162, 70) andText:@""];
	descriptionView = [LGSPlatformBoxView viewWithFrame:LGSMakeRect(2, 342 - 306, 298, 87) andText:@""];
	actionView = [LGSPlatformBoxView viewWithFrame:LGSMakeRect(300, 342 - 306, 211, 87) andText:@""];
	msgView = [LGSPlatformBoxView viewWithFrame:LGSMakeRect(2, 342 - 306, (300 - 2) + 211, 87) andText:@"" andType:LGSBoxViewTypeButtonText];

	[positionView addToView:self.view withTarget:self isHidden:NO];
	[descriptionView addToView:self.view withTarget:self isHidden:NO];
	[actionView addToView:self.view withTarget:self isHidden:NO];
	[msgView addToView:self.view withTarget:self isHidden:YES];

	[positionView resizeWithOldSuperviewSize:NSMakeSize(512, 342)];
	[descriptionView resizeWithOldSuperviewSize:NSMakeSize(512, 342)];
	[actionView resizeWithOldSuperviewSize:NSMakeSize(512, 342)];
	[msgView resizeWithOldSuperviewSize:NSMakeSize(512, 342)];
	
	[self goCard:user.cardID];

	return YES;
}

-(LGSCard*) goCard:(NSString*) cardID
{
	NSView* contentWindowView = [[self.view window] contentView];
	NSSize frameRatio = NSMakeSize(contentWindowView.frame.size.width / 512, contentWindowView.frame.size.height / 342); //ratio scale according to original window size (512x342)
	
	LGSCard* card = [super goCard:cardID];

	if([[card messageFromKey:@"angel"] isEqualToString:@""])
	{
		[angelView hide];
	}
	else
	{
		[angelView show];
	}
  
	if(card.coords.x > 0 || card.coords.y > 0)
	{
		[heroView setFrame:LGSMakeResizeRect(card.coords.x - 10, 342 - 8 - card.coords.y, 15, 15, frameRatio)];
	}

	NSString* cameraImagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:[card imagePath]];
	NSImage* cameraImage = [[[NSImage alloc] initWithContentsOfFile:cameraImagePath] autorelease];

	[cameraView setImage:cameraImage];

	for(NSValue* surface in card.surfaces)
	{
		NSRect surfaceRect = [surface rectValue];
		surfaceRect.origin.x -= 167;
		surfaceRect.origin.y = 214 - surfaceRect.origin.y - surfaceRect.size.height;
		LGSPlatformSurfaceView* surfaceView = [[[LGSPlatformSurfaceView alloc] initWithFrame:surfaceRect andAction:[card.surfaces objectForKey:surface]] autorelease];

		//<-- debug -->
		//LGSPlatformBoxView* surfaceView = [[[LGSPlatformBoxView alloc] initWithFrame:surfaceRect andText:[card.surfaces objectForKey:surface] andType:LGSBoxViewTypeButton] autorelease];
		//<-- debug -->

		[surfaceView addToView:cameraView withTarget:self isHidden:NO];
		[surfaceView resizeWithOldSuperviewSize:NSMakeSize(344, 214)];
	}

	return card;
}

@end
