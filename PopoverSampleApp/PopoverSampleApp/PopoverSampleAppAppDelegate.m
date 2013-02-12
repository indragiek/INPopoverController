//
//  PopoverSampleAppAppDelegate.m
//  Copyright 2011 Indragie Karunaratne. All rights reserved.
//
//  Licensed under the BSD License <http://www.opensource.org/licenses/bsd-license>
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "PopoverSampleAppAppDelegate.h"
#import "ContentViewController.h"
#import "INPopoverController.h"

@implementation PopoverSampleAppAppDelegate

@synthesize window, popoverController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    ContentViewController *viewController = [[ContentViewController alloc] initWithNibName:@"ContentViewController" bundle:nil];
    self.popoverController = [[INPopoverController alloc] initWithContentViewController:viewController];
}

- (IBAction)togglePopover:(id)sender
{
    if (self.popoverController.popoverIsVisible) {
        [self.popoverController closePopover:nil];
    } else {
        [self.popoverController presentPopoverFromRect:[sender bounds] inView:sender preferredArrowDirection:INPopoverArrowDirectionLeft anchorsToPositionView:YES];
    }
}

@end
