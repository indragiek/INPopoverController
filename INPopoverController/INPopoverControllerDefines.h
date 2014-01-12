//
//  INPopoverControllerDefines.h
//  Copyright 2011-2014 Indragie Karunaratne. All rights reserved.
//

enum {
	INPopoverArrowDirectionUndefined = 0,
	INPopoverArrowDirectionLeft = NSMaxXEdge,
	INPopoverArrowDirectionRight = NSMinXEdge,
	INPopoverArrowDirectionUp = NSMaxYEdge,
	INPopoverArrowDirectionDown = NSMinYEdge
};
typedef NSRectEdge INPopoverArrowDirection;

/** The arrow height **/ 
#define INPOPOVER_ARROW_HEIGHT 12.0
/** The arrow width **/
#define INPOPOVER_ARROW_WIDTH 23.0
/** Corner radius to use when drawing popover corners **/
#define INPOPOVER_CORNER_RADIUS 4.0