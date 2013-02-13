//
//  INPopoverWindow.h
//  Copyright 2011 Indragie Karunaratne. All rights reserved.
//
//  Licensed under the BSD License <http://www.opensource.org/licenses/bsd-license>
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import <AppKit/AppKit.h>
#import "INPopoverControllerDefines.h"

/** 
 @class INPopoverWindow
 An NSWindow subclass used to draw a custom window frame (@class INPopoverWindowFrame)
 **/
@class INPopoverWindowFrame;
@class INPopoverController;
@interface INPopoverWindow : NSWindow {
	NSView *_popoverContentView;
	NSWindow *_zoomWindow;
}

@property (nonatomic, readonly) INPopoverWindowFrame *frameView; // Equivalent to contentView
@property (nonatomic, retain) NSView *popoverContentView;

- (void)presentWithPopoverController:(INPopoverController *)popoverController;
- (void)dismissAnimated;

@end
