//
//  EGPreferencesController.h
//  Sass
//
//  Created by Ryan Krug on 2/16/14.
//
//

#import <Cocoa/Cocoa.h>

extern NSString *const EG_PREF_OUTPUT_STYLE;
extern NSString *const EG_PREF_DEBUG_STYLE;

extern NSInteger const EG_SASS_SOURCE_COMMENTS_NONE;
extern NSInteger const EG_SASS_SOURCE_COMMENTS_DEBUG;
extern NSInteger const EG_SASS_SOURCE_COMMENTS_MAP;

@interface EGPreferencesController : NSWindowController<NSWindowDelegate>

@property (nonatomic, weak) IBOutlet NSPopUpButton *outputStyleButton;
@property (nonatomic, weak) IBOutlet NSPopUpButton *debugStyleButton;

- (IBAction)outputStyleChanged:(id)sender;
- (IBAction)debugStyleChanged:(id)sender;

@end
