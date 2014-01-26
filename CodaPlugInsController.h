#import <Cocoa/Cocoa.h>

////////////////////////////////////////////////////////////////////////////////
// This object is passed during initialization. You must register your        //
// available functionality with one of the methods implemented by the         //
// plug-in controller                                                         //
////////////////////////////////////////////////////////////////////////////////

@class CodaTextView;

@interface CodaPlugInsController : NSObject

////////////////////////////////////////////////////////////////////////////////
// The following methods are available to plugin developers	in Coda 1.6 and   //
// later:																	  //
////////////////////////////////////////////////////////////////////////////////


// Returns the version of Coda that is hosting the plugin, such as "1.6.3"

- (NSString*)codaVersion:(id)sender;


// Returns to the plugin an abstract object representing the text view in Coda 
// that currently has focus

- (CodaTextView*)focusedTextView:(id)sender;


// Exposes to the user a plug-in action (a menu item) with the given title, that 
// will perform the given selector on the target

- (void)registerActionWithTitle:(NSString*)title target:(id)target selector:(SEL)selector;


// Returns 6 as of Coda 2.0.1

- (NSUInteger)apiVersion;


// Displays the provided HTML in a new tab. 

- (void)displayHTMLString:(NSString*)html;


// Creates a new unsaved document in the frontmost Coda window and returns the Text View associated with it.
// The text view provided is auto-released, so the caller does not need to explicitly release it.

- (CodaTextView*)makeUntitledDocument;


// Similar to registerActionWithTitle:target:selector: but allows further customization of the registered
// menu items, including submenu title, represented object, keyEquivalent and custom plug-in name.

- (void)registerActionWithTitle:(NSString*)title
		  underSubmenuWithTitle:(NSString*)submenuTitle
						 target:(id)target
					   selector:(SEL)selector
			  representedObject:(id)repOb
				  keyEquivalent:(NSString*)keyEquivalent
					 pluginName:(NSString*)aName;


// Causes the frontmost Coda window to save all documents that have unsaved changes.

- (void)saveAll;


////////////////////////////////////////////////////////////////////////////////
// The following methods are available to plugin developers	in Coda 2.0 and   //
// later:																	  //
////////////////////////////////////////////////////////////////////////////////

// Displays the provided HTML in a new tab with a specific baseURL

- (void)displayHTMLString:(NSString*)html baseURL:(NSURL*)baseURL;


// Opens text file at path, returning CodaTextView if successful

- (CodaTextView*)openFileAtPath:(NSString*)path error:(NSError**)error;



@end


// 
// This is your hook to a text view in Coda. You can use this to provide 
// manipulation of files.
//

@class CodaPlainTextEditor;

@interface CodaTextView : NSObject
{
	CodaPlainTextEditor* editor;
}

////////////////////////////////////////////////////////////////////////////////
// The following methods are available to plugin developers in Coda 1.6 and	  //
// later.																	  //
////////////////////////////////////////////////////////////////////////////////

// Inserts the given string at the insertion point

- (void)insertText:(NSString*)inText;


// Replaces characters in the given range with the given string

- (void)replaceCharactersInRange:(NSRange)aRange withString:(NSString *)aString;


// Returns the range of currently selected characters

- (NSRange)selectedRange;


// Returns the currently selected text, or nil if none

- (NSString*)selectedText;


// Selects the given character range

- (void)setSelectedRange:(NSRange)range;

// Returns a string containing the entire content of the line that the insertion 
// point is on

- (NSString*)currentLine;


// Returns the line number corresponding to the location of the insertion point

- (NSUInteger)currentLineNumber;


// Deletes the selected text range

- (void)deleteSelection;


// Returns the current line ending of the file

- (NSString*)lineEnding;


// Returns the character range of the entire line the insertion point
// is on

- (NSRange)rangeOfCurrentLine;


// StartOfLine returns the character index (relative to the beginning of the 
// document) of the start of the line the insertion point is on

- (NSUInteger)startOfLine;


// String returns the entire document as a plain string

- (NSString*)string;


// Returns the specified ranged substring of the entire document

- (NSString*)stringWithRange:(NSRange)range;


// Returns the width of tabs as spaces

- (NSInteger)tabWidth;


// Returns the range of the word previous to the insertion point

- (NSRange)previousWordRange;


// UsesTabs returns if the editor is currently uses tabs instead of spaces for 
// indentation

- (BOOL)usesTabs;

// saves the document you are working on

- (void)save;

// Saves the document you are working on to a local path, returns YES if 
// successful

- (BOOL)saveToPath:(NSString*)aPath;

// Allows for multiple text manipulations to be considered one "undo/redo"
// operation

- (void)beginUndoGrouping;
- (void)endUndoGrouping;


// Returns the window the editor is located in (useful for showing sheets)

- (NSWindow*)window;


// Returns the path to the text view's file (may be nil for unsaved documents)

- (NSString*)path;


// Returns the root local path of the site if specified (nil if unspecified in 
// the site or site is not loaded)

- (NSString*)siteLocalPath;


////////////////////////////////////////////////////////////////////////////////
// The following methods are available to plugin developers in Coda 1.6.1 and //
// later.																	  //
////////////////////////////////////////////////////////////////////////////////

// Returns the range of the word containing the insertion point

- (NSRange)currentWordRange;


////////////////////////////////////////////////////////////////////////////////
// The following methods are available to plugin developers in Coda 1.6.3 and //
// later.																	  //
////////////////////////////////////////////////////////////////////////////////

// Returns the URL of the site if specified (nil if unspecified in 
// the site or site is not loaded) 

- (NSString*)siteURL;


// Returns the local URL of the site if specified (nil if unspecified in 
// the site or site is not loaded)

