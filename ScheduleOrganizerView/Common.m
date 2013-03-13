//
//  Common.m
//  ScheduleOrganizerView
//
//  Created by Conroy, William | Liam | SDTD on 13/03/13.
//  Copyright (c) 2013年 Conroy, William | Liam | SDTD. All rights reserved.
//

#import "Common.h"

@implementation Common

// point along line decided by 0.0f->1.0f float
+ (CGPoint)intermediatePointOnLine:(CGLine)line atPoint:(CGFloat)t
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

@end
