//
//  EGPreferencesController.m
//  Sass
//
//  Created by Ryan Krug on 2/16/14.
//
//

#import "EGPreferencesController.h"

NSString *const EG_PREF_OUTPUT_STYLE = @"EGSassPlugin_OutputStyle";
NSString *const EG_PREF_DEBUG_STYLE = @"EGSassPlugin_DebugStyle";

NSInteger const EG_SASS_SOURCE_COMMENTS_NONE = 0;
NSInteger const EG_SASS_SOURCE_COMMENTS_DEBUG = 1;
NSInteger const EG_SASS_SOURCE_COMMENTS_MAP = 2;

@interface EGPreferencesController ()

@end

@implementation EGPreferencesController

- (instancetype)init
{
    self = [super initWithWindowNibName:@"EGPreferencesController"];
    
    if (!self) {
        return nil;
    }
	
	return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
	NSInteger outputStyle = [[NSUserDefaults standardUserDefaults] integerForKey:EG_PREF_OUTPUT_STYLE];
	NSInteger debugStyle = [[NSUserDefaults standardUserDefaults] integerForKey:EG_PREF_DEBUG_STYLE];
	
	[self.outputStyleButton selectItemAtIndex:outputStyle];
	[self.debugStyleButton selectItemAtIndex:debugStyle];
}

#pragma mark - IBAction

- (IBAction)outputStyleChanged:(id)sender
{
    NSInteger outputStyle = [self.outputStyleButton indexOfSelectedItem];

    [[NSUserDefaults standardUserDefaults] setInteger:outputStyle forKey:EG_PREF_OUTPUT_STYLE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)debugStyleChanged:(id)sender
{
    NSInteger debugStyle = [self.debugStyleButton indexOfSelectedItem];
    
    [[NSUserDefaults standardUserDefaults] setInteger:debugStyle forKey:EG_PREF_DEBUG_STYLE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
