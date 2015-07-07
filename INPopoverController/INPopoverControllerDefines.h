//
//  INPopoverControllerDefines.h
//  Copyright 2011-2014 Indragie Karunaratne. All rights reserved.
//

typedef NS_ENUM(NSUInteger, INPopoverArrowDirection) {
	INPopoverArrowDirectionUndefined = 0,
	INPopoverArrowDirectionLeft,
	INPopoverArrowDirectionRight,
	INPopoverArrowDirectionUp,
	INPopoverArrowDirectionDown
};

typedef NS_ENUM(NSInteger, INPopoverAnimationType) {
	INPopoverAnimationTypePop = 0,	// Pop animation similar to NSPopover
	INPopoverAnimationTypeFadeIn,	// Fade in only, no fade out
	INPopoverAnimationTypeFadeOut,	// Fade out only, no fade in
	INPopoverAnimationTypeFadeInOut // Fade in and out
};