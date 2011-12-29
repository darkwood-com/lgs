/**
 *  LGSGameViewController.h
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

#import "LGSPlatformDefaultViewController.h"

#import "LGSBoxView.h"

typedef enum
{
	LGSGameActionCurrent,   //on current action
	LGSGameActionOpenCard,  //on open card action
	LGSGameActionCloseCard, //on close card action
} LGSGameAction;

typedef enum
{
	LGSGameModeNormal,   //mode normal
	LGSGameModeQuestion, //mode question
} LGSGameMode;

@interface LGSGameViewController : LGSPlatformDefaultViewController {
	LGSBoxView* positionView; //card position box
	LGSBoxView* descriptionView; //card description box
	LGSBoxView* actionView; //card action box
	LGSBoxView* msgView; //card message box

	LGSImageView* cameraView; //curent card image display
	LGSImageView* heroView; //display hero view
	LGSControl* angelView; //display angel view
	LGSControl* bagView; //display bag view
	LGSControl* saveView; //display save view
	LGSControl* mapView; //display map view
	
	NSMutableDictionary* mode; //mode (normal or question + params)
	NSMutableDictionary* actions; //card actions
	NSMutableDictionary* boxViewMessages; //NSMutableDictionary<LGSBoxView => NSString>, message alterated before display
	NSMutableDictionary* boxOriginalViewMessages; //NSMutableDictionary<LGSBoxView => NSString>, message original from the card (not alterated)
}

@property (readonly) LGSControl* saveView;

-(LGSCard*) goCard:(NSString*) cardID;
-(void) refreshTextViews;
-(void) lgsCustomActions:(LGSGameAction) actionEvent currentAction:(NSString*) currentAction;

@end
