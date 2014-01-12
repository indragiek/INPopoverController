//
//  INPopoverController.h
//  Copyright 2011-2014 Indragie Karunaratne. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "INPopoverControllerDefines.h"

@protocol INPopoverControllerDelegate;

@interface INPopoverController : NSObject

#pragma mark -
#pragma mark Properties

/** The delegate of the INPopoverController object (should conform to the INPopoverControllerDelegate protocol) **/
@property (nonatomic, assign) id <INPopoverControllerDelegate> delegate;

/** The background color of the popover. Default value is [NSColor blackColor] with an alpha value of 0.8. Changes to this value are not animated. **/
@property (nonatomic, strong) NSColor *color;

/** Border color to use when drawing a border. Default value: [NSColor blackColor]. Changes to this value are not animated. **/
@property (nonatomic, strong) NSColor *borderColor;

/** Color to use for drawing a 1px highlight just below the top. Can be nil. Changes to this value are not animated. **/
@property (nonatomic, strong) NSColor *topHighlightColor;

/** The width of the popover border, drawn using borderColor. Default value: 0.0 (no border). Changes to this value are not animated. **/
@property (nonatomic, assign) CGFloat borderWidth;

/** Corner radius of the popover window. Default value: 4. Changes to this value are not animated. **/
@property (nonatomic, assign) CGFloat cornerRadius;

/** The size of the popover arrow. Default value: {23, 12}. Changes to this value are not animated. **/
@property (nonatomic, assign) NSSize arrowSize;

/** The current arrow direction of the popover. If the popover has never been displayed, then this will return INPopoverArrowDirectionUndefined */
@property (nonatomic, assign, readonly) INPopoverArrowDirection arrowDirection;

/** The size of the content of the popover. This is automatically set to contentViewController's size when the view controller is set, but can be modified. Changes to this value are animated when animates is set to YES **/
@property (nonatomic, assign) NSSize contentSize;

/** Whether the popover closes when the popover window resigns its key status. Default value: YES **/
@property (nonatomic, assign) BOOL closesWhenPopoverResignsKey;

/** Whether the popover closes when the application becomes inactive. Default value: NO **/
@property (nonatomic, assign) BOOL closesWhenApplicationBecomesInactive;

/** Enable or disable animation when showing/closing the popover and changing the content size. Default value: YES */
@property (nonatomic, assign) BOOL animates;

/* If `animates` is `YES`, this is the animation type to use when showing/closing the popover.
   Default value: `INPopoverAnimationTypePop` **/
@property (nonatomic, assign) INPopoverAnimationType animationType;

/** The content view controller from which content is displayed in the popover **/
@property (nonatomic, strong) NSViewController *contentViewController;

/** The view that the currently displayed popover is positioned relative to. If there is no popover being displayed, this returns nil. **/
@property (nonatomic, strong, readonly) NSView *positionView;

/** The window of the popover **/
@property (nonatomic, strong, readonly) NSWindow *popoverWindow;

/** Whether the popover is currently visible or not **/
@property (nonatomic, assign, readonly) BOOL popoverIsVisible;

#pragma mark -
#pragma mark Methods

/**
 Initializes the popover with a content view already set.
 @param viewController the content view controller
 @returns a new instance of INPopoverController
 */
- (id)initWithContentViewController:(NSViewController *)viewController;

/**
 Displays the popover.
 @param rect the rect in the positionView from which to display the popover
 @param positionView the view that the popover is positioned relative to
 @param direction the prefered direction at which the arrow will point. There is no guarantee that this will be the actual arrow direction, depending on whether the screen is able to accomodate the popover in that position.
 @param anchors Whether the popover binds to the frame of the positionView. This means that if the positionView is resized or moved, the popover will be repositioned according to the point at which it was originally placed. This also means that if the positionView goes off screen, the popover will be automatically closed. **/

- (void)presentPopoverFromRect:(NSRect)rect inView:(NSView *)positionView preferredArrowDirection:(INPopoverArrowDirection)direction anchorsToPositionView:(BOOL)anchors;

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
- (BOOL)popoverShouldClose:(INPopoverController *)popover;

/**
 Invoked right before the popover shows on screen
 @param popover the @class INPopoverController object that is controlling the popover
 */
- (void)popoverWillShow:(INPopoverController *)popover;

/**
 Invoked right after the popover shows on screen
 @param popover the @class INPopoverController object that is controlling the popover
 */
- (void)popoverDidShow:(INPopoverController *)popover;

/**
 Invoked right before the popover closes
 @param popover the @class INPopoverController object that is controlling the popover
 */
- (void)popoverWillClose:(INPopoverController *)popover;

/**
 Invoked right before the popover closes
 @param popover the @class INPopoverController object that is controlling the popover
 */
- (void)popoverDidClose:(INPopoverController *)popover;
@end
