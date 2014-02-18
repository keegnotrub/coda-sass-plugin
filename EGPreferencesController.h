//
//  EGPreferencesController.h
//  Sass
//
//  Created by Ryan Krug on 2/16/14.
//
//

#import <Cocoa/Cocoa.h>

@interface EGPreferencesController : NSWindowController<NSWindowDelegate>
{
	BOOL isModal;
	IBOutlet NSPopUpButton *outputStyleButton;
	IBOutlet NSPopUpButton *debugStyleButton;
}

- (void) runModal;

@end
