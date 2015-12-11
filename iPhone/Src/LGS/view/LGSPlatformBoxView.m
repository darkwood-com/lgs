/**
 *  LGSPlatformBoxView.m
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

#import "CMGlyphDrawing.h"

#import "LGSPlatformBoxView.h"

#import "LGSFontManager.h"
#import "LGSDefaultViewController.h"

@implementation LGSPlatformBoxView

-(id) initWithFrame:(CGRect) frameRect andText:(NSString*) aString
{
	return [self initWithFrame:frameRect andText:aString rotate:LGSBoxViewOrientationUp andType:LGSBoxViewTypeText];
}

-(id) initWithFrame:(CGRect) frameRect andText:(id) aString rotate:(LGSBoxViewOrientation) orient
{
	return [self initWithFrame:frameRect andText:aString rotate:orient andType:LGSBoxViewTypeText];
}

-(id) initWithFrame:(CGRect) frameRect andText:(id) aString rotate:(LGSBoxViewOrientation) orient andType:(LGSBoxViewType) aType
{
	if(self = [super initWithFrame:frameRect])
	{
		textValue = aString;
		type = aType;
		actionsRect = [[NSMutableDictionary alloc] init];
		orientation = orient;
		originalSize = frameRect.size;

		[self setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight];
		
		[self setOpaque:NO];

		switch(orientation)
		{
		  case LGSBoxViewOrientationRight:
			  [self setTransform:CGAffineTransformMakeRotation(M_PI / 2.0)];
			  [self setFrame:CGRectMake(frameRect.origin.x, frameRect.origin.y, frameRect.size.height, frameRect.size.width)];
			  break;

		  default:
			  break;
		}
	}
	return self;
}

+(id) viewWithFrame:(CGRect) frameRect andText:(id) aString
{
	return [[[self alloc] initWithFrame:frameRect andText:aString] autorelease];
}

+(id) viewWithFrame:(CGRect) frameRect andText:(id) aString rotate:(LGSBoxViewOrientation) orient
{
	return [[[self alloc] initWithFrame:frameRect andText:aString rotate:orient] autorelease];
}

+(id) viewWithFrame:(CGRect) frameRect andText:(id) aString rotate:(LGSBoxViewOrientation) orient andType:(LGSBoxViewType) aType;
{
	return [[[self alloc] initWithFrame:frameRect andText:aString rotate:orient andType:aType] autorelease];
}

-(void) drawRect:(CGRect) rect
{
	LGSView* mainView = [LGSDefaultViewController getMainView];
	CGSize frameRatio = CGSizeMake(mainView.frame.size.width / 342, mainView.frame.size.height / 512); //ratio scale according to original window size (512x342)
    frameRatio = CGSizeMake(1.0, 1.0);
	CGSize invframeRatio = CGSizeMake(1.0 / frameRatio.width, 1.0 / frameRatio.height); //ratio scale according to original window size (512x342)
    invframeRatio = CGSizeMake(1.0, 1.0);

	CGContextRef context = UIGraphicsGetCurrentContext();

	CGContextSaveGState(context);
	CGContextSetShouldAntialias(context, FALSE);

	CGAffineTransform  tran = CGAffineTransformIdentity;
	tran = CGAffineTransformScale(tran, 1, -1);
	CGContextSetTextMatrix(context, tran);
	CGContextScaleCTM(context, frameRatio.width, frameRatio.height);
	
	rect = CGRectMake(rect.origin.x, rect.origin.y, originalSize.width, originalSize.height);
	
	//clear view
	CGContextSetRGBFillColor(context, 1, 1, 1, 1);
	CGContextAddRect(context, LGSMakeResizeRect(rect.origin.x + 1, rect.origin.y + 1, rect.size.width - 3, rect.size.height - 3, invframeRatio));
	CGContextFillPath(context);

	//draw background
	CGContextSetRGBFillColor(context, 0, 0, 0, 1);
	CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);

	CGPoint points[] = {
		CGPointMake(rect.origin.x + 2, rect.origin.y + rect.size.height),
		CGPointMake(rect.size.width - 1, rect.size.height),
		CGPointMake(rect.size.width - 1, rect.origin.y + 3),
	};
	CGContextAddLines(context, points, 3);
	CGContextAddRect(context, LGSMakeResizeRect(rect.origin.x, rect.origin.y + 1, rect.size.width - 2, rect.size.height - 2, invframeRatio));
	CGContextStrokePath(context);

	//draw text
	CGFontRef font = [[LGSFontManager sharedFontManager] getFont:@"/Datas/Fonts/lgsfont.ttf"];
	CGContextSetFont(context, font);
	CGContextSetFontSize(context, 16.0f);

	//split text into lines
	[actionsRect removeAllObjects];
	CGPoint basePosition = CGPointMake(4, 13);
	CGFloat lineHeight = 16;
	NSArray* lines = [textValue componentsSeparatedByString:@"\n"];
	NSInteger autoLines = 0;
	for(NSInteger lineIndex = 0; lineIndex < [lines count]; lineIndex++)
	{
		NSString* line = [lines objectAtIndex:lineIndex];
		NSInteger length = [line length];
		CGGlyph glyphs[length];
		UniChar characters[length];
		[line getCharacters:characters range:NSMakeRange(0, length)];
		CMFontGetGlyphsForUnichars(font, characters, glyphs, length);

		CGPoint beginPosition = basePosition;
		if(type == LGSBoxViewTypeButton)
		{
			//calculate center text position for button
			CGContextSetTextDrawingMode(context, kCGTextInvisible);
			CGContextShowGlyphsAtPoint(context, 0, -10, glyphs, length);

			beginPosition = CGContextGetTextPosition(context);
			beginPosition.x = (rect.size.width * invframeRatio.width - beginPosition.x) / 2.0f;
			basePosition.y = (rect.size.height * invframeRatio.height - beginPosition.y) / 2.0f;
		}

		//we also calculate coords of text action (surrounded beetween #action#)
		NSInteger pos = 0;
		CGPoint lastPosition = beginPosition;
		NSArray* actions = [line componentsSeparatedByString:@"#"];
		for(NSInteger actionIndex = 0; actionIndex < [actions count]; actionIndex++)
		{
			NSString* action = [actions objectAtIndex:actionIndex];

			if([action isEqualToString:@""])
			{
				pos += 1;
				continue;
			}

			CGPoint actionPosition;
			actionPosition.x = lastPosition.x;
			actionPosition.y = basePosition.y + (lineIndex + autoLines) * lineHeight;

			//new line if words are not in draw rect
			NSArray* words = [action componentsSeparatedByString:@" "];
			for(NSInteger wordIndex = 0; wordIndex < [words count]; wordIndex++)
			{
				NSString* word = [words objectAtIndex:wordIndex];
				NSInteger wordLength = [word length];
				if(([line length] > pos + wordLength) && ([line characterAtIndex:(pos + wordLength)] == ' '))
				{
					wordLength += 1;
				}
				beginPosition.x = lastPosition.x;
				beginPosition.y = basePosition.y + (lineIndex + autoLines) * lineHeight;

				CGContextSetTextDrawingMode(context, kCGTextInvisible);
				CGContextShowGlyphsAtPoint(context, beginPosition.x, beginPosition.y, &glyphs[pos], wordLength);
				lastPosition = CGContextGetTextPosition(context);
				if(lastPosition.x > rect.size.width * invframeRatio.width)
				{
					autoLines += 1;
					beginPosition.x = basePosition.x;
					beginPosition.y = basePosition.y + (lineIndex + autoLines) * lineHeight;
				}

				CGContextSetTextDrawingMode(context, kCGTextFill);
				CGContextShowGlyphsAtPoint(context, beginPosition.x, beginPosition.y, &glyphs[pos], wordLength);
				lastPosition = CGContextGetTextPosition(context);

				pos += wordLength;
			}

			//create an action rect
			if(actionIndex % 2 == 1)
			{
				CGRect actionRect = LGSMakeResizeRect(actionPosition.x, actionPosition.y - lineHeight + lineHeight / 4.0f, abs(lastPosition.x - actionPosition.x), lineHeight, frameRatio);
				[actionsRect setObject:[NSValue valueWithCGRect:actionRect] forKey:action];

				//CGContextAddRect(context, CGRectMake(actionPosition.x, actionPosition.y - lineHeight + lineHeight / 4.0f, abs(lastPosition.x - actionPosition.x), lineHeight));
				//CGContextStrokePath(context);
			}
		}
	}

	CGContextRestoreGState(context);
}

-(void) touchesBegan:(NSSet*) touches withEvent:(UIEvent*) event
{
	currentAction = @"";
	if((type == LGSBoxViewTypeButton) || (type == LGSBoxViewTypeButtonText))
	{
		//the whole button is an action
		currentAction = textValue;
		[self sendActionToTarget];
	}
	else
	{
		CGPoint clickPoint = [[touches anyObject] locationInView:self];
		for(NSString* anAction in actionsRect)
		{
			CGRect actionRect = [[actionsRect objectForKey:anAction] CGRectValue];
			if(CGRectContainsPoint(actionRect, clickPoint))
			{
				currentAction = anAction;
				[self sendActionToTarget];
			}
		}
	}
}

-(void) dealloc
{
	[actionsRect release];
	[super dealloc];
}

@end
