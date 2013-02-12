//
//  INPopoverController.h
//  Copyright 2011 Indragie Karunaratne. All rights reserved.
//
//  Licensed under the BSD License <http://www.opensource.org/licenses/bsd-license>
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import <Cocoa/Cocoa.h>
#import "INPopoverControllerDefines.h"

@class INPopoverWindow;
@protocol INPopoverControllerDelegate;
@interface INPopoverController : NSObject {
#if __has_feature(objc_arc)
	__unsafe_unretained id<INPopoverControllerDelegate> _delegate;
#else
    id<INPopoverControllerDelegate> _delegate;
#endif
	NSSize _contentSize;
	BOOL _closesWhenPopoverResignsKey;
	BOOL _closesWhenApplicationBecomesInactive;
	BOOL _animates;
	NSViewController *_contentViewController;

	INPopoverWindow *_popoverWindow;
	NSView *_positionView;
	NSRect _screenRect;
	NSRect _viewRect;
}

#pragma mark -
#pragma mark Properties

/** The delegate of the INPopoverController object (should conform to the INPopoverControllerDelegate protocol) **/
#if __has_feature(objc_arc)
@property (nonatomic, unsafe_unretained) id<INPopoverControllerDelegate> delegate;
#else
@property (nonatomic, assign) id<INPopoverControllerDelegate> delegate;
#endif

/** The background color of the popover. Default value is [NSColor blackColor] with an alpha value of 0.8. Changes to this value are not animated. **/
@property (nonatomic, retain) NSColor *color;

/** Border color to use when drawing a border. Default value: [NSColor blackColor]. Changes to this value are not animated. **/
@property (nonatomic, retain) NSColor *borderColor;

/** Color to use for drawing a 1px highlight just below the top. Can be nil. Changes to this value are not animated. **/
@property (nonatomic, retain) NSColor *topHighlightColor;

/** The width of the popover border, drawn using borderColor. Default value: 0.0 (no border). Changes to this value are not animated. **/
@property (nonatomic) CGFloat borderWidth;

/** The current arrow direction of the popover. If the popover has never been displayed, then this will return INPopoverArrowDirectionUndefined */
@property (readonly) INPopoverArrowDirection arrowDirection;

/** The size of the content of the popover. This is automatically set to contentViewController's size when the view controller is set, but can be modified. Changes to this value are animated when animates is set to YES **/
@property (nonatomic, assign) NSSize contentSize;

/** Whether the popover closes when the popover window resigns its key status. Default value: YES **/
@property (nonatomic, assign) BOOL closesWhenPopoverResignsKey;

/** Whether the popover closes when the application becomes inactive. Default value: NO **/
@property (nonatomic, assign) BOOL closesWhenApplicationBecomesInactive;

/** Enable or disable animation when showing/closing the popover and changing the content size. Default value: YES */
@property (nonatomic, assign) BOOL animates;

/** The content view controller from which content is displayed in the popover **/
@property (nonatomic, retain) NSViewController *contentViewController;

/** The view that the currently displayed popover is positioned relative to. If there is no popover being displayed, this returns nil. **/
@property (readonly) NSView *positionView;

/** The window of the popover **/
@property (readonly) NSWindow *popoverWindow;

/** Whether the popover is currently visible or not **/
@property (readonly) BOOL popoverIsVisible;

#pragma mark -
#pragma mark Methods

/**
 Initializes the popover with a content view already set.
 @param viewController the content view controller
 @returns a new instance of INPopoverController
 */
- (id)initWithContentViewController:(NSViewController*)viewController;

/**
 Displays the popover.
 @param rect the rect in the positionView from which to display the popover
 @param positionView the view that the popover is positioned relative to
 @param direction the prefered direction at which the arrow will point. There is no guarantee that this will be the actual arrow direction, depending on whether the screen is able to accomodate the popover in that position.
 @param anchors Whether the popover binds to the frame of the positionView. This means that if the positionView is resized or moved, the popover will be repositioned according to the point at which it was originally placed. This also means that if the positionView goes off screen, the popover will be automatically closed. **/

- (void)presentPopoverFromRect:(NSRect)rect inView:(NSView*)positionView preferredArrowDirection:(INPopoverArrowDirection)direction anchorsToPositionView:(BOOL)anchors;

/** 
 Recalculates the best arrow direction for the current window position and resets the arrow direction. The change will not be animated. **/
- (void)recalculateAndResetArrowDirection;

/**
 Closes the popover unless NO is returned for the -popoverShouldClose: delegate method 
 @param sender the object that sent this message
 */
- (IBAction)closePopover:(id)sender;

/**
 Closes the popover regardless of what the delegate returns
 @param sender the object that sent this message
 */
- (IBAction)forceClosePopover:(id)sender;

/**
 Returns the frame for a popop window with a given size depending on the arrow direction.
 @param contentSize the popover window content size
 @param direction the arrow direction
 */
- (NSRect)popoverFrameWithSize:(NSSize)contentSize andArrowDirection:(INPopoverArrowDirection)direction;

@end

@protocol INPopoverControllerDelegate <NSObject>
@optional
/**
 When the -closePopover: method is invoked, this method is called to give a change for the delegate to prevent it from closing. Returning NO for this delegate method will prevent the popover being closed. This delegate method does not apply to the -forceClosePopover: method, which will close the popover regardless of what the delegate returns.
 @param popover the @class INPopoverController object that is controlling the popover
 @returns whether the popover should close or not
 */
- (BOOL)popoverShouldClose:(INPopoverController*)popover;

/**
 Invoked right before the popover shows on screen
 @param popover the @class INPopoverController object that is controlling the popover
 */
- (void)popoverWillShow:(INPopoverController*)popover;

/**
 Invoked right after the popover shows on screen
 @param popover the @class INPopoverController object that is controlling the popover
 */
- (void)popoverDidShow:(INPopoverController*)popover;

/**
 Invoked right before the popover closes
 @param popover the @class INPopoverController object that is controlling the popover
 */
- (void)popoverWillClose:(INPopoverController*)popover;

/**
 Invoked right before the popover closes
 @param popover the @class INPopoverController object that is controlling the popover
 */
- (void)popoverDidClose:(INPopoverController*)popover;
@end
