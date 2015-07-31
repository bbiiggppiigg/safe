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

-(void) insertEvent:(EventModel *)event withContacts :(NSMutableDictionary *) contacts;
-(void) removeEvent:(int)event_id;

-(void) removeEventById:(int) event_id;

-(int) executeSQLStatement : (NSString * ) query;
-(NSArray *) selectAllEvent;
-(NSArray * ) selectEventById:(int) event_id;
-(NSArray * ) selectEventByIdWithPhoneNumbers:(int) event_id;
-(void) updateExistingEvent:(EventModel *) event withContacts:(NSMutableDictionary *) contacts;
@end
