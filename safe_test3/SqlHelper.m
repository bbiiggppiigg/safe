//
//  SqlHelper.m
//  safe_test3
//
//  Created by Man-Chun Hsieh on 7/30/15.
//  Copyright (c) 2015 bbiiggppiigg. All rights reserved.
//

#import "SqlHelper.h"

@implementation SqlHelper

-(void)createDB{
    NSString *docsDir;
    NSArray *dirPaths;
    
    //Get the directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    //Build the path to keep the database
    _databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"myEvents.db"]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if([filemgr fileExistsAtPath:_databasePath] == NO){
        const char *dbpath = [_databasePath UTF8String];
        
        if(sqlite3_open(dbpath, &_DB) == SQLITE_OK){
            char *errorMessage;
            const char *sql_statement = "CREATE TABLE IF NOT EXISTS events (ID INTEGER PRIMARY KEY AUTOINCREMENT, TITLE TEXT, TIME TEXT, FREQ TEXT)";
        
            if(sqlite3_exec(_DB, sql_statement, NULL, NULL, &errorMessage) != SQLITE_OK){
                //[self showUIAlertWithMessage:@"Failed to create the table" andTitle:@"Error"];
                NSLog(@"Failed to create the table");
            }
            sqlite3_close(_DB);
        }
        else{
            //[self showUIAlertWithMessage:@"Failed to open/create the table" andTitle:@"Error"];
            NSLog(@"Failed to open/create the table");
        }
    }
}



-(void) insertEvent:(EventModel *)event{
    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String];
    
    if(sqlite3_open(dbpath, &_DB) == SQLITE_OK){
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO events (title, time, freq) VALUES (\"%@\", \"%@\", \"%d\")", event.title, event.alarmTime, 1];
        
        const char *insert_statement = [insertSQL UTF8String];
        sqlite3_prepare_v2(_DB, insert_statement, -1, &statement, NULL);
        
        if(sqlite3_step(statement) == SQLITE_DONE){
            //[self showUIAlertWithMessage:@"Event added to the database Successful" andTitle:@"Message"];
            NSLog(@"Event added to the database Successful");
        }
        else{
            //[self showUIAlertWithMessage:@"Failed to add the event" andTitle:@"Error"];
            NSLog(@"Failed to add the event");
        }
        sqlite3_finalize(statement);
        sqlite3_close(_DB);
    }
}
-(EventModel *) selectEvent:(int)event_id{
    EventModel *result = [[EventModel alloc] init];
    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String];
    
    if(sqlite3_open(dbpath, &_DB) == SQLITE_OK){
        NSString *querySQL = [NSString stringWithFormat:@"SELECT id, title, time, freq FROM events WHERE id = \"%d\"", event_id];
        const char *query_statement = [querySQL UTF8String];
        
        if(sqlite3_prepare_v2(_DB, query_statement, -1, &statement, NULL) == SQLITE_OK){
            if(sqlite3_step(statement) == SQLITE_ROW){
                result.title =[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                
                char *time = (char *) sqlite3_column_text(statement, 2);
                NSDateFormatter *format = [[NSDateFormatter alloc] init];
                [format setDateFormat:@"yyyy-MM-dd hh:mm"];
                [format setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8]];
                result.alarmTime = [format dateFromString:[[NSString alloc] initWithUTF8String:time]];
                
                
                //[self showUIAlertWithMessage:[NSString stringWithFormat:@"Match %@ found in database",result.ID] andTitle:@"Message"];
                NSLog(@"Match %d found in database",event_id);
                
            }
            else{
                //[self showUIAlertWithMessage:@"Match not found in databse" andTitle:@"Message"];
                NSLog(@"Match not found in databse");
            }
            sqlite3_finalize(statement);
        }
        else{
            //[self showUIAlertWithMessage:@"Failed to search the database" andTitle:@"Error"];
            NSLog(@"Failed to search the database");
        }
        sqlite3_close(_DB);
    }
    return result;
}

-(NSArray *) selectAllEvent{
    
    NSMutableArray *returnData = [NSMutableArray new];
    
    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String];
    if(sqlite3_open(dbpath, &_DB) == SQLITE_OK){
        NSString *querySQL = [NSString stringWithFormat:@"SELECT id, title, time, freq FROM events"];
        const char *query_statement = [querySQL UTF8String];
        
        if(sqlite3_prepare_v2(_DB, query_statement, -1, &statement, NULL) == SQLITE_OK){
            while (sqlite3_step(statement) == SQLITE_ROW) {
                EventModel *event = [[EventModel alloc] init];
                
                char *title = (char *) sqlite3_column_text(statement, 1);
                char *time = (char *) sqlite3_column_text(statement, 2);
                char *freq = (char *) sqlite3_column_text(statement, 3);
                NSString *stime = [[NSString alloc] initWithUTF8String:time];
                NSString *sfreq = [[NSString alloc] initWithUTF8String:freq];
                
                event.ID = sqlite3_column_int(statement, 0);
                event.title = [[NSString alloc] initWithUTF8String:title];
                NSDateFormatter *format = [[NSDateFormatter alloc] init];
                [format setDateFormat:@"yyyy/MM/dd hh:mm"];
                [format setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8]];
                event.alarmTime = [format dateFromString:[[NSString alloc] initWithUTF8String:time]];
                
                [returnData addObject:event];
            }
            
            sqlite3_finalize(statement);
        }else{
            //[self showUIAlertWithMessage:@"Failed to search the database" andTitle:@"Error"];
            NSLog(@"Failed to search the database");
        }
        sqlite3_close(_DB);
    }
    NSLog(@"%@", returnData);
    return returnData;
}


-(void) removeEvent:(int)event_id{
    const char *dbpath = [_databasePath UTF8String];
    char *errorMessage;
    
    if(sqlite3_open(dbpath, &_DB) == SQLITE_OK){
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM events WHERE id = \"%d\"", event_id];
        const char *query_statement = [querySQL UTF8String];
        if(sqlite3_exec(_DB, query_statement, NULL, NULL, &errorMessage) == SQLITE_OK){
            //[self showUIAlertWithMessage:[NSString stringWithFormat:@"Deleted %d from database",event_id] andTitle:@"Message"];
            NSLog(@"Deleted %d from database",event_id);
        }else{
            //[self showUIAlertWithMessage:@"Failed to delete from database" andTitle:@"Error"];
            NSLog(@"Failed to delete from database");
        }
    }else{
        //[self showUIAlertWithMessage:@"Failed to delete from database" andTitle:@"Error"];
        NSLog(@"Failed to delete from database");
    }
    
}



@end


