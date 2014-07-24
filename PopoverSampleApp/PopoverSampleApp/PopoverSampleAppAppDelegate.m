//
//  PopoverSampleAppAppDelegate.m
//  Copyright 2011-2014 Indragie Karunaratne. All rights reserved.
//

#import "PopoverSampleAppAppDelegate.h"
#import "ContentViewController.h"
#import <INPopoverController/INPopoverController.h>

@implementation PopoverSampleAppAppDelegate
@synthesize window, popoverController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    ContentViewController *viewController = [[ContentViewController alloc] initWithNibName:@"ContentViewController" bundle:nil];
	viewController.view.wantsLayer = YES;
	viewController.view.layer.backgroundColor = [NSColor redColor].CGColor;
    self.popoverController = [[INPopoverController alloc] initWithContentViewController:viewController];
}

- (IBAction)togglePopover:(id)sender
{
    if (self.popoverController.popoverIsVisible) {
        [self.popoverController closePopover:nil];
    } else {
        [self.popoverController presentPopoverFromRect:[sender bounds] inView:sender preferredArrowDirection:INPopoverArrowDirectionUp anchorsToPositionView:YES];
    }
}

@end
