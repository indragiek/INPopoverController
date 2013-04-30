//
//  INPopoverController.m
//  Copyright 2011 Indragie Karunaratne. All rights reserved.
//
//  Licensed under the BSD License <http://www.opensource.org/licenses/bsd-license>
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "INPopoverController.h"
#import "INPopoverWindow.h"
#import "INPopoverWindowFrame.h"
#import "INPopoverParentWindow.h"

#include <QuartzCore/QuartzCore.h>

@interface INPopoverController ()
- (void)_setInitialPropertyValues;
- (void)_closePopoverAndResetVariables;
- (void)_callDelegateMethod:(SEL)selector;
- (void)_positionViewFrameChanged:(NSNotification*)notification;
- (void)_setPositionView:(NSView*)newPositionView;
- (void)_setArrowDirection:(INPopoverArrowDirection)direction;
- (INPopoverArrowDirection)_arrowDirectionWithPreferredArrowDirection:(INPopoverArrowDirection)direction;
@property (readonly) NSView *contentView;
@end

@implementation INPopoverController
@synthesize delegate = _delegate;
@synthesize closesWhenPopoverResignsKey = _closesWhenPopoverResignsKey;
@synthesize closesWhenApplicationBecomesInactive = _closesWhenApplicationBecomesInactive;
@synthesize animates = _animates;

#pragma mark -
#pragma mark Initialization

- (id)init
{
	if ((self = [super init])) {
		[self _setInitialPropertyValues];
	}
	return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self _setInitialPropertyValues];
}

#pragma mark -
#pragma mark Public Methods

- (id)initWithContentViewController:(NSViewController*)viewController
{
	if ((self = [super init])) {
		[self _setInitialPropertyValues];
		self.contentViewController = viewController;
	}
	return self;
}

- (void)presentPopoverFromRect:(NSRect)rect inView:(NSView*)positionView preferredArrowDirection:(INPopoverArrowDirection)direction anchorsToPositionView:(BOOL)anchors
{
	if (self.popoverIsVisible) { return; } // If it's already visible, do nothing
	NSWindow *mainWindow = [positionView window];
	[self _setPositionView:positionView];
	_viewRect = rect;
	_screenRect = [positionView convertRect:rect toView:nil]; // Convert the rect to window coordinates
	_screenRect.origin = [mainWindow convertBaseToScreen:_screenRect.origin]; // Convert window coordinates to screen coordinates
	INPopoverArrowDirection calculatedDirection = [self _arrowDirectionWithPreferredArrowDirection:direction]; // Calculate the best arrow direction
	[self _setArrowDirection:calculatedDirection]; // Change the arrow direction of the popover
	NSRect windowFrame = [self popoverFrameWithSize:self.contentSize andArrowDirection:calculatedDirection]; // Calculate the window frame based on the arrow direction
	[_popoverWindow setFrame:windowFrame display:YES]; // Se the frame of the window
	[[_popoverWindow animationForKey:@"alphaValue"] setDelegate:self];
	
	// Show the popover
	[self _callDelegateMethod:@selector(popoverWillShow:)]; // Call the delegate
	if (self.animates)
	{
		// Animate the popover in
		[_popoverWindow setAlphaValue:1.0];
		[_popoverWindow presentWithPopoverController:self];
	}
	else
	{
		[mainWindow addChildWindow:_popoverWindow ordered:NSWindowAbove]; // Add the popover as a child window of the main window
		[_popoverWindow makeKeyAndOrderFront:nil]; // Show the popover
		[self _callDelegateMethod:@selector(popoverDidShow:)]; // Call the delegate
	}
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	if (anchors) {  // If the anchors option is enabled, register for frame change notifications
		[nc addObserver:self selector:@selector(_positionViewFrameChanged:) name:NSViewFrameDidChangeNotification object:self.positionView];
	}
	// When -closesWhenPopoverResignsKey is set to YES, the popover will automatically close when the popover loses its key status
	if (self.closesWhenPopoverResignsKey) {
		[nc addObserver:self selector:@selector(closePopover:) name:NSWindowDidResignKeyNotification object:_popoverWindow];
		if (!self.closesWhenApplicationBecomesInactive)
			[nc addObserver:self selector:@selector(applicationDidBecomeActive:) name:NSApplicationDidBecomeActiveNotification object:nil];
	} else if (self.closesWhenApplicationBecomesInactive) {
		// this is only needed if closesWhenPopoverResignsKey is NO, otherwise we already get a "resign key" notification when resigning active
		[nc addObserver:self selector:@selector(closePopover:) name:NSApplicationDidResignActiveNotification object:nil];
	}
}

