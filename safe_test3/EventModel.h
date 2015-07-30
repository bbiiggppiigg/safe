//
//  EventModel.h
//  safe_test3
//
//  Created by Man-Chun Hsieh on 7/30/15.
//  Copyright (c) 2015 bbiiggppiigg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventModel : NSObject

@property (assign, nonatomic) int ID;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSDate *alarmTime;
@property (strong, nonatomic) NSString *name;

@end
