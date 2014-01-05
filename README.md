## INPopoverController?
### Open source OS X popover implementation

OS X 10.7 introduced the `NSPopover` class for displaying popover windows. That said, developers who want to support older versions of OS X (like me) are unable to use that API without breaking backward compatibility. So I developed this class that will allow developers to easily add popovers into their applications and also have it be compatible with older versions of OS X (tested on 10.6, should work for 10.5 as well). I've included a sample app to demonstrate how to use INPopoverController:

![INPopoverController](https://raw.github.com/indragiek/INPopoverController/master/screenshot.png)

Features:

- Customizable color, border color, and border width (arrow width/height and popover corner radius are also customizable by editing the INPopoverControllerDefines.h file)
- Autocalculates the best arrow direction depending on screen space and popover position
- Displays content from a regular NSViewController (can be loaded from a NIB)
- Animation for when the popover appears/disappears and when the content size is changed
- Popover can anchor to a view
- Customizable popover behaviour (close when key status is lost, when application resigns active)

### How to use it

The headers are well documented (and I've also included a sample app) so it should be simple to figure out how to use it. There are `color`, `borderColor`, and `borderWidth` properties to customize the appearance of the popover. There are also some hard-coded defines in the `INPopoverControllerDefines.h` file which can be changed to further customize the appearance. The `closesWhenPopoverResignsKey` and `closesWhenApplicationBecomesInactive` properties can be used to control the behaviour of the popover. Everything else should be pretty much self explanatory. 

If you want to completely customize the drawing of the popover, you can edit the `INPopoverWindowFrame.m` file to run your own drawing code instead of the default. Make sure that you're taking the `arrowDirection` property into account when drawing. 

**Important note:** You may notice that there's a little quirk that when interacting with views inside the popover, the main window resigns its key status (and causes it to take on an inactive window appearance). If this is an issue, then I've included a simple `NSWindow` subclass (`/Extras/INAlwaysKeyWindow.h`) that will make a window look like it's key regardless of which window has key status. This might be useful for your main application window.

**Create a new issue if you have trouble getting it working, or if you want to request new features**

### Contact

* Indragie Karunaratne
* [@indragie](http://twitter.com/indragie)
* [http://indragie.com](http://indragie.com)

### Licensing

INPopoverController is licensed under the [BSD license](http://www.opensource.org/licenses/bsd-license.php).