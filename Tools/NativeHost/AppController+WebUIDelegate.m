//
//  AppController+WebUIDelegate.m
//  NativeHost
//
//  Created by Francisco Tolmasky on 7/28/09.
//  Copyright 2009 280 North, Inc.. All rights reserved.
//

#import "AppController.h"
#import "WebWindow.h"


@implementation AppController (WebUIDelegate)

- (void)webView:(WebView *)aWebView setFrame:(NSRect)aFrame
{
    [[aWebView window] setFrame:aFrame display:YES];
}

- (NSRect)webViewFrame:(WebView *)aWebView
{
    return [[aWebView window] frame];
}

- (WebView *)webView:(WebView *)aWebView createWebViewWithRequest:(NSURLRequest *)aRequest
{
    return [[WebWindow webWindow] webView];
}

- (void)webViewClose:(WebView *)aWebView
{
    // Important to call close and not:
    // -performClose:, which beeps without the presence of a close button.
    // -orderOut:, which doesn't release the window.
    [[aWebView window] close];
    //[[aWebView window] orderOut:self];
}

- (void)webViewShow:(WebView *)aWebView
{
    [[aWebView window] makeKeyAndOrderFront:self];
}

- (NSAttributedString *)loggedOutput;
{
    return loggedOutput;
}

- (void)webView:(WebView *)aWebView addMessageToConsole:(NSDictionary *)aDictionary
{
    NSString * message = [aDictionary objectForKey:@"message"];
    NSAttributedString * attributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", message, nil]];
    
    [loggedOutput appendAttributedString:attributedString];

    [attributedString release];
    NHLog(@"CONSOLE", message);
}

- (void)webView:(WebView *)aSender runJavaScriptAlertPanelWithMessage:(NSString *)aMessage initiatedByFrame:(WebFrame *)aFrame
{
    WebDataSource * dataSource = [aFrame dataSource];
    NSString * title = [dataSource pageTitle];
    
    if (![title length])
        title = [[[dataSource request] URL] absoluteString];
    
    [[NSAlert alertWithMessageText:title defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", aMessage, nil] runModal];
}

// Added by David
- (BOOL)webView:(WebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame {
	NSInteger result = NSRunInformationalAlertPanel(NSLocalizedString(@"JavaScript", @""),  // title
		message,                // message
		NSLocalizedString(@"OK", @""),      // default button
		NSLocalizedString(@"Cancel", @""),    // alt button
		nil);
	return NSAlertDefaultReturn == result;  
}

// Added by David
- (void)webView:(WebView *)sender runOpenPanelForFileButtonWithResultListener:(id < WebOpenPanelResultListener >)resultListener {
	NSOpenPanel *openDialog = [NSOpenPanel openPanel];
	[openDialog setCanChooseFiles:YES];
	[openDialog setAllowsMultipleSelection:NO];
	[openDialog setCanChooseDirectories:NO];
	if ([openDialog runModalForDirectory:nil file:nil] == NSOKButton) {
		[resultListener chooseFilename:[[openDialog filenames] objectAtIndex:0]];
	}
}

// Added by David
- (void)webView:(WebView *)sender runOpenPanelForFileButtonWithResultListener:(id < WebOpenPanelResultListener >)resultListener allowMultipleFiles:(BOOL)allowMultipleFiles {
	NSOpenPanel *openDialog = [NSOpenPanel openPanel];
	[openDialog setCanChooseFiles:YES];
	[openDialog setAllowsMultipleSelection:NO];
	[openDialog setCanChooseDirectories:NO];
	if ([openDialog runModalForDirectory:nil file:nil] == NSOKButton) {
		if (allowMultipleFiles && [resultListener respondsToSelector:@selector(chooseFilenames:)]) {
			[resultListener performSelector:@selector(chooseFilenames:) withObject:[openDialog filenames]];
		} else {
			[resultListener chooseFilename:[[openDialog filenames] objectAtIndex:0]];
		}
	}
}

@end
