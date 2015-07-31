//
//  DateHelper.m
//  safe_test3
//
//  Created by bbiiggppiigg on 2015/7/31.
//  Copyright (c) 2015年 bbiiggppiigg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DateHelper.h"

@implementation DateHelper

+(NSDateFormatter * ) getFormatter{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm"];
    [format setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC+8"]];
    return format;
}
@end