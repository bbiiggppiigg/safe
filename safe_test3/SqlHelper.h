//
//  SqlHelper.h
//  safe_test3
//
//  Created by Man-Chun Hsieh on 7/30/15.
//  Copyright (c) 2015 bbiiggppiigg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventModel.h"
#import <sqlite3.h>


@interface SqlHelper : NSObject
@property (strong, nonatomic) NSString *databasePath;
@property (nonatomic) sqlite3 *DB;


-(void)createDB;
-(void) insertEvent:(EventModel *)event;
-(EventModel *) selectEvent:(int)event_id;
-(NSArray *) selectAllEvent;
-(void) removeEvent:(int)event_id;

@end