- (void)recalculateAndResetArrowDirection
{
	INPopoverArrowDirection direction = [self _arrowDirectionWithPreferredArrowDirection:self.arrowDirection];
	[self _setArrowDirection:direction];
}

- (IBAction)closePopover:(id)sender
{
	if (![_popoverWindow isVisible]) { return; }
	if ([sender isKindOfClass:[NSNotification class]] && [[(NSNotification*)sender name] isEqualToString:NSWindowDidResignKeyNotification]) {
		// ignore "resign key" notification sent when app becomes inactive unless closesWhenApplicationBecomesInactive is enabled
		if (!self.closesWhenApplicationBecomesInactive && ![NSApp isActive])
			return;
	}
	BOOL close = YES;
	// Check to see if the delegate has implemented the -popoverShouldClose: method
	if ([self.delegate respondsToSelector:@selector(popoverShouldClose:)]) {
		close = [self.delegate popoverShouldClose:self]; 
	}
	if (close) { [self forceClosePopover:nil]; }
}

- (IBAction)forceClosePopover:(id)sender
{
	if (![_popoverWindow isVisible]) { return; }
	[self _callDelegateMethod:@selector(popoverWillClose:)]; // Call delegate
	if (self.animates) {
		[_popoverWindow dismissAnimated];
	} else {
		[self _closePopoverAndResetVariables];
	}
}

// Calculate the frame of the window depending on the arrow direction
- (NSRect)popoverFrameWithSize:(NSSize)contentSize andArrowDirection:(INPopoverArrowDirection)direction
{
	NSRect contentRect = NSZeroRect;
	contentRect.size = contentSize;
	NSRect windowFrame = [_popoverWindow frameRectForContentRect:contentRect];
	if (direction == INPopoverArrowDirectionUp) { 
		CGFloat xOrigin = NSMidX(_screenRect) - floor(windowFrame.size.width / 2.0);
		CGFloat yOrigin = NSMinY(_screenRect) - windowFrame.size.height;
		windowFrame.origin = NSMakePoint(xOrigin, yOrigin);
	} else if (direction == INPopoverArrowDirectionDown) {
		CGFloat xOrigin = NSMidX(_screenRect) - floor(windowFrame.size.width / 2.0);
		windowFrame.origin = NSMakePoint(xOrigin, NSMaxY(_screenRect));
	} else if (direction == INPopoverArrowDirectionLeft) {
		CGFloat yOrigin = NSMidY(_screenRect) - floor(windowFrame.size.height / 2.0);
		windowFrame.origin = NSMakePoint(NSMaxX(_screenRect), yOrigin);
	} else if (direction == INPopoverArrowDirectionRight) {
		CGFloat xOrigin = NSMinX(_screenRect) - windowFrame.size.width;
		CGFloat yOrigin = NSMidY(_screenRect) - floor(windowFrame.size.height / 2.0);
		windowFrame.origin = NSMakePoint(xOrigin, yOrigin);
	} else {
		// If no arrow direction is specified, just return an empty rect
		windowFrame = NSZeroRect;
	}
	return windowFrame;
}

#pragma mark -
#pragma mark Memory Management

#if !__has_feature(objc_arc)
- (void)dealloc
{
	[_contentViewController release];
	[_popoverWindow release];
	[super dealloc];
}
#endif

- (void) animationDidStop:(CAAnimation *)animation finished:(BOOL)flag 
{
#pragma unused(animation)
#pragma unused(flag)
	// Detect the end of fade out and close the window
	if(0.0 == [_popoverWindow alphaValue])
		[self _closePopoverAndResetVariables];
	else if(1.0 == [_popoverWindow alphaValue]) {
		[[_positionView window] addChildWindow:_popoverWindow ordered:NSWindowAbove];
		[self _callDelegateMethod:@selector(popoverDidShow:)];
	}
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
	// when the user clicks in the parent window for activating the app, the parent window becomes key which prevents 
	if ([_popoverWindow isVisible])
		[self performSelector:@selector(checkPopoverKeyWindowStatus) withObject:nil afterDelay:0];
}

