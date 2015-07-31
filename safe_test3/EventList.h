//
//  EventList.h
//  safe_test3
//
//  Created by bbiiggppiigg on 2015/7/30.
//  Copyright (c) 2015年 bbiiggppiigg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddEvent.h"

@interface EventList : UITableViewController<AddEventDelegate>
@property NSMutableArray * eventList;
-(void) loadData;
@end
