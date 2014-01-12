//
//  INPopoverWindowFrame.m
//  Copyright 2011-2014 Indragie Karunaratne. All rights reserved.
//

#import "INPopoverWindowFrame.h"

@implementation INPopoverWindowFrame

- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		// Set some default values
		self.arrowDirection = INPopoverArrowDirectionLeft;
		self.color = [NSColor colorWithCalibratedWhite:0.0 alpha:0.8];
	}
	return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect bounds = [self bounds];
    if ( ( (int)self.borderWidth % 2 ) == 1) // Remove draw glitch on odd border width
        bounds = NSInsetRect(bounds, 0.5f, 0.5f);
    
	NSBezierPath *path = [self _popoverBezierPathWithRect:bounds];
	[self.color set];
	[path fill];
	
	[path setLineWidth:self.borderWidth];
	[self.borderColor set];
	[path stroke];
	
	if (self.topHighlightColor) {
		[self.topHighlightColor set];
		NSRect bounds = NSInsetRect([self bounds], INPOPOVER_ARROW_HEIGHT, INPOPOVER_ARROW_HEIGHT);
		NSRect lineRect = NSMakeRect(floor(NSMinX(bounds) + (INPOPOVER_CORNER_RADIUS / 2.0)), NSMaxY(bounds) - self.borderWidth - 1, NSWidth(bounds) - INPOPOVER_CORNER_RADIUS, 1.0);
		
		if (self.arrowDirection == INPopoverArrowDirectionUp) {
			CGFloat width = floor((lineRect.size.width / 2.0) - (INPOPOVER_ARROW_WIDTH / 2.0));
			NSRectFill(NSMakeRect(lineRect.origin.x, lineRect.origin.y, width, lineRect.size.height));
			NSRectFill(NSMakeRect(floor(lineRect.origin.x + (lineRect.size.width / 2.0) + (INPOPOVER_ARROW_WIDTH / 2.0)), lineRect.origin.y, width, lineRect.size.height));
		} else {
			NSRectFill(lineRect);
		}
	}
}

#pragma mark -
#pragma mark Private

- (NSBezierPath *)_popoverBezierPathWithRect:(NSRect)aRect
{
	CGFloat radius = INPOPOVER_CORNER_RADIUS;
	CGFloat inset = radius + INPOPOVER_ARROW_HEIGHT;
	NSRect drawingRect = NSInsetRect(aRect, inset, inset);
	CGFloat minX = NSMinX(drawingRect);
	CGFloat maxX = NSMaxX(drawingRect);
	CGFloat minY = NSMinY(drawingRect);
	CGFloat maxY = NSMaxY(drawingRect);
	
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path setLineJoinStyle:NSRoundLineJoinStyle];
	
	// Bottom left corner
	[path appendBezierPathWithArcWithCenter:NSMakePoint(minX, minY) radius:radius startAngle:180.0 endAngle:270.0];
	if (self.arrowDirection == INPopoverArrowDirectionDown) {
		CGFloat midX = NSMidX(drawingRect);
		NSPoint points[3];
		points[0] = NSMakePoint(floor(midX - (INPOPOVER_ARROW_WIDTH / 2.0)), minY - radius); // Starting point
		points[1] = NSMakePoint(floor(midX), points[0].y - INPOPOVER_ARROW_HEIGHT); // Arrow tip
		points[2] = NSMakePoint(floor(midX + (INPOPOVER_ARROW_WIDTH / 2.0)), points[0].y); // Ending point
		[path appendBezierPathWithPoints:points count:3];
	}
	// Bottom right corner
	[path appendBezierPathWithArcWithCenter:NSMakePoint(maxX, minY) radius:radius startAngle:270.0 endAngle:360.0];
	if (self.arrowDirection == INPopoverArrowDirectionRight) {
		CGFloat midY = NSMidY(drawingRect);
		NSPoint points[3];
		points[0] = NSMakePoint(maxX + radius, floor(midY - (INPOPOVER_ARROW_WIDTH / 2.0)));
		points[1] = NSMakePoint(points[0].x + INPOPOVER_ARROW_HEIGHT, floor(midY));
		points[2] = NSMakePoint(points[0].x, floor(midY + (INPOPOVER_ARROW_WIDTH / 2.0)));
		[path appendBezierPathWithPoints:points count:3];
	}
	// Top right corner
	[path appendBezierPathWithArcWithCenter:NSMakePoint(maxX, maxY) radius:radius startAngle:0.0 endAngle:90.0];
	if (self.arrowDirection == INPopoverArrowDirectionUp) {
		CGFloat midX = NSMidX(drawingRect);
		NSPoint points[3];
		points[0] = NSMakePoint(floor(midX + (INPOPOVER_ARROW_WIDTH / 2.0)), maxY + radius);
		points[1] = NSMakePoint(floor(midX), points[0].y + INPOPOVER_ARROW_HEIGHT);
		points[2] = NSMakePoint(floor(midX - (INPOPOVER_ARROW_WIDTH / 2.0)), points[0].y);
		[path appendBezierPathWithPoints:points count:3];
	}
	// Top left corner
	[path appendBezierPathWithArcWithCenter:NSMakePoint(minX, maxY) radius:radius startAngle:90.0 endAngle:180.0];
	if (self.arrowDirection == INPopoverArrowDirectionLeft) {
		CGFloat midY = NSMidY(drawingRect);
		NSPoint points[3];
		points[0] = NSMakePoint(minX - radius, floor(midY + (INPOPOVER_ARROW_WIDTH / 2.0)));
		points[1] = NSMakePoint(points[0].x - INPOPOVER_ARROW_HEIGHT, floor(midY));
		points[2] = NSMakePoint(points[0].x, floor(midY - (INPOPOVER_ARROW_WIDTH / 2.0)));
		[path appendBezierPathWithPoints:points count:3];
	}
	[path closePath];
	
	return path;
}

#pragma mark -
#pragma mark Accessors

// Redraw the frame every time a property is changed
- (void)setColor:(NSColor *)newColor
{
	if (_color != newColor) {
        _color = newColor;
		[self setNeedsDisplay:YES];
	}
}

- (void)setBorderColor:(NSColor *)newBorderColor
{
	if (_borderColor != newBorderColor) {
        _borderColor = newBorderColor;
		[self setNeedsDisplay:YES];
	}
}

- (void)setArrowDirection:(INPopoverArrowDirection)newArrowDirection
{
	if (_arrowDirection != newArrowDirection) {
		_arrowDirection = newArrowDirection;
		[self setNeedsDisplay:YES];
	}
}

- (void)setBorderWidth:(CGFloat)newBorderWidth
{
	if (_borderWidth != newBorderWidth) {
		_borderWidth = newBorderWidth;
		[self setNeedsDisplay:YES];
	}
}

@end
