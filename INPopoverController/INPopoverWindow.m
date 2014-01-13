//
//  INPopoverWindow.m
//  Copyright 2011-2014 Indragie Karunaratne. All rights reserved.
//

#import "INPopoverWindow.h"
#import "INPopoverControllerDefines.h"
#import "INPopoverWindowFrame.h"
#import "INPopoverController.h"
#import <QuartzCore/QuartzCore.h>

#define START_SIZE            NSMakeSize(20, 20)
#define OVERSHOOT_FACTOR    1.2

// A lot of this code was adapted from the following article:
// <http://cocoawithlove.com/2008/12/drawing-custom-window-on-mac-os-x.html>

@implementation INPopoverWindow {
	NSView *_popoverContentView;
	NSWindow *_zoomWindow;
}

// Borderless, transparent window
- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)windowStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation
{
	if ((self = [super initWithContentRect:contentRect styleMask:NSNonactivatingPanelMask backing:bufferingType defer:deferCreation])) {
		[self setOpaque:NO];
		[self setBackgroundColor:[NSColor clearColor]];
		[self setHasShadow:YES];
	}
	return self;
}

// Leave some space around the content for drawing the arrow
- (NSRect)contentRectForFrameRect:(NSRect)windowFrame
{
	windowFrame.origin = NSZeroPoint;
	const CGFloat arrowHeight = self.frameView.arrowSize.height;
	return NSInsetRect(windowFrame, arrowHeight, arrowHeight);
}

- (NSRect)frameRectForContentRect:(NSRect)contentRect
{
	const CGFloat arrowHeight = self.frameView.arrowSize.height;
	return NSInsetRect(contentRect, -arrowHeight, -arrowHeight);
}

// Allow the popover to become the key window
- (BOOL)canBecomeKeyWindow
{
	return YES;
}

- (BOOL)canBecomeMainWindow
{
	return NO;
}

- (BOOL)isVisible
{
	return [super isVisible] || [_zoomWindow isVisible];
}

- (INPopoverWindowFrame *)frameView
{
	return (INPopoverWindowFrame *) [self contentView];
}

- (void)setContentView:(NSView *)aView
{
	[self setPopoverContentView:aView];
}

- (void)setPopoverContentView:(NSView *)aView
{
	if ([_popoverContentView isEqualTo:aView]) {return;}
	NSRect bounds = [self frame];
	bounds.origin = NSZeroPoint;
	INPopoverWindowFrame *frameView = [self frameView];
	if (!frameView) {
		frameView = [[INPopoverWindowFrame alloc] initWithFrame:bounds];
		[super setContentView:frameView]; // Call on super or there will be infinite loop
	}
	if (_popoverContentView) {
		[_popoverContentView removeFromSuperview];
	}
	_popoverContentView = aView;
	[_popoverContentView setFrame:[self contentRectForFrameRect:bounds]];
	[_popoverContentView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
	[frameView addSubview:_popoverContentView];
}

- (void)presentAnimated
{
	if ([self isVisible])
		return;
	
	switch (self.popoverController.animationType) {
		case INPopoverAnimationTypePop:
			[self presentWithPopAnimation];
			break;
		case INPopoverAnimationTypeFadeIn:
		case INPopoverAnimationTypeFadeInOut:
			[self presentWithFadeAnimation];
			break;
		default:
			break;
	}
}

- (void)presentWithPopAnimation
{
	NSRect endFrame = [self frame];
	NSRect startFrame = [self.popoverController popoverFrameWithSize:START_SIZE andArrowDirection:self.frameView.arrowDirection];
	NSRect overshootFrame = [self.popoverController popoverFrameWithSize:NSMakeSize(endFrame.size.width * OVERSHOOT_FACTOR, endFrame.size.height * OVERSHOOT_FACTOR) andArrowDirection:self.frameView.arrowDirection];
	
	_zoomWindow = [self _zoomWindowWithRect:startFrame];
	[_zoomWindow setAlphaValue:0.0];
	[_zoomWindow orderFront:self];
	
	// configure bounce-out animation
	CAKeyframeAnimation *anim = [CAKeyframeAnimation animation];
	[anim setDelegate:self];
	[anim setValues:[NSArray arrayWithObjects:[NSValue valueWithRect:startFrame], [NSValue valueWithRect:overshootFrame], [NSValue valueWithRect:endFrame], nil]];
	[_zoomWindow setAnimations:[NSDictionary dictionaryWithObjectsAndKeys:anim, @"frame", nil]];
	
	[NSAnimationContext beginGrouping];
	[[_zoomWindow animator] setAlphaValue:1.0];
	[[_zoomWindow animator] setFrame:endFrame display:YES];
	[NSAnimationContext endGrouping];
}

- (void)presentWithFadeAnimation
{
	[self setAlphaValue:0.0];
	[self makeKeyAndOrderFront:nil];
	[[self animator] setAlphaValue:1.0];
}

- (void)dismissAnimated
{
	[[_zoomWindow animator] setAlphaValue:0.0]; // in case zoom window is currently animating
	[[self animator] setAlphaValue:0.0];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
	[self setAlphaValue:1.0];
	[self makeKeyAndOrderFront:self];
	[_zoomWindow close];
	_zoomWindow = nil;

	// call the animation delegate of the "real" window
	CAAnimation *windowAnimation = [self animationForKey:@"alphaValue"];
	[[windowAnimation delegate] animationDidStop:anim finished:flag];
}

#pragma mark -
#pragma mark Private

// The following method is adapted from the following class:
// <https://github.com/MrNoodle/NoodleKit/blob/master/NSWindow-NoodleEffects.m>
//  Copyright 2007-2009 Noodlesoft, LLC. All rights reserved.
- (NSWindow *)_zoomWindowWithRect:(NSRect)rect
{
	BOOL isOneShot = [self isOneShot];
	if (isOneShot)
		[self setOneShot:NO];

	if ([self windowNumber] <= 0) {
		// force creation of window device by putting it on-screen. We make it transparent to minimize the chance of visible flicker
		CGFloat alpha = [self alphaValue];
		[self setAlphaValue:0.0];
		[self orderBack:self];
		[self orderOut:self];
		[self setAlphaValue:alpha];
	}

	// get window content as image
	NSRect frame = [self frame];
	NSImage *image = [[NSImage alloc] initWithSize:frame.size];
	[self displayIfNeeded];    // refresh view
	NSView *view = self.contentView;
	NSBitmapImageRep *imageRep = [view bitmapImageRepForCachingDisplayInRect:view.bounds];
	[view cacheDisplayInRect:view.bounds toBitmapImageRep:imageRep];
	[image addRepresentation:imageRep];

	// create zoom window
	NSWindow *zoomWindow = [[NSWindow alloc] initWithContentRect:rect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	[zoomWindow setBackgroundColor:[NSColor clearColor]];
	[zoomWindow setHasShadow:[self hasShadow]];
	[zoomWindow setLevel:[self level]];
	[zoomWindow setOpaque:NO];
	[zoomWindow setReleasedWhenClosed:NO];
	[zoomWindow useOptimizedDrawing:YES];

	NSImageView *imageView = [[NSImageView alloc] initWithFrame:[zoomWindow contentRectForFrameRect:frame]];
	[imageView setImage:image];
	[imageView setImageFrameStyle:NSImageFrameNone];
	[imageView setImageScaling:NSScaleToFit];
	[imageView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];

	[zoomWindow setContentView:imageView];

	// reset one shot flag
	[self setOneShot:isOneShot];

	return zoomWindow;
}

@end
