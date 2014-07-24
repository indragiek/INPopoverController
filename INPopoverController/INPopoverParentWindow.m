//
//  INAlwaysKeyWindow.m
//  Copyright 2011-2014 Indragie Karunaratne. All rights reserved.
//

#import "INPopoverParentWindow.h"
#import "INPopoverWindow.h"

@implementation INPopoverParentWindow

- (BOOL)isKeyWindow
{
	BOOL isKey = [super isKeyWindow];
	if (!isKey) {
		for (NSWindow *childWindow in [self childWindows]) {
			if ([childWindow isKindOfClass:[INPopoverWindow class]]) {
				// if we have popover attached, window is key if app is active
				isKey = [NSApp isActive];
				break;
			}
		}
	}
	return isKey;
}

- (BOOL)isReallyKeyWindow
{
	return [super isKeyWindow];
}

@end
