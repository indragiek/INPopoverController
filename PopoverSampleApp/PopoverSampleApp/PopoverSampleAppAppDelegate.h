//
//  PopoverSampleAppAppDelegate.h
//  Copyright 2011-2014 Indragie Karunaratne. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class INPopoverController;
@interface PopoverSampleAppAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *__weak window;
    INPopoverController *popoverController;
}
@property (nonatomic, strong) INPopoverController *popoverController;
@property (weak) IBOutlet NSWindow *window;
- (IBAction)togglePopover:(id)sender;
@end