- (NSString*)siteLocalURL;


// Returns the root remote path of the site if specified (nil if unspecified in 
// the site or site is not loaded)

- (NSString*)siteRemotePath;


// Returns the nickname of the site if specified (nil if site is not loaded)

- (NSString*)siteNickname;


////////////////////////////////////////////////////////////////////////////////
// The following methods are available to plugin developers in Coda 2.0 and //
// later.																	  //
////////////////////////////////////////////////////////////////////////////////

// Moves insertion point to specified line and column, scrolling to visible if needed

- (void)goToLine:(NSInteger)line column:(NSInteger)column;


// Remote URL for file given the site configuration

- (NSString*)remoteURL;


// Text encoding of the file

- (NSStringEncoding)encoding;

@end

////////////////////////////////////////////////////////////////////////////////
// The following protocol is available to plugin developers	in Coda 2.0.1     //
// and later:																  //
////////////////////////////////////////////////////////////////////////////////

@protocol CodaPlugInBundle

@required

// @abstract The unique identifier for the bundle
@property (copy, readonly) NSString *bundleIdentifier;

// @abstract The URL of the bundle on disk
@property (copy, readonly) NSURL *bundleURL;

// @abstract The path of the bundle on disk
@property (copy, readonly) NSString *bundlePath;


// @abstract The principal class of the bundle
@property (readonly) Class principalClass;


// The (unlocalized) info dictionary
@property (copy, readonly) NSDictionary *infoDictionary;

// The localized info dictionary
@property (copy, readonly) NSDictionary *localizedInfoDictionary;

// Gets the (localized, when possible) value of an info dictionary key
- (id)objectForInfoDictionaryKey:(NSString *)key;


// The URL of the bundle's executable file
@property (copy, readonly) NSURL *executableURL;

// The path of the bundle's executable file
@property (copy, readonly) NSString *executablePath;

// An array of numbers indicating the architecture types supported by the bundle’s executable
@property (copy, readonly) NSArray *executableArchitectures;

// Gets the URL for an auxiliary executable in the bundle
- (NSURL *)URLForAuxiliaryExecutable:(NSString *)executableName;

// Gets the path for an auxiliary executable in the bundle
- (NSString *)pathForAuxiliaryExecutable:(NSString *)executableName;


// @abstract The URL of the bundle's resource directory
@property (copy, readonly) NSURL *resourceURL;

// The path of the bundle's resource directory
@property (copy, readonly) NSString *resourcePath;

// Gets the URL for a bundle resource
- (NSURL *)URLForResource:(NSString *)name withExtension:(NSString *)extension;

// Gets the URL for a bundle resource located within a bundle subdirectory
- (NSURL *)URLForResource:(NSString *)name withExtension:(NSString *)extension subdirectory:(NSString *)subpath;

// Gets the URL for a bundle resource located within a bundle subdirectory and localization
- (NSURL *)URLForResource:(NSString *)name withExtension:(NSString *)extension subdirectory:(NSString *)subpath localization:(NSString *)localizationName;

// Gets the URL for a bundle resource
- (NSString *)pathForResource:(NSString *)name ofType:(NSString *)extension;

// Gets the URL for a bundle resource located within a bundle subdirectory
- (NSString *)pathForResource:(NSString *)name ofType:(NSString *)extension inDirectory:(NSString *)subpath;

// Gets the URL for a bundle resource located within a bundle subdirectory and localization
- (NSString *)pathForResource:(NSString *)name ofType:(NSString *)extension inDirectory:(NSString *)subpath forLocalization:(NSString *)localizationName;


// @abstract A list of all the localizations contained within the receiver's bundle
@property (copy, readonly) NSArray *localizations;

// A list of the preferred localizations contained within the receiver's bundle
@property (copy, readonly) NSArray *preferredLocalizations;

// The localization used to create the bundle
@property (copy, readonly) NSArray *developmentLocalization;

// Gets the localized string for a given key, value and table
- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName;

@end


////////////////////////////////////////////////////////////////////////////////
// Your plug-in's principal class must conform to this protocol               //
////////////////////////////////////////////////////////////////////////////////

@protocol CodaPlugIn <NSObject>

// Return a name to display in the plug-ins menu

- (NSString*)name;


@optional 

// Default init'r for your plug-in's principal class. Passes a reference to your
// bundle and the singleton instance of the CodaPlugInsController, may be called from a secondary thread
//
// Available in Coda API v6 (2.0.1) and later, this is the preferred init method
// NOTE: CodaPlugInSupportedAPIVersion and/or CodaPlugInMinimumAPIVersion info.plist key must be set to 6 or higher

- (id)initWithPlugInController:(CodaPlugInsController*)aController plugInBundle:(NSObject <CodaPlugInBundle> *)plugInBundle;


// Default init'r for your plug-in's principal class. Passes a reference to your
// bundle and the singleton instance of the CodaPlugInsController, may be called from a secondary thread
//
// NOTE: Deprecated in Coda API v6 (2.0.1) and later in favor of initWithPlugInController:pluginBundle:

- (id)initWithPlugInController:(CodaPlugInsController*)aController bundle:(NSBundle*)yourBundle DEPRECATED_ATTRIBUTE;


// Called before the text view will be saved to disk

- (void)textViewWillSave:(CodaTextView*)textView;


// Called when a text view is focused/opened
// NOTE: this method is time sensitive and should return quickly

- (void)textViewDidFocus:(CodaTextView*)textView;


// Gives the plugin a chance to modify files just before publishing, output is the path to the file to publish.
// WARNING: this method will be called on a non-main thread

- (NSString*)willPublishFileAtPath:(NSString*)inputPath;

@end


