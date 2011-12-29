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

#import "LGSAdditionControl.h"
#import "LGSAdditionView.h"
#import "LGSPlatformGameViewController.h"
#import "LGSPlatformSurfaceView.h"
#import "UKImage.h"
#import "LGSDefaultViewController.h"

@implementation LGSPlatformGameViewController

-(BOOL) start
{
	[super start];

	LGSView* mainView = [LGSDefaultViewController getMainView];
	CGSize frameRatio = CGSizeMake(mainView.frame.size.width / 342, mainView.frame.size.height / 512); //ratio scale according to original window size (512x342)
	CGSize switchFrameRatio = CGSizeMake(frameRatio.height, frameRatio.width); //ratio scale according to original window size (512x342)
	
	//background image
	NSString* backgroundImagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/Datas/Images/8980.png"];
	UIImage* backgroundImage = [[[[UIImage alloc] initWithContentsOfFile:backgroundImagePath] autorelease] rotate:UIImageOrientationRight];
	UIImageView* backgroundImageView = [[[UIImageView alloc] initWithFrame:self.view.bounds] autorelease];

	[backgroundImageView setUserInteractionEnabled:YES];
	[backgroundImageView setImage:backgroundImage];
	[backgroundImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

	[self.view addSubview:backgroundImageView];

	//camera view
	cameraView = [[[UIImageView alloc] initWithFrame:LGSMakeResizeRect(127, 167, 214, 344, frameRatio)] autorelease];
	[cameraView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight];
	[cameraView setUserInteractionEnabled:YES];

	[backgroundImageView addSubview:cameraView];
	
	//angel view
	NSString* angelImagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/Datas/Images/10564.png"];
	UIImage* angelImage = [[[[UIImage alloc] initWithContentsOfFile:angelImagePath] autorelease] rotate:UIImageOrientationRight];
	UIImageView* angelViewImage = [[[UIImageView alloc] initWithFrame:LGSMakeResizeRect(2, 135, 32, 32, frameRatio)] autorelease];

	[angelViewImage setUserInteractionEnabled:YES];
	[angelViewImage setImage:angelImage];
	[angelViewImage setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight];

	[self.view addSubview:angelViewImage];

	//notes : UIImageView do not handle events (inherit from UIView), so we add an invisible UIControl inside the UIImageView to manage touch events
	angelView = [[[UIControl alloc] initWithFrame:LGSMakeResizeRect(0, 0, 32, 32, frameRatio)] autorelease];
	[angelView addToView:angelViewImage withTarget:self isHidden:NO];
	
	//bag view
	NSString* bagImagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/Datas/Images/10311.png"];
	UIImage* bagImage = [[[[UIImage alloc] initWithContentsOfFile:bagImagePath] autorelease] rotate:UIImageOrientationRight];
	UIImageView* bagViewImage = [[[UIImageView alloc] initWithFrame:LGSMakeResizeRect(6, 78, 28, 49, frameRatio)] autorelease];
	
	[bagViewImage setUserInteractionEnabled:YES];
	[bagViewImage setImage:bagImage];
	[bagViewImage setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight];
	
	[self.view addSubview:bagViewImage];
	
	//notes : UIImageView do not handle events (inherit from UIView), so we add an invisible UIControl inside the UIImageView to manage touch events
	bagView = [[[UIControl alloc] initWithFrame:LGSMakeResizeRect(0, 0, 28, 49, frameRatio)] autorelease];
	[bagView addToView:bagViewImage withTarget:self isHidden:NO];
	
	//save view
	NSString* saveImagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/Datas/Images/13710.png"];
	UIImage* saveImage = [[[[UIImage alloc] initWithContentsOfFile:saveImagePath] autorelease] rotate:UIImageOrientationRight];
	UIImageView* saveViewImage = [[[UIImageView alloc] initWithFrame:LGSMakeResizeRect(1, 28, 34, 39, frameRatio)] autorelease];
	
	[saveViewImage setUserInteractionEnabled:YES];
	[saveViewImage setImage:saveImage];
	[saveViewImage setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight];
	
	[self.view addSubview:saveViewImage];
	
	//notes : UIImageView do not handle events (inherit from UIView), so we add an invisible UIControl inside the UIImageView to manage touch events
	saveView = [[[UIControl alloc] initWithFrame:LGSMakeResizeRect(0, 0, 34, 39, frameRatio)] autorelease];
	[saveView addToView:saveViewImage withTarget:self isHidden:NO];

	//map view
	NSString* mapImagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/Datas/Images/16012.png"];
	UIImage* mapImage = [[[[UIImage alloc] initWithContentsOfFile:mapImagePath] autorelease] rotate:UIImageOrientationRight];
	UIImageView* mapViewImage = [[[UIImageView alloc] initWithFrame:LGSMakeResizeRect(205, 0, 137, 162, frameRatio)] autorelease];
	
	[mapViewImage setUserInteractionEnabled:YES];
	[mapViewImage setImage:mapImage];
	[mapViewImage setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight];
	
	[self.view addSubview:mapViewImage];
	
	//notes : UIImageView do not handle events (inherit from UIView), so we add an invisible UIControl inside the UIImageView to manage touch events
	mapView = [[[UIControl alloc] initWithFrame:CGRectMake(0, 0, 137, 162)] autorelease];
	[mapView addToView:mapViewImage withTarget:self isHidden:NO];
	
	//hero view
	NSString* heroImagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/Datas/Images/5738.png"];
	UIImage* heroImage = [[[[UIImage alloc] initWithContentsOfFile:heroImagePath] autorelease] rotate:UIImageOrientationRight];
	heroView = [[[UIImageView alloc] initWithFrame:LGSMakeResizeRect(342 - 15 * frameRatio.width, 0, 15, 15, frameRatio)] autorelease];
	
	[heroView setImage:heroImage];
	[heroView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight];
	
	[self.view addSubview:heroView];
	
	//buttons and texts
	positionView = [LGSPlatformBoxView viewWithFrame:LGSMakeResizeRect(141, 2, 162, 70, switchFrameRatio) andText:@"" rotate:LGSBoxViewOrientationRight];
	descriptionView = [LGSPlatformBoxView viewWithFrame:LGSMakeResizeRect(41, 2, 298, 87, switchFrameRatio) andText:@"" rotate:LGSBoxViewOrientationRight];
	actionView = [LGSPlatformBoxView viewWithFrame:LGSMakeResizeRect(41, 268, 211, 87, switchFrameRatio) andText:@"" rotate:LGSBoxViewOrientationRight];
	msgView = [LGSPlatformBoxView viewWithFrame:LGSMakeResizeRect(41, 2, (300 - 2) + 211, 87, switchFrameRatio) andText:@"" rotate:LGSBoxViewOrientationRight andType:LGSBoxViewTypeButtonText];
	
	[positionView addToView:self.view withTarget:self isHidden:NO];
	[descriptionView addToView:self.view withTarget:self isHidden:NO];
	[actionView addToView:self.view withTarget:self isHidden:NO];
	[msgView addToView:self.view withTarget:self isHidden:YES];
	
	[self goCard:user.cardID];

	return YES;
}

-(LGSCard*) goCard:(NSString*) cardID
{
	CGSize frameRatio = CGSizeMake(self.view.frame.size.width / 342, self.view.frame.size.height / 512); //ratio scale according to original window size (512x342)
	CGSize switchFrameRatio = CGSizeMake(frameRatio.height, frameRatio.width); //ratio scale according to original window size (512x342)
	
	LGSCard* card = [super goCard:cardID];

  if([[card messageFromKey:@"angel"] isEqualToString:@""])
	{
		[angelView.superview hide];
	}
	else
	{
		[angelView.superview show];
	}
  
	if(card.coords.x > 0 || card.coords.y > 0)
	{
		[heroView setFrame:LGSMakeResizeRect(342 - 8 - card.coords.y, card.coords.x - 10, 15, 15, frameRatio)];
	}
	
	NSString* cameraImagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:[card imagePath]];
	UIImage* cameraImage = [[[[UIImage alloc] initWithContentsOfFile:cameraImagePath] autorelease] rotate:UIImageOrientationRight];

	[cameraView setImage:cameraImage];

	for(NSValue* surface in card.surfaces)
	{
		CGRect surfaceRectInv = [surface CGRectValue];
		CGRect surfaceRect = surfaceRectInv;
		
		surfaceRect.origin.x = surfaceRectInv.origin.y;
		surfaceRect.origin.y = surfaceRectInv.origin.x;
		
		surfaceRect.size.width *= switchFrameRatio.width;
		surfaceRect.size.height *= switchFrameRatio.height;

		surfaceRect.origin.x = 214 - surfaceRectInv.origin.y - surfaceRectInv.size.height;
		surfaceRect.origin.y -= 167;
		
		surfaceRect.origin.x *= frameRatio.width;
		surfaceRect.origin.y *= frameRatio.height;

		LGSPlatformSurfaceView* surfaceView = [[[LGSPlatformSurfaceView alloc] initWithFrame:surfaceRect andAction:[card.surfaces objectForKey:surface] rotate:LGSBoxViewOrientationRight] autorelease];

		//LGSPlatformBoxView* surfaceView = [[[LGSPlatformBoxView alloc] initWithFrame:surfaceRect andText:[card.surfaces objectForKey:surface] rotate:LGSBoxViewOrientationRight andType:LGSBoxViewTypeButton] autorelease];

		[surfaceView addToView:cameraView withTarget:self isHidden:NO];
	}

	return card;
}

@end
