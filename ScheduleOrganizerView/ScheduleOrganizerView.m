//
//  ScheduleOrganizerView.m
//  ScheduleOrganizerView
//
//  Created by Conroy, William | Liam | SDTD on 13/03/06.
//  Copyright (c) 2013年 Conroy, William | Liam | SDTD. All rights reserved.
//

#import "ScheduleOrganizerView.h"

#define ARC_CIRCLE_GAP 20.0f
#define CIRCLE_RADIUS 150.0f
#define ARC_RADIUS 20.0f

#define   DEGREES_TO_RADIANS(degrees)  ((M_PI * degrees)/ 180)

@implementation ScheduleOrganizerView

CGFloat arcAngle;
CGPoint arcPoint;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        arcPoint = CGPointMake(10.0f, 10.0f);
        arcAngle = 40.0f;
    }
    return self;
}

float PointPairToBearingDegrees(CGPoint startingPoint, CGPoint endingPoint)
{
    CGPoint originPoint = CGPointMake(endingPoint.x - startingPoint.x, endingPoint.y - startingPoint.y); // get origin point to origin by subtracting end from start
    float bearingRadians = atan2f(originPoint.y, originPoint.x); // get bearing in radians
    float bearingDegrees = bearingRadians * (180.0 / M_PI); // convert to degrees
    bearingDegrees = (bearingDegrees > 0.0 ? bearingDegrees : (360.0 + bearingDegrees)); // correct discontinuity
    return bearingDegrees;
}

- (CGPoint)calculatePointAtEdgeOfCircleWithRadius:(CGFloat)r
                                     andCenter:(CGPoint)center
                                       atAngle:(CGFloat)theta
{
    double x = center.x + r * cos(theta * M_PI / 180);
    double y = center.y + r * sin(theta * M_PI / 180);
    
    return CGPointMake(x, y);
}

- (void)touchBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
}

static inline double radians (double degrees) { return degrees * M_PI/180; }

CGMutablePathRef createArcPathFromBottomOfRect(CGRect rect, CGFloat arcHeight) {
    
    CGRect arcRect = CGRectMake(rect.origin.x,
                                rect.origin.y + rect.size.height - arcHeight,
                                rect.size.width, arcHeight);
    
    CGFloat arcRadius = (arcRect.size.height/2) +
    (pow(arcRect.size.width, 2) / (8*arcRect.size.height));
    CGPoint arcCenter = CGPointMake(arcRect.origin.x + arcRect.size.width/2,
                                    arcRect.origin.y + arcRadius);
    
    CGFloat angle = acos(arcRect.size.width / (2*arcRadius));
    CGFloat startAngle = radians(180) + angle;
    CGFloat endAngle = radians(360) - angle;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, NULL, arcCenter.x, arcCenter.y, arcRadius,
                 startAngle, endAngle, 0);
    CGPathAddLineToPoint(path, NULL, CGRectGetMaxX(rect), CGRectGetMinY(rect));
    CGPathAddLineToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGPathAddLineToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMaxY(rect));
    return path;    
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    
    arcAngle = PointPairToBearingDegrees(self.center, location);
    arcPoint = [self calculatePointAtEdgeOfCircleWithRadius:(CIRCLE_RADIUS/2)+50.0f
                                                  andCenter:self.center
                                                    atAngle:arcAngle];
    [self setNeedsDisplay];
}

void drawLinearGradient(CGContextRef context, CGRect rect, CGColorRef startColor,
                        CGColorRef endColor) {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    
    NSArray *colors = [NSArray arrayWithObjects:(__bridge id)startColor, (__bridge id)endColor, nil];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace,
                                                        (__bridge CFArrayRef) colors, locations);
    
    // More coming...
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    CGContextSaveGState(context);
    CGContextAddRect(context, rect);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    NSLog(@"drawRect");
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    CGRect drawRect = CGRectMake(rect.origin.x, rect.origin.y,rect.size.width, rect.size.height);
    CGContextSetRGBFillColor(contextRef, 255.0f, 255.0f, 255.0f, 1.0f);
    CGContextFillRect(contextRef, drawRect);
    
    CGContextSetLineWidth(contextRef, 8.0);
    CGContextSetRGBFillColor(contextRef, 0.0, 0.0, 0.0, 1.0);
    CGContextSetRGBStrokeColor(contextRef, 0, 0, 0, 1.0);
    
    CGRect circlePointRect = (CGRectMake((rect.size.width/2)-CIRCLE_RADIUS/2.0f, (rect.size.height/2)-CIRCLE_RADIUS/2.0f, CIRCLE_RADIUS, CIRCLE_RADIUS));
    CGContextFillEllipseInRect(contextRef, circlePointRect);
    
    /*CGRect arcPointRect = (CGRectMake((arcPoint.x)-ARC_RADIUS/2.0f, (arcPoint.y)-ARC_RADIUS/2.0f, ARC_RADIUS, ARC_RADIUS));
    CGContextFillEllipseInRect(contextRef, arcPointRect);*/
    //
    
    //CGColorRef lightGrayColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0
    //                                             blue:230.0/255.0 alpha:1.0].CGColor;
    //CGColorRef darkGrayColor = [UIColor colorWithRed:187.0/255.0 green:187.0/255.0
    //                                            blue:187.0/255.0 alpha:1.0].CGColor;
    
    CGRect arcRect = circlePointRect;
    arcRect.size.height = 1;
    
    /*CGContextSaveGState(contextRef);
    CGMutablePathRef arcPath = createArcPathFromBottomOfRect(arcRect, 4.0);
    CGContextAddPath(contextRef, arcPath);
    CGContextClip(contextRef);
    drawLinearGradient(contextRef, arcRect, lightGrayColor, darkGrayColor);
    CGContextRestoreGState(contextRef);
    
    CFRelease(arcPath);*/
    
    /*CGContextSetLineWidth(contextRef, 2);
    CGContextSetStrokeColorWithColor(contextRef, [UIColor blueColor].CGColor);
    CGContextMoveToPoint(contextRef, 10, 500);
    CGContextAddArc(contextRef, 60, 500, 50, M_PI / 2, M_PI, 0);
    CGContextStrokePath(contextRef);*/
    
    CGFloat minAngle = arcAngle - 10.0f;
    CGFloat maxAngle = arcAngle + 10.0f;
    
    if(minAngle < 0.0f)
    {
        minAngle += 360.0f;
    }
    if(maxAngle > 360.0f)
    {
        maxAngle -= 360.0f;
    }
    
    UIBezierPath *aPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(rect.size.width/2, rect.size.width/2)
                                                         radius:CIRCLE_RADIUS+ARC_CIRCLE_GAP
                                                     startAngle:DEGREES_TO_RADIANS(minAngle)
                                                       endAngle:DEGREES_TO_RADIANS(maxAngle)
                                                      clockwise:YES];
    
    [aPath stroke];
}


@end
