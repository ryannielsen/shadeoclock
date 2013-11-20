//
//  ShadeoclockView.m
//  Shadeoclock
//
//  Created by Ryan Nielsen on 7/16/11.
//  Copyright 2011 Tumult Inc. All rights reserved.
//

#import "ShadeoclockView.h"
#import <QuartzCore/QuartzCore.h>
#include <time.h>

@interface ShadeoclockView (Private)

@property (retain) NSBezierPath *frameLines;
@property (retain) NSDictionary *stringAttributes;

@end

@implementation ShadeoclockView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
		[self setAnimationTimeInterval:1.0];
		[self setLayer:[CALayer layer]];
		[[self layer] setDelegate:self];
		[[self layer] setNeedsDisplayOnBoundsChange:YES];
		[[self layer] setFrame:NSRectToCGRect(self.bounds)];
		[self setWantsLayer:YES];

		[self setFrameLines:[NSBezierPath bezierPath]];
		[[self frameLines] moveToPoint:NSMakePoint(round([self bounds].size.width / 4.0), round([self bounds].size.height / 2.0) - 1.0)];
		[[self frameLines] lineToPoint:NSMakePoint(3.0 * round([self bounds].size.width / 4.0), round([self bounds].size.height / 2.0) - 1.0)];
		[[self frameLines] appendBezierPathWithRect:NSInsetRect([self bounds], 6.0, 6.0)];
		[[self frameLines] setLineWidth:1.0];
		NSAffineTransform *transform = [NSAffineTransform transform];
		[transform translateXBy:0.5 yBy:0.5];
		[[self frameLines] transformUsingAffineTransform:transform];

		NSMutableParagraphStyle *centeredStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
		[centeredStyle setAlignment:NSCenterTextAlignment];
		[self setStringAttributes:@{NSFontAttributeName: [NSFont fontWithName:@"Helvetica Neue" size:160],
									NSForegroundColorAttributeName: [[NSColor whiteColor] colorWithAlphaComponent:0.9],
									NSStrokeWidthAttributeName: @-0.5f,
									NSStrokeColorAttributeName: [[NSColor blackColor] colorWithAlphaComponent:0.2],
									NSParagraphStyleAttributeName: centeredStyle}];
    }
    return self;
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
	[NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:ctx flipped:NO]];

    time_t timer = time(NULL);
	struct tm *now = localtime(&timer);

	int red = round(255 * (now->tm_hour / 23.0));
	int green = round(255 * (now->tm_min / 59.0));
	int blue = round(255 * (now->tm_sec / 59.0));

	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
	[animation setFromValue:(NSColor *)[layer backgroundColor]];
	CGColorRef color = CGColorCreateGenericRGB((red / 255.0), (green / 255.0), (blue / 255.0), 1.0);
    [animation setToValue:CFBridgingRelease(color)];
	[animation setDuration:1.0];
    color = CGColorCreateGenericRGB((red / 255.0), (green / 255.0), (blue / 255.0), 1.0);
	[layer setBackgroundColor:color];
    CFRelease(color);
	[layer addAnimation:animation forKey:@"backgroundColor"];

	NSAttributedString *hex = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%02X%02X%02X", red, green, blue] attributes:[self stringAttributes]];
	NSRect hexRect = [hex boundingRectWithSize:NSZeroSize options:0];

	NSAttributedString *time = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%02i:%02i:%02i", now->tm_hour, now->tm_min, now->tm_sec] attributes:[self stringAttributes]];
	NSRect timeRect = [time boundingRectWithSize:NSZeroSize options:0];

	[hex drawInRect:NSMakeRect(0.5, round(([self bounds].size.height / 2.0) - hexRect.size.height) + 0.5, [self bounds].size.width, hexRect.size.height)];
	[time drawInRect:NSMakeRect(0.5, round([self bounds].size.height / 2.0) + 0.5, [self bounds].size.width, timeRect.size.height)];

	[[[NSColor whiteColor] colorWithAlphaComponent:0.9] set];
	[[self frameLines] stroke];
    [NSGraphicsContext restoreGraphicsState];
}

- (void)animateOneFrame
{
	[[self layer] setNeedsDisplay];
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

@end
