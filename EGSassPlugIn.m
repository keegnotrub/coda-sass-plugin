//
//	EGSassPlugIn.m
//	Copyright ©2014 Ryan Krug. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
//	files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
//	modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
//	Software is furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//	OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//	LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
//	IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "EGSassPlugIn.h"
#import "EGPreferencesController.h"
#import "CodaPlugInsController.h"

#include <glob.h>
#include "libsass/sass_interface.h"

@interface ERSassPlugIn ()
- (id)initWithController:(CodaPlugInsController*)inController resourcePath:(NSString*)path;
@end

@implementation ERSassPlugIn

// Coda 2.0 and lower
- (id)initWithPlugInController:(CodaPlugInsController*)aController bundle:(NSBundle*)aBundle
{
	return [self initWithController:aController resourcePath:[aBundle resourcePath]];
}

// Coda 2.0.1 and higher
- (id)initWithPlugInController:(CodaPlugInsController*)aController plugInBundle:(NSObject <CodaPlugInBundle> *)plugInBundle
{
	return [self initWithController:aController resourcePath:[plugInBundle resourcePath]];
}

- (id)initWithController:(CodaPlugInsController *)inController resourcePath:(NSString*)path
{
	if ((self = [super init]) != nil)
	{
		controller = inController;
		resourcePath = [path copy];
		
		[controller registerActionWithTitle:@"Sass Preferences…" target:self selector:@selector(openSassPreferences:)];
		
		// CodaDocumentDidSaveNotification was derived by observing notifications being sent in Coda.
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(codaDocumentSavedNotification:) name:@"CodaDocumentDidSaveNotification" object:nil];
	}
	return self;
}

- (NSString*)name
{
	return @"Sass";
}

- (IBAction)openSassPreferences:(id)sender
{
	EGPreferencesController *prefs = [[EGPreferencesController alloc] init];
	[prefs runModal];
	[prefs release];
}


- (void)codaDocumentSavedNotification:(NSNotification*)notification
{
	// The object for CodaDocumentDidSaveNotification is currently a subclass of NSDocument.
	NSDocument *document = [notification object];
	if (document == nil || ![document isKindOfClass:[NSDocument class]])
	{
		return;
	}
	
	NSURL *documentURL = [document fileURL];
	if ([documentURL isFileURL])
	{
		NSString *file = [[documentURL path] stringByExpandingTildeInPath];
		if ([self isFileScss:file])
		{
			for (NSString* scssFile in [self scssFilesForScssFile:file])
			{
				[self generateCssForScssFile:scssFile];
			}
		}
	}
}

- (BOOL)isFileScss:(NSString*)file
{
	return [[[file pathExtension] lowercaseString] isEqualToString:@"scss"];
}

- (BOOL)isScssFileScssPartial:(NSString*)scssFile
{
	return [[scssFile lastPathComponent] hasPrefix:@"_"];
}

- (NSArray*)scssFilesForScssDirectory:(NSString*)scssDirectory
{
	NSString *pattern = @"[!_]*.scss";
	NSString *fullPattern = [scssDirectory stringByAppendingPathComponent:pattern];
    
	glob_t gt;
	const char *cPattern = [fullPattern UTF8String];
	NSMutableArray *paths = [NSMutableArray array];
	if (glob(cPattern, GLOB_NOSORT, NULL, &gt) == 0)
	{
		for (int i = 0; i < gt.gl_matchc; i++)
		{
			[paths addObject:[NSString stringWithUTF8String:gt.gl_pathv[i]]];
		}
	}
	globfree(&gt);
	
	if ([paths count] == 0 && [[scssDirectory pathComponents] count] > 1)
	{
		return [self scssFilesForScssDirectory:[scssDirectory stringByDeletingLastPathComponent]];
	}
	
	return paths;
}

- (NSArray*)scssFilesForScssFile:(NSString*)scssFile
{
	if (![self isScssFileScssPartial:scssFile])
	{
		return [NSArray arrayWithObject:scssFile];
	}
	
	return [self scssFilesForScssDirectory:[scssFile stringByDeletingLastPathComponent]];
}

