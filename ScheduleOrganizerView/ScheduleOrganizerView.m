//
//  ScheduleOrganizerView.m
//  ScheduleOrganizerView
//
//  Created by Conroy, William | Liam | SDTD on 13/03/06.
//  Copyright (c) 2013年 Conroy, William | Liam | SDTD. All rights reserved.
//

#import "ScheduleOrganizerView.h"
#import "LightningData.h"

#define ARC_CIRCLE_GAP 5.0f
#define CIRCLE_RADIUS 150.0f
#define ARC_RADIUS 20.0f
#define ARC_POINT_RADIUS 20.0f

#define   DEGREES_TO_RADIANS(degrees)  ((M_PI * degrees)/ 180)

@implementation ScheduleOrganizerView

CGFloat arcAngle;
CGPoint location;	
NSMutableArray * arcPoints;
BOOL holdState;
LightningData * lightning;
NSTimer * timer;

//CGPoint arcPoint;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        arcPoints = [[NSMutableArray alloc] init];
        
        
        //arcPoint = CGPointMake(10.0f, 10.0f);
        arcAngle = 40.0f;
        holdState = false;
        
        /*UILongPressGestureRecognizer *longpressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHandler:)];
        longpressGesture.minimumPressDuration = 1;
        [longpressGesture setDelegate:self];
        [self addGestureRecognizer:longpressGesture];
        */
        lightning = [[LightningData alloc] init];
        
        
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

-(float)distanceFrom:(CGPoint)point1 to:(CGPoint)point2
{
    CGFloat xDist = (point2.x - point1.x);
    CGFloat yDist = (point2.y - point1.y);
    return sqrt((xDist * xDist) + (yDist * yDist));
}

- (BOOL)checkIfTouchIsOnPoint:(CGPoint)touch
{
    for (NSValue * pointVal in arcPoints)
    {
        CGPoint point = [pointVal CGPointValue];
        
        if([self distanceFrom:touch to:point] < ARC_POINT_RADIUS)
        {
            return true;
        }
        else
        {
            return false;
        }
        
    }
    
    return false;
}


- (void)longPressHandler:(UILongPressGestureRecognizer *)gestureRecognizer
{
    [arcPoints addObject:[NSValue valueWithCGPoint:[gestureRecognizer locationInView:self]]];
    [self setNeedsDisplay];
}

- (void)touchLoop
{
    CGPoint center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    [lightning regenerateForkDataBetweenPoint:location andPoint:center];
    [self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"- (void)touchBegan:(NSSet *)touches withEvent:(UIEvent *)event");
    
    UITouch * touch = [touches anyObject];
    location = [touch locationInView:self];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.03f target:self selector:@selector(touchLoop) userInfo:nil repeats:YES];
    
    if([self checkIfTouchIsOnPoint:location])
    {
        
    }
    else
    {
        NSLog(@"touchme");
        holdState = true;
        
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    location = [touch locationInView:self];
                                   
    arcAngle = PointPairToBearingDegrees(self.center, location);
    //arcPoint = [self calculatePointAtEdgeOfCircleWithRadius:(CIRCLE_RADIUS/2)+50.0f
    //                                              andCenter:self.center
    //                                                atAngle:arcAngle];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [lightning clearData];
    [timer invalidate];
    [self setNeedsDisplay];
    holdState = false;
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

- (void)drawArcPointsOnContext:(CGContextRef)context
{
    for (NSValue * pointVal in arcPoints)
    {
        CGPoint arcPoint = [pointVal CGPointValue];
        
        CGRect circlePointRect = (CGRectMake((arcPoint.x)-ARC_POINT_RADIUS/2.0f,
                                             (arcPoint.y)-ARC_POINT_RADIUS/2.0f,
                                            ARC_POINT_RADIUS,
                                             ARC_POINT_RADIUS));
        
        CGContextFillEllipseInRect(context, circlePointRect);
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    CGRect drawRect = CGRectMake(rect.origin.x, rect.origin.y,rect.size.width, rect.size.height);
    CGContextSetRGBFillColor(contextRef, 255.0f, 255.0f, 255.0f, 1.0f);
    CGContextFillRect(contextRef, drawRect);
    
    CGContextSetLineWidth(contextRef, 8.0);
    CGContextSetRGBFillColor(contextRef, 0.0, 0.0, 0.0, 1.0);
    CGContextSetRGBStrokeColor(contextRef, 0, 0, 0, 1.0);
    
    CGRect circlePointRect = (CGRectMake((rect.size.width/2)-CIRCLE_RADIUS/2.0f, (rect.size.height/2)-CIRCLE_RADIUS/2.0f, CIRCLE_RADIUS, CIRCLE_RADIUS));
    //CGContextFillEllipseInRect(contextRef, circlePointRect);
    
    /*CGRect arcRect = circlePointRect;
    arcRect.size.height = 1;
    
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
    
    [aPath stroke];*/
    
    [self drawArcPointsOnContext:contextRef];
    
    [lightning renderDataOntoContext:contextRef];
    
}


@end
