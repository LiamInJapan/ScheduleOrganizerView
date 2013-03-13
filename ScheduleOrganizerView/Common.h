//
//  Common.h
//  ScheduleOrganizerView
//
//  Created by Conroy, William | Liam | SDTD on 13/03/13.
//  Copyright (c) 2013年 Conroy, William | Liam | SDTD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Common : NSObject

typedef struct Line
{
    CGPoint start;
    CGPoint end;
    float alpha;
}CGLine;

+ (CGPoint)intermediatePointOnLine:(CGLine)line atPoint:(CGFloat)t;

@end