- (void)checkPopoverKeyWindowStatus
{
	id parentWindow = [_positionView window]; // could be INPopoverParentWindow
	BOOL isKey = [parentWindow respondsToSelector:@selector(isReallyKeyWindow)] ? [parentWindow isReallyKeyWindow] : [parentWindow isKeyWindow];
	if (isKey)
		[_popoverWindow makeKeyWindow];
}

#pragma mark -
#pragma mark Getters
@synthesize positionView=_positionView, contentSize=_contentSize, popoverWindow=_popoverWindow, contentViewController=_contentViewController;

- (NSColor*)color { return _popoverWindow.frameView.color; }

- (CGFloat)borderWidth { return _popoverWindow.frameView.borderWidth; }

- (NSColor*)borderColor { return _popoverWindow.frameView.borderColor; }

- (NSColor*)topHighlightColor { return _popoverWindow.frameView.topHighlightColor; }

- (INPopoverArrowDirection)arrowDirection { return _popoverWindow.frameView.arrowDirection; }

- (NSView*)contentView { return [_popoverWindow popoverContentView]; }

- (BOOL)popoverIsVisible { return [_popoverWindow isVisible]; }

#pragma mark -
#pragma mark Setters

- (void)setColor:(NSColor *)newColor { _popoverWindow.frameView.color = newColor; }

- (void)setBorderWidth:(CGFloat)newBorderWidth { _popoverWindow.frameView.borderWidth = newBorderWidth; }

- (void)setBorderColor:(NSColor *)newBorderColor { _popoverWindow.frameView.borderColor = newBorderColor; }

- (void)setTopHighlightColor:(NSColor *)newTopHighlightColor { _popoverWindow.frameView.topHighlightColor = newTopHighlightColor; }

- (void)setContentViewController:(NSViewController *)newContentViewController
{
	if (_contentViewController != newContentViewController) {
		[_popoverWindow setPopoverContentView:nil]; // Clear the content view
#if __has_feature(objc_arc)
        _contentViewController = newContentViewController;
#else
		[_contentViewController release];
		_contentViewController = [newContentViewController retain];
#endif
		NSView *contentView = [_contentViewController view];
		self.contentSize = [contentView frame].size;
		[_popoverWindow setPopoverContentView:contentView];
	}
}

- (void)setContentSize:(NSSize)newContentSize
{
	// We use -frameRectForContentRect: just to get the frame size because the origin it returns is not the one we want to use. Instead, -windowFrameWithSize:andArrowDirection: is used to  complete the frame
	_contentSize = newContentSize;
	NSRect adjustedRect = [self popoverFrameWithSize:newContentSize andArrowDirection:self.arrowDirection];
	[_popoverWindow setFrame:adjustedRect display:YES animate:self.animates];
}
	
#pragma mark -

- (void)_setPositionView:(NSView*)newPositionView
{
#if __has_feature(objc_arc)
    _positionView = newPositionView;
#else
	if (_positionView != newPositionView) {
		[_positionView release];
		_positionView = [newPositionView retain];
	}
#endif
}

- (void)_setArrowDirection:(INPopoverArrowDirection)direction {
	_popoverWindow.frameView.arrowDirection = direction; 
}

#pragma mark -
#pragma mark Private

