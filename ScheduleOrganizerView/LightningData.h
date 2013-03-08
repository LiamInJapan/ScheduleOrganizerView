//
//  LightningData.h
//  ScheduleOrganizerView
//
//  Created by Conroy, William | Liam | SDTD on 13/03/08.
//  Copyright (c) 2013年 Conroy, William | Liam | SDTD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LightningData : NSObject

- (void)renderDataOntoContext:(CGContextRef)context;
- (void)regenerateData;

@end