- (NSString*)cssDirectoryForScssDirectory:(NSString*)scssDirectory
{
	NSString *pattern = @"{css, styles, stylesheets, style}";
	NSString *fullPattern = [scssDirectory stringByAppendingPathComponent:pattern];
	
	glob_t gt;
	const char *cPattern = [fullPattern UTF8String];
	NSString *cssDirectory = nil;
	if (glob(cPattern, GLOB_BRACE|GLOB_NOSORT, NULL, &gt) == 0)
	{
		for (int i = 0; i < gt.gl_matchc; i++)
		{
			cssDirectory = [NSString stringWithUTF8String:gt.gl_pathv[i]];
			break;
		}
	}
	globfree(&gt);
	
	if (cssDirectory == nil && [[scssDirectory pathComponents] count] > 1)
	{
		return [self cssDirectoryForScssDirectory:[scssDirectory stringByDeletingLastPathComponent]];
	}
	
	return cssDirectory;
}

- (NSString*)cssFileForScssFile:(NSString*)scssFile
{
	NSString *dir = [scssFile stringByDeletingLastPathComponent];
	NSString *scssFileName = [scssFile lastPathComponent];
	
	NSString *cssFileName = [scssFileName stringByReplacingOccurrencesOfString:@"scss"
																	withString:@"css"
																	   options:NSCaseInsensitiveSearch
																		 range:NSMakeRange(0, [scssFileName length])];
	
	NSString *cssFile = [dir stringByAppendingPathComponent:cssFileName];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:cssFile])
	{
		NSString *cssDirectory = [self cssDirectoryForScssDirectory:dir];
		
		if (cssDirectory != nil)
		{
			cssFile = [cssDirectory stringByAppendingPathComponent:cssFileName];
		}
	}
	
	return cssFile;
}


- (void)generateCssForScssFile:(NSString*)scssFile
{
	if (scssFile == nil)
	{
		return;
	}
	
	NSString *cssFile = [self cssFileForScssFile:scssFile];
	if (cssFile == nil)
	{
		return;
	}
	
	NSString *mapFile = [[cssFile stringByDeletingPathExtension] stringByAppendingPathExtension:@"map"];

	struct sass_options options;
	
	NSInteger outputStyle = [[NSUserDefaults standardUserDefaults] integerForKey:EG_PREF_OUTPUT_STYLE];
	options.output_style = outputStyle;

	NSInteger debugStyle = [[NSUserDefaults standardUserDefaults] integerForKey:EG_PREF_DEBUG_STYLE];
	options.source_comments = debugStyle;
	
	options.image_path = "images";
	options.include_paths = [[resourcePath stringByAppendingPathComponent:@"scss"] UTF8String];
	
	struct sass_file_context *ctx = sass_new_file_context();
	
	ctx->options = options;
	ctx->input_path = [scssFile UTF8String];
	
	if (options.source_comments == SASS_SOURCE_COMMENTS_MAP)
	{
		ctx->source_map_file = (char*)[mapFile UTF8String];
	}
	
	sass_compile_file(ctx);
	
	if (ctx->error_status)
	{
		NSString *error = [NSString stringWithUTF8String:ctx->error_message];
		NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Sass could not be completed.",@"Sass could not be completed.")
										 defaultButton:NSLocalizedString(@"OK",@"OK")
									   alternateButton:nil
										   otherButton:nil
							 informativeTextWithFormat:@"%@", error];
		[alert runModal];
	}
	
	if (!ctx->error_status && ctx->output_string)
	{
		NSString *cssResult = [NSString stringWithUTF8String:ctx->output_string];
		[cssResult writeToFile:cssFile atomically:YES encoding:NSUTF8StringEncoding error:NULL];
		
		if (ctx->source_map_string)
		{
			NSString *mapResult = [NSString stringWithUTF8String:ctx->source_map_string];
			[mapResult writeToFile:mapFile atomically:YES encoding:NSUTF8StringEncoding error:NULL];
		}
	}
	
	sass_free_file_context(ctx);
}

@end
