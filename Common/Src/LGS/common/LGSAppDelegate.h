/**
 *  LGSAppDelegate.h
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

#import "LGSDefaultViewController.h"
#import "LGSTypes.h"

@interface LGSAppDelegate : LGSApplicationDelegateObject {
	LGSWindow* window;
	LGSView* view;
	
	LGSDefaultViewController* mainController;
}

#if defined(D_IOS)

@property (nonatomic, retain) IBOutlet UIWindow* window;
@property (nonatomic, retain) IBOutlet UIView* view;

#endif

#ifdef D_MAC

@property (retain) IBOutlet NSWindow* window;
@property (retain) IBOutlet NSView* view;

- (IBAction)newGame:(NSMenuItem *)sender;
- (IBAction)revertToSaved:(NSMenuItem *)sender;
- (IBAction)saveGame:(NSMenuItem *)sender;

#endif

-(void) changeLGSController:(NSString*) lgsControllerName;

@end