// Set the default values for all the properties as described in the header documentation
- (void)_setInitialPropertyValues
{
	// Create an empty popover window
	_popoverWindow = [[INPopoverWindow alloc] initWithContentRect:NSZeroRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	
	// set defaults like iCal popover
	self.color = [NSColor colorWithCalibratedWhite:0.94 alpha:0.92];
	self.borderColor = [NSColor colorWithCalibratedWhite:1.0 alpha:0.92];
	self.borderWidth = 1.0;
	self.closesWhenPopoverResignsKey = YES;
	self.closesWhenApplicationBecomesInactive = NO;
	self.animates = YES;
	
	// create animation to get callback - delegate is set when opening popover to avoid memory cycles
	CAAnimation *animation = [CABasicAnimation animation];
	[_popoverWindow setAnimations:[NSDictionary dictionaryWithObject:animation forKey:@"alphaValue"]];
}

// Figure out which direction best stays in screen bounds
- (INPopoverArrowDirection)_arrowDirectionWithPreferredArrowDirection:(INPopoverArrowDirection)direction
{
	NSRect screenFrame = [[[_positionView window] screen] frame];
	// If the window with the preferred arrow direction already falls within the screen bounds then no need to go any further
	NSRect windowFrame = [self popoverFrameWithSize:self.contentSize andArrowDirection:direction];
	if (NSContainsRect(screenFrame, windowFrame)) {
		return direction;
	}
	// First thing to try is making the popover go opposite of its current direction
	INPopoverArrowDirection newDirection = INPopoverArrowDirectionUndefined;
	switch (direction) {
		case INPopoverArrowDirectionUp:
			newDirection = INPopoverArrowDirectionDown;
			break;
		case INPopoverArrowDirectionDown:
			newDirection = INPopoverArrowDirectionUp;
			break;
		case INPopoverArrowDirectionLeft:
			newDirection = INPopoverArrowDirectionRight;
			break;
		case INPopoverArrowDirectionRight:
			newDirection = INPopoverArrowDirectionLeft;
			break;
		default:
			break;
	}
	// If the popover now fits within bounds, then return the newly adjusted direction
	windowFrame = [self popoverFrameWithSize:self.contentSize andArrowDirection:newDirection];
	if (NSContainsRect(screenFrame, windowFrame)) {
		return newDirection;
	}
	// Calculate the remaining space on each side and figure out which would be the best to try next
	CGFloat left = NSMinX(_screenRect);
	CGFloat right = screenFrame.size.width - NSMaxX(_screenRect);
	CGFloat up = screenFrame.size.height - NSMaxY(_screenRect);
	CGFloat down = NSMinY(_screenRect);
	BOOL arrowLeft = (right > left);
	BOOL arrowUp = (down > up);
	// Now the next thing to try is the direction with the most space
	switch (direction) {
		case INPopoverArrowDirectionUp:
		case INPopoverArrowDirectionDown:
			newDirection = arrowLeft ? INPopoverArrowDirectionLeft : INPopoverArrowDirectionRight;
		case INPopoverArrowDirectionLeft:
		case INPopoverArrowDirectionRight:
			newDirection = arrowUp ? INPopoverArrowDirectionUp : INPopoverArrowDirectionDown;
			break;
		default:
			break;
	}
	// If the popover now fits within bounds, then return the newly adjusted direction
	windowFrame = [self popoverFrameWithSize:self.contentSize andArrowDirection:newDirection];
	if (NSContainsRect(screenFrame, windowFrame)) {
		return newDirection;
	}
	// If that didn't fit, then that means that it will be out of bounds on every side so just return the original direction
	return direction;
}

- (void)_positionViewFrameChanged:(NSNotification*)notification
{
	NSRect superviewBounds = [[self.positionView superview] bounds];
	if (!(NSContainsRect(superviewBounds, [self.positionView frame]))) {
		[self forceClosePopover:nil]; // If the position view goes off screen then close the popover
		return;
	}
	NSRect newFrame = [_popoverWindow frame];
	_screenRect = [self.positionView convertRect:_viewRect toView:nil]; // Convert the rect to window coordinates
	_screenRect.origin = [[self.positionView window] convertBaseToScreen:_screenRect.origin]; // Convert window coordinates to screen coordinates
	NSRect calculatedFrame = [self popoverFrameWithSize:self.contentSize andArrowDirection:self.arrowDirection]; // Calculate the window frame based on the arrow direction
	newFrame.origin = calculatedFrame.origin;
	[_popoverWindow setFrame:newFrame display:YES animate:NO]; // Set the frame of the window
}

- (void)_closePopoverAndResetVariables
{
	NSWindow *positionWindow = [self.positionView window];
	[_popoverWindow orderOut:nil]; // Close the window 
	[self _callDelegateMethod:@selector(popoverDidClose:)]; // Call the delegate to inform that the popover has closed
	[positionWindow removeChildWindow:_popoverWindow]; // Remove it as a child window
	[positionWindow makeKeyAndOrderFront:nil];
	// Clear all the ivars
	[self _setArrowDirection:INPopoverArrowDirectionUndefined];
	[self _setPositionView:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	_screenRect = NSZeroRect;
	_viewRect = NSZeroRect;
    
    // When using ARC and no animation, there is a "message sent to deallocated instance" crash if setDelegate: is not performed at the end of the event.
    [[_popoverWindow animationForKey:@"alphaValue"] performSelector:@selector(setDelegate:) withObject:nil afterDelay:0];
}

- (void)_callDelegateMethod:(SEL)selector
{
	if ([self.delegate respondsToSelector:selector]) {

#if __has_feature(objc_arc)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		[self.delegate performSelector:selector withObject:self];
#pragma clang diagnostic pop
#else
		[self.delegate performSelector:selector withObject:self];
#endif
	}
}

@end
