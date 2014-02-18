//
//  EGPreferencesController.m
//  Sass
//
//  Created by Ryan Krug on 2/16/14.
//
//

#import "EGPreferencesController.h"

@interface EGPreferencesController ()
@end

@implementation EGPreferencesController

- (id)init
{
	if(self = [super initWithWindowNibName:@"EGPreferencesController"])
	{
	}
	
	return self;
}

- (BOOL)windowShouldClose:(id)sender
{
	NSInteger outputStyle = [outputStyleButton indexOfSelectedItem];
	NSInteger debugStyle = [debugStyleButton indexOfSelectedItem];
	
	[[NSUserDefaults standardUserDefaults] setInteger:outputStyle forKey:EG_PREF_OUTPUT_STYLE];
	[[NSUserDefaults standardUserDefaults] setInteger:debugStyle forKey:EG_PREF_DEBUG_STYLE];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	if (isModal)
	{
		[NSApp stopModal];
		isModal = NO;
	}
	
	return YES;
}

- (void)runModal
{
	isModal = YES;
	[NSApp runModalForWindow:self.window];
	[self.window orderOut:self];
}

- (void)windowDidLoad
{
	NSInteger outputStyle = [[NSUserDefaults standardUserDefaults] integerForKey:EG_PREF_OUTPUT_STYLE];
	NSInteger debugStyle = [[NSUserDefaults standardUserDefaults] integerForKey:EG_PREF_DEBUG_STYLE];
	
	[outputStyleButton selectItemAtIndex:outputStyle];
	[debugStyleButton selectItemAtIndex:debugStyle];
}

@end
