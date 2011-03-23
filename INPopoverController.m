//
//  INPopoverController.m
//  Copyright 2011 Indragie Karunaratne. All rights reserved.
//
//  Licensed under the BSD License <http://www.opensource.org/licenses/bsd-license>
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "INPopoverController.h"
#import "INPopoverWindow.h"
#import "INPopoverWindowFrame.h"

#include <QuartzCore/QuartzCore.h>

@interface INPopoverController ()
- (void)_setInitialPropertyValues;
- (void)_closePopoverAndResetVariables;
- (void)_callDelegateMethod:(SEL)selector;
- (void)_positionViewFrameChanged:(NSNotification*)notification;
- (void)_setPositionView:(NSView*)newPositionView;
- (void)_setArrowDirection:(INPopoverArrowDirection)direction;
- (NSRect)_windowFrameWithArrowDirection:(INPopoverArrowDirection)direction;
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

- (void)showPopoverAtPoint:(NSPoint)point inView:(NSView*)positionView preferredArrowDirection:(INPopoverArrowDirection)direction anchorsToPositionView:(BOOL)anchors
{
    if (self.popoverIsVisible) { return; } // If it's already visible, do nothing
    NSWindow *mainWindow = [positionView window];
    [self _setPositionView:positionView];
    _viewPoint = point;
    NSPoint windowPoint = [positionView convertPoint:point toView:nil]; // Convert the point to window coordinates
    _screenPoint = [mainWindow convertBaseToScreen:windowPoint]; // Convert window coordinates to screen coordinates
    INPopoverArrowDirection calculatedDirection = [self _arrowDirectionWithPreferredArrowDirection:direction]; // Calculate the best arrow direction
    [self _setArrowDirection:calculatedDirection]; // Change the arrow direction of the popover
    NSRect windowFrame = [self _windowFrameWithArrowDirection:calculatedDirection]; // Calculate the window frame based on the arrow direction
    [_popoverWindow setFrame:windowFrame display:YES]; // Se the frame of the window
                    
    // Show the popover
    [self _callDelegateMethod:@selector(popoverWillShow:)]; // Call the delegate
    if (self.animates) { [_popoverWindow setAlphaValue:0.0]; } // Set the alpha of the window to 0.0 initially
    [mainWindow addChildWindow:_popoverWindow ordered:NSWindowAbove]; // Add the popover as a child window of the main window
    [_popoverWindow makeKeyAndOrderFront:nil]; // Show the popover (if animation is enabled it won't be visible on screen YET)
    if (self.animates) { [[_popoverWindow animator] setAlphaValue:1.0]; } // Animate the popover in
    else { [self _callDelegateMethod:@selector(popoverDidShow:)]; } // Call the delegate
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    if (anchors) {  // If the anchors option is enabled, register for frame change notifications
        [nc addObserver:self selector:@selector(_positionViewFrameChanged:) name:NSViewFrameDidChangeNotification object:self.positionView];
    }
    // When -closesWhenPopoverResignsKey is set to YES, the popover will automatically close when the popover loses its key status
    if (self.closesWhenPopoverResignsKey) {
        [nc addObserver:self selector:@selector(closePopover:) name:NSWindowDidResignKeyNotification object:_popoverWindow];
    }
    if (self.closesWhenApplicationBecomesInactive) {
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
        [[_popoverWindow animator] setAlphaValue:0.0];
    } else {
        [self _closePopoverAndResetVariables];
    }
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc
{
    [_contentViewController release];
    [_popoverWindow release];
    [super dealloc];
}

- (void) animationDidStop:(CAAnimation *)animation finished:(BOOL)flag 
{
#pragma unused(animation)
#pragma unused(flag)
	// Detect the end of fade out and close the window
	if(0.0 == [_popoverWindow alphaValue])
		[self _closePopoverAndResetVariables];
	else if(1.0 == [_popoverWindow alphaValue])
		[self _callDelegateMethod:@selector(popoverDidShow:)];
}

#pragma mark -
#pragma mark Getters

- (NSView*)positionView { return _positionView; }
    
- (NSColor*)color { return _popoverWindow.frameView.color; }
    
- (CGFloat)borderWidth { return _popoverWindow.frameView.borderWidth; }
    
- (NSColor*)borderColor { return _popoverWindow.frameView.borderColor; }
    
- (INPopoverArrowDirection)arrowDirection { return _popoverWindow.frameView.arrowDirection; }

- (NSView*)contentView { return [self.popoverWindow contentView]; }

- (NSSize)contentSize { return _contentSize; }

- (NSWindow*)popoverWindow { return _popoverWindow; }

- (NSViewController*)contentViewController { return _contentViewController; }

- (BOOL)popoverIsVisible { return [_popoverWindow isVisible]; }

#pragma mark -
#pragma mark Setters

- (void)setColor:(NSColor *)newColor { _popoverWindow.frameView.color = newColor; }

- (void)setBorderWidth:(CGFloat)newBorderWidth { _popoverWindow.frameView.borderWidth = newBorderWidth; }

- (void)setBorderColor:(NSColor *)newBorderColor { _popoverWindow.frameView.borderColor = newBorderColor; }

- (void)setContentViewController:(NSViewController *)newContentViewController
{
    if (_contentViewController != newContentViewController) {
        [_popoverWindow setContentView:nil]; // Clear the content view
        [_contentViewController release];
        _contentViewController = [newContentViewController retain];
        NSView *contentView = [_contentViewController view];
        NSSize viewSize = [contentView frame].size;
        [_popoverWindow setContentView:contentView];
        self.contentSize = viewSize;
    }
}

- (void)setContentSize:(NSSize)newContentSize
{
    // We use -frameRectForContentRect: just to get the frame size because the origin it returns is not the one we want to use. Instead, -_windowFrameWithArrowDirection is used to  complete the frame
    _contentSize = newContentSize;
    NSRect adjustedRect = [self _windowFrameWithArrowDirection:self.arrowDirection];
    [_popoverWindow setFrame:adjustedRect display:YES animate:self.animates];
}
    
#pragma mark -

- (void)_setPositionView:(NSView*)newPositionView
{
    if (_positionView != newPositionView) {
        [_positionView release];
        _positionView = [newPositionView retain];
    }
}

- (void)_setArrowDirection:(INPopoverArrowDirection)direction { 
    _popoverWindow.frameView.arrowDirection = direction; 
}

#pragma mark -
#pragma mark Private

// Set the default values for all the properties as described in the header documentation
- (void)_setInitialPropertyValues
{
    self.color = [[NSColor blackColor] colorWithAlphaComponent:0.8];
    self.borderColor = [NSColor blackColor];
    self.closesWhenPopoverResignsKey = YES;
    self.animates = YES;
    
    // Create an empty popover window
    _popoverWindow = [[INPopoverWindow alloc] initWithContentRect:NSZeroRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];

	CAAnimation *animation = [CABasicAnimation animation];
	[animation setDelegate:self];
	[_popoverWindow setAnimations:[NSDictionary dictionaryWithObject:animation forKey:@"alphaValue"]];
}

// Calculate the frame of the window depending on the arrow direction
- (NSRect)_windowFrameWithArrowDirection:(INPopoverArrowDirection)direction
{
    NSRect contentRect = NSZeroRect;
    contentRect.size = self.contentSize;
    NSRect windowFrame = [_popoverWindow frameRectForContentRect:contentRect];
    if (direction == INPopoverArrowDirectionUp) { 
        CGFloat xOrigin = _screenPoint.x - floor(windowFrame.size.width / 2.0);
        CGFloat yOrigin = _screenPoint.y - windowFrame.size.height;
        windowFrame.origin = NSMakePoint(xOrigin, yOrigin);
    } else if (direction == INPopoverArrowDirectionDown) {
        CGFloat xOrigin = _screenPoint.x - floor(windowFrame.size.width / 2.0);
        windowFrame.origin = NSMakePoint(xOrigin, _screenPoint.y);
    } else if (direction == INPopoverArrowDirectionLeft) {
        CGFloat yOrigin = _screenPoint.y - floor(windowFrame.size.height / 2.0);
        windowFrame.origin = NSMakePoint(_screenPoint.x, yOrigin);
    } else if (direction == INPopoverArrowDirectionRight) {
        CGFloat xOrigin = _screenPoint.x - windowFrame.size.width;
        CGFloat yOrigin = _screenPoint.y - floor(windowFrame.size.height / 2.0);
        windowFrame.origin = NSMakePoint(xOrigin, yOrigin);
    } else {
        // If no arrow direction is specified, just return an empty rect
        windowFrame = NSZeroRect;
    }
    return windowFrame;

}

// Figure out which direction best stays in screen bounds
- (INPopoverArrowDirection)_arrowDirectionWithPreferredArrowDirection:(INPopoverArrowDirection)direction
{
    NSRect screenFrame = [[NSScreen mainScreen] frame];
    // If the window with the preferred arrow direction already falls within the screen bounds then no need to go any further
    NSRect windowFrame = [self _windowFrameWithArrowDirection:direction];
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
    windowFrame = [self _windowFrameWithArrowDirection:newDirection];
    if (NSContainsRect(screenFrame, windowFrame)) {
        return newDirection;
    }
    // Calculate the remaining space on each side and figure out which would be the best to try next
    CGFloat left = _screenPoint.x;
    CGFloat right = screenFrame.size.width - _screenPoint.x;
    CGFloat up = screenFrame.size.height - _screenPoint.y;
    CGFloat down = _screenPoint.y;
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
    windowFrame = [self _windowFrameWithArrowDirection:newDirection];
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
    NSPoint windowPoint = [self.positionView convertPoint:_viewPoint toView:nil]; // Convert the point to window coordinates
    _screenPoint = [[self.positionView window] convertBaseToScreen:windowPoint]; // Convert window coordinates to screen coordinates
    NSRect calculatedFrame = [self _windowFrameWithArrowDirection:self.arrowDirection]; // Calculate the window frame based on the arrow direction
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
    _screenPoint = NSZeroPoint;
    _viewPoint = NSZeroPoint;
}

- (void)_callDelegateMethod:(SEL)selector
{
    if ([self.delegate respondsToSelector:selector]) {
        [self.delegate performSelector:selector withObject:self];
    }
}

@end
