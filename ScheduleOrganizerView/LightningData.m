//
//  LightningData.m
//  ScheduleOrganizerView
//
//  Created by Conroy, William | Liam | SDTD on 13/03/08.
//  Copyright (c) 2013年 Conroy, William | Liam | SDTD. All rights reserved.
//

#import "LightningData.h"
#import "Vector2D.h"
#import <Accelerate/Accelerate.h>

#define NUM_GENERATIONS 5


@implementation LightningData

typedef struct Line
{
    CGPoint start;
    CGPoint end;
}CGLine;

NSMutableArray * lineSegments;

- (void)renderDataOntoContext:(CGContextRef)context
{
    NSLog(@"- (void)renderDataOntoContext:(CGContextRef)context");
    CGContextSetLineWidth(context, 1.0);
    
    for (NSValue * lineVal in lineSegments)
    {
        CGLine l;
        [lineVal getValue:&l];
        
        //CGContextMoveToPoint(context, 0.0f, 0.0f);
        CGContextMoveToPoint(context, l.start.x, l.start.y);
        CGContextAddLineToPoint(context, l.end.x, l.end.y);
        CGContextStrokePath(context);
        
        //CGRect circlePointRect = (CGRectMake((perpPoint.x)-20.0f, (perpPoint.y)-20.0f, 40.0f, 40.0f));
        //CGContextFillEllipseInRect(context, circlePointRect);
    }
}

// point along line decided by 0.0f->1.0f float
- (CGPoint)intermediatePointOnLine:(CGLine)line atPoint:(CGFloat)t
{
    float p0[2] = { line.start.x, line.start.y };
    float p1[2] = { line.end.x, line.end.y };
    float delta[2] = { 0.0f, 0.0f };
    
    vDSP_vsub( &p0[0], 1, &p1[0], 1, &delta[0], 1, 2 );
    
    float distance;
    vDSP_vdist( &delta[0], 1, &delta[1], 1, &distance, 1, 1 );
    
    if (distance == 0.0f)
    {
        return CGPointMake(p0[0], p0[1]);
    }
    else
    {
        float dir[2];
        
        vDSP_vsdiv( &delta[0], 1, &distance, &dir[0], 1, 2 );
        
        //Vector2 direction = delta / distance;
        
        //return p0 + direction * (distance * t);
        return CGPointMake(p0[0] + dir[0] * (distance * t), p0[1] + dir[1] * (distance * t));
    }
}

- (CGLine)parralellOfLine:(CGLine)line withOffset:(CGFloat)offset
{
    float L = (float)sqrt((line.start.x-line.end.x)*(line.start.x-line.end.x)
                          +(line.start.y-line.end.y)*(line.start.y-line.end.y));
    
    float x0p = line.start.x + offset * (line.end.y-line.start.y) / L;
    float x1p = line.end.x + offset * (line.end.y-line.start.y) / L;
    float y0p = line.start.y + offset * (line.start.x-line.end.x) / L;
    float y1p = line.end.y + offset * (line.start.x-line.end.x) / L;

    CGLine retLine;
    retLine.start = CGPointMake(x0p, y0p);
    retLine.end = CGPointMake(x1p, y1p);
    
    return retLine;
}

-(float)distanceFrom:(CGPoint)point1 to:(CGPoint)point2
{
    CGFloat xDist = (point2.x - point1.x);
    CGFloat yDist = (point2.y - point1.y);
    return sqrt((xDist * xDist) + (yDist * yDist));
}

- (void)clearData
{
    [lineSegments removeAllObjects];
}

/*
 direction = midPoint - startPoint;
 splitEnd = Rotate(direction, randomSmallAngle)*lengthScale + midPoint; // lengthScale is, for best results, < 1.  0.7 is a good value.
 segmentList.Add(new Segment(midPoint, splitEnd));
 */

- (void)regenerateForkDataBetweenPoint:(CGPoint)a andPoint:(CGPoint)b
{
    NSLog(@"- (void)regenerateData");
    
    [self clearData];
    CGLine line;
    line.start = a;
    line.end = b;
    
    [lineSegments addObject:[NSValue value:&line withObjCType:@encode(struct Line)]];
    
    float offsetAmount = 1.0f;
    
    for(int i = 0; i < NUM_GENERATIONS; i++)
    {
        int countAtBeginningOfGeneration = lineSegments.count;
        
        for (int j = 0; j < countAtBeginningOfGeneration; j++)
        {
            NSValue *lineVal = [lineSegments objectAtIndex:j];
            CGLine l;
            [lineVal getValue:&l];
            
            float splitpoint = ((((float)arc4random()/0x100000000)*100) - 50.0f) * offsetAmount;
            
            CGPoint perpPoint = [self intermediatePointOnLine:[self parralellOfLine:l withOffset:splitpoint] atPoint:0.5f];
            
            CGLine firstHalf;
            CGLine secondHalf;
            
            firstHalf.start = l.start;
            firstHalf.end = perpPoint;
            secondHalf.start = perpPoint;
            secondHalf.end = l.end;
            
            [lineSegments removeObject:lineVal];
            [lineSegments addObject:[NSValue value:&firstHalf withObjCType:@encode(struct Line)]];
            [lineSegments addObject:[NSValue value:&secondHalf withObjCType:@encode(struct Line)]];
            
            
            /*direction = midPoint - startPoint;
            splitEnd = Rotate(direction, randomSmallAngle)*lengthScale + midPoint; // lengthScale is, for best results, < 1.  0.7 is a good value.
            segmentList.Add(new Segment(midPoint, splitEnd));*/
        }
        
        offsetAmount /= 2;
    }
}

- (void)regenerateBoltDataBetweenPoint:(CGPoint)a andPoint:(CGPoint)b
{
    NSLog(@"- (void)regenerateData");
    
    [self clearData];
    CGLine line;
    line.start = a;
    line.end = b;
    
    [lineSegments addObject:[NSValue value:&line withObjCType:@encode(struct Line)]];
    
    float offsetAmount = 1.0f;
    
    for(int i = 0; i < NUM_GENERATIONS; i++)
    {
        int countAtBeginningOfGeneration = lineSegments.count;
        
        for (int j = 0; j < countAtBeginningOfGeneration; j++)
        {
            NSValue *lineVal = [lineSegments objectAtIndex:j];
            CGLine l;
            [lineVal getValue:&l];
            
            float splitpoint = ((((float)arc4random()/0x100000000)*100) - 50.0f) * offsetAmount;
            
            CGPoint perpPoint = [self intermediatePointOnLine:[self parralellOfLine:l withOffset:splitpoint] atPoint:0.5f];
            
            CGLine firstHalf;
            CGLine secondHalf;
            
            firstHalf.start = l.start;
            firstHalf.end = perpPoint;
            secondHalf.start = perpPoint;
            secondHalf.end = l.end;
            
            [lineSegments removeObject:lineVal];
            [lineSegments addObject:[NSValue value:&firstHalf withObjCType:@encode(struct Line)]];
            [lineSegments addObject:[NSValue value:&secondHalf withObjCType:@encode(struct Line)]];
            
            
        }
        
        offsetAmount /= 2;
    }
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        // Initialization code
        lineSegments = [[NSMutableArray alloc] init];
        //[self regenerateData];
        srand((int)time(NULL));
    }
    return self;
}


@end
