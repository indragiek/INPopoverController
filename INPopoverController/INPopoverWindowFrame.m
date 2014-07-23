//
//  INPopoverWindowFrame.m
//  Copyright 2011-2014 Indragie Karunaratne. All rights reserved.
//

#import "INPopoverWindowFrame.h"

@implementation INPopoverWindowFrame

- (id)initWithFrame:(NSRect)frame
{
	if ((self = [super initWithFrame:frame])) {
		_color = [NSColor colorWithCalibratedWhite:0.0 alpha:0.8];
		_cornerRadius = 4.0;
		_arrowSize = NSMakeSize(23.0, 12.0);
		_arrowDirection = INPopoverArrowDirectionLeft;
	}
	return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	NSRect bounds = [self bounds];
	if (((NSUInteger) self.borderWidth % 2) == 1) { // Remove draw glitch on odd border width
		bounds = NSInsetRect(bounds, 0.5, 0.5);
	}

	NSBezierPath *path = [self _popoverBezierPathWithRect:bounds], *inside;
	
	if([self.color isEqualTo:self.borderColor])	//prevent to redraw over the previous colored area, important if alpha channel used!
	{
		NSUInteger offset = ceil(self.borderWidth / 2.0f);
		inside = [self _popoverBezierPathWithRect: NSMakeRect(offset, offset, bounds.size.width - 2 * offset, bounds.size.height - 2 * offset)];
	}
	else
		inside = path;
	
	if (self.color)
	{
		[self.color set];
		[inside fill];
	}
	
	if (self.borderWidth > 0)
	{
		[path setLineWidth:self.borderWidth];
		
		[self.borderColor set];
		[path stroke];
	}

	const CGFloat arrowWidth = self.arrowSize.width;
	const CGFloat arrowHeight = self.arrowSize.height;
	const CGFloat radius = self.cornerRadius;

	if (self.topHighlightColor) {
		[self.topHighlightColor set];
		NSRect bounds = NSInsetRect([self bounds], arrowHeight, arrowHeight);
		NSRect lineRect = NSMakeRect(floor(NSMinX(bounds) + (radius / 2.0)), NSMaxY(bounds) - self.borderWidth - 1, NSWidth(bounds) - radius, 1.0);

		if (self.arrowDirection == INPopoverArrowDirectionUp) {
			CGFloat width = floor((lineRect.size.width / 2.0) - (arrowWidth / 2.0));
			NSRectFill(NSMakeRect(lineRect.origin.x, lineRect.origin.y, width, lineRect.size.height));
			NSRectFill(NSMakeRect(floor(lineRect.origin.x + (lineRect.size.width / 2.0) + (arrowWidth / 2.0)), lineRect.origin.y, width, lineRect.size.height));
		} else {
			NSRectFill(lineRect);
		}
	}
}

#pragma mark -
#pragma mark Private

- (NSBezierPath *)_popoverBezierPathWithRect:(NSRect)aRect
{
	const CGFloat radius = self.cornerRadius, border = floor(self.borderWidth / 2.0f);
	const CGFloat arrowWidth = self.arrowSize.width;
	const CGFloat arrowHeight = self.arrowSize.height;
	const CGFloat inset = radius + arrowHeight + ceil(self.borderWidth / 2.0f);
	const NSRect drawingRect = NSInsetRect(aRect, inset, inset);
	
	const CGFloat minX = NSMinX(drawingRect) - ((self.arrowDirection == INPopoverArrowDirectionUp || self.arrowDirection == INPopoverArrowDirectionDown) ? border : 0);
	const CGFloat maxX = NSMaxX(drawingRect) - ((self.arrowDirection == INPopoverArrowDirectionUp || self.arrowDirection == INPopoverArrowDirectionDown) ? border : 0);
	const CGFloat minY = NSMinY(drawingRect) - ((self.arrowDirection == INPopoverArrowDirectionRight || self.arrowDirection == INPopoverArrowDirectionLeft) ? border : 0);
	const CGFloat maxY = NSMaxY(drawingRect) - ((self.arrowDirection == INPopoverArrowDirectionRight || self.arrowDirection == INPopoverArrowDirectionLeft) ? border : 0);

	NSBezierPath *path = [NSBezierPath bezierPath];
	[path setLineJoinStyle:NSRoundLineJoinStyle];

	// Bottom left corner
	[path appendBezierPathWithArcWithCenter:NSMakePoint(minX, minY) radius:radius startAngle:180.0 endAngle:270.0];
	if (self.arrowDirection == INPopoverArrowDirectionDown) {
		CGFloat midX = NSMidX(drawingRect);
		NSPoint points[3];
		points[0] = NSMakePoint(floor(midX - (arrowWidth / 2.0)), minY - radius); // Starting point
		points[1] = NSMakePoint(floor(midX), points[0].y - arrowHeight); // Arrow tip
		points[2] = NSMakePoint(floor(midX + (arrowWidth / 2.0)), points[0].y); // Ending point
		[path appendBezierPathWithPoints:points count:3];
	}
	// Bottom right corner
	[path appendBezierPathWithArcWithCenter:NSMakePoint(maxX, minY) radius:radius startAngle:270.0 endAngle:360.0];
	if (self.arrowDirection == INPopoverArrowDirectionRight) {
		CGFloat midY = NSMidY(drawingRect);
		NSPoint points[3];
		points[0] = NSMakePoint(maxX + radius, floor(midY - (arrowWidth / 2.0)));
		points[1] = NSMakePoint(points[0].x + arrowHeight, floor(midY));
		points[2] = NSMakePoint(points[0].x, floor(midY + (arrowWidth / 2.0)));
		[path appendBezierPathWithPoints:points count:3];
	}
	// Top right corner
	[path appendBezierPathWithArcWithCenter:NSMakePoint(maxX, maxY) radius:radius startAngle:0.0 endAngle:90.0];
	if (self.arrowDirection == INPopoverArrowDirectionUp) {
		CGFloat midX = NSMidX(drawingRect);
		NSPoint points[3];
		points[0] = NSMakePoint(floor(midX + (arrowWidth / 2.0)), maxY + radius);
		points[1] = NSMakePoint(floor(midX), points[0].y + arrowHeight);
		points[2] = NSMakePoint(floor(midX - (arrowWidth / 2.0)), points[0].y);
		[path appendBezierPathWithPoints:points count:3];
	}
	// Top left corner
	[path appendBezierPathWithArcWithCenter:NSMakePoint(minX, maxY) radius:radius startAngle:90.0 endAngle:180.0];
	if (self.arrowDirection == INPopoverArrowDirectionLeft) {
		CGFloat midY = NSMidY(drawingRect);
		NSPoint points[3];
		points[0] = NSMakePoint(minX - radius, floor(midY + (arrowWidth / 2.0)));
		points[1] = NSMakePoint(points[0].x - arrowHeight, floor(midY));
		points[2] = NSMakePoint(points[0].x, floor(midY - (arrowWidth / 2.0)));
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


- (void)setBorderWidth:(CGFloat)newBorderWidth
{
	if (_borderWidth != newBorderWidth) {
		_borderWidth = newBorderWidth;
		[self setNeedsDisplay:YES];
	}
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
	if (_cornerRadius != cornerRadius) {
		_cornerRadius = cornerRadius;
		[self setNeedsDisplay:YES];
	}
}

- (void)setArrowSize:(NSSize)arrowSize
{
	if (!NSEqualSizes(_arrowSize, arrowSize)) {
		_arrowSize = arrowSize;
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

@end
