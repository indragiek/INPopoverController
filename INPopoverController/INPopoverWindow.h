//
//  INPopoverWindow.h
//  Copyright 2011-2014 Indragie Karunaratne. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "INPopoverControllerDefines.h"

/** 
 @class INPopoverWindow
 An NSWindow subclass used to draw a custom window frame (@class INPopoverWindowFrame)
 **/
@class INPopoverWindowFrame;
@class INPopoverController;

@interface INPopoverWindow : NSPanel
@property (nonatomic, readonly) INPopoverWindowFrame *frameView; // Equivalent to contentView
@property (nonatomic, assign) INPopoverController *popoverController;
@property (nonatomic, strong) NSView *popoverContentView;

- (void)presentAnimated;
- (void)dismissAnimated;

@end
