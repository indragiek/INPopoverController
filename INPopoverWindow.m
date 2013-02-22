//
//  INPopoverWindow.m
//  Copyright 2011 Indragie Karunaratne. All rights reserved.
//
//  Licensed under the BSD License <http://www.opensource.org/licenses/bsd-license>
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "INPopoverWindow.h"
#import "INPopoverControllerDefines.h"
#import "INPopoverWindowFrame.h"
#import "INPopoverController.h"
#import <QuartzCore/QuartzCore.h>

#define START_SIZE			NSMakeSize(20, 20)
#define OVERSHOOT_FACTOR	1.2

// A lot of this code was adapted from the following article:
// <http://cocoawithlove.com/2008/12/drawing-custom-window-on-mac-os-x.html>

@interface INPopoverWindow ()
- (NSWindow *)_zoomWindowWithRect:(NSRect)rect;
@end

@implementation INPopoverWindow

// Borderless, transparent window
- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)windowStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation
{
	if ((self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:bufferingType defer:deferCreation])) {
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
	return NSInsetRect(windowFrame, INPOPOVER_ARROW_HEIGHT, INPOPOVER_ARROW_HEIGHT);
}

- (NSRect)frameRectForContentRect:(NSRect)contentRect
{
	return NSInsetRect(contentRect, -INPOPOVER_ARROW_HEIGHT, -INPOPOVER_ARROW_HEIGHT);
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

- (INPopoverWindowFrame*)frameView
{
	return (INPopoverWindowFrame*)[self contentView];
}

- (void)setContentView:(NSView *)aView
{
    [self setPopoverContentView:aView];
}

- (void)setPopoverContentView:(NSView *)aView
{
	if ([_popoverContentView isEqualTo:aView]) { return; }
	NSRect bounds = [self frame];
	bounds.origin = NSZeroPoint;
	INPopoverWindowFrame *frameView = [self frameView];
	if (!frameView) {
#if __has_feature(objc_arc)
        frameView = [[INPopoverWindowFrame alloc] initWithFrame:bounds];
#else
		frameView = [[[INPopoverWindowFrame alloc] initWithFrame:bounds] autorelease];
#endif
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

- (void)presentWithPopoverController:(INPopoverController *)popoverController
{
	if ([self isVisible])
		return;
	
	NSRect endFrame = [self frame];
	NSRect startFrame = [popoverController popoverFrameWithSize:START_SIZE andArrowDirection:self.frameView.arrowDirection];
	NSRect overshootFrame = [popoverController popoverFrameWithSize:NSMakeSize(endFrame.size.width*OVERSHOOT_FACTOR, endFrame.size.height*OVERSHOOT_FACTOR) andArrowDirection:self.frameView.arrowDirection];
	
#if __has_feature(objc_arc)
    _zoomWindow = [self _zoomWindowWithRect:startFrame];
#else
	_zoomWindow = [[self _zoomWindowWithRect:startFrame] retain];
#endif
	
	[_zoomWindow setAlphaValue:0.0];
	[_zoomWindow orderFront:self];
	
	// configure bounce-out animation
	CAKeyframeAnimation *anim = [CAKeyframeAnimation animation];
	[anim setDelegate:self];
	[anim setValues:[NSArray arrayWithObjects:[NSValue valueWithRect:startFrame], [NSValue valueWithRect:overshootFrame], [NSValue valueWithRect:endFrame], nil]];
	[_zoomWindow setAnimations:[NSDictionary dictionaryWithObjectsAndKeys:anim, @"frame", nil]];
	
	[[_zoomWindow animator] setAlphaValue:1.0];
	[[_zoomWindow animator] setFrame:endFrame display:YES];
}

- (void)dismissAnimated
{
	[[_zoomWindow animator] setAlphaValue:0.0]; // in case zoom window is currently animating
	[[self animator] setAlphaValue:0.0];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
	[self makeKeyAndOrderFront:self];	
	[_zoomWindow close];
	
#if !__has_feature(objc_arc)
	[_zoomWindow release];
#endif
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
	
	if ([self windowNumber] <= 0)
	{
        // force creation of window device by putting it on-screen. We make it transparent to minimize the chance of visible flicker
		CGFloat alpha = [self alphaValue];
		[self setAlphaValue:0.0];
		[self orderBack:self];
		[self orderOut:self];
		[self setAlphaValue:alpha];
	}
	
	// get window content as image
	NSRect frame = [self frame];
#if __has_feature(objc_arc)
	NSImage *image = [[NSImage alloc] initWithSize:frame.size];
#else
	NSImage *image = [[[NSImage alloc] initWithSize:frame.size] autorelease];
#endif
	[self displayIfNeeded];	// refresh view
	[image lockFocus];
	NSCopyBits([self gState], NSMakeRect(0.0, 0.0, frame.size.width, frame.size.height), NSZeroPoint);
	[image unlockFocus];
	
	// create zoom window
	NSWindow *zoomWindow = [[NSWindow alloc] initWithContentRect:rect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	[zoomWindow setBackgroundColor:[NSColor clearColor]];
	[zoomWindow setHasShadow:[self hasShadow]];
	[zoomWindow setLevel:[self level]];
	[zoomWindow setOpaque:NO];
#if __has_feature(objc_arc)
	[zoomWindow setReleasedWhenClosed:NO];
#else
	[zoomWindow setReleasedWhenClosed:YES];
#endif
	[zoomWindow useOptimizedDrawing:YES];

#if __has_feature(objc_arc)
	NSImageView *imageView = [[NSImageView alloc] initWithFrame:[zoomWindow contentRectForFrameRect:frame]];
#else
	NSImageView *imageView = [[[NSImageView alloc] initWithFrame:[zoomWindow contentRectForFrameRect:frame]] autorelease];
#endif
	[imageView setImage:image];
	[imageView setImageFrameStyle:NSImageFrameNone];
	[imageView setImageScaling:NSScaleToFit];
	[imageView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
	
	[zoomWindow setContentView:imageView];
	
	// reset one shot flag
	[self setOneShot:isOneShot];
	
	return zoomWindow;
}

@end
