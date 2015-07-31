//
//  SqlHelper.m
//  safe_test3
//
//  Created by Man-Chun Hsieh on 7/30/15.
//  Copyright (c) 2015 bbiiggppiigg. All rights reserved.
//

#import "SqlHelper.h"
#import "Person.h"



@implementation SqlHelper

-(void)createDB{
    NSString *docsDir;
    NSArray *dirPaths;
    
    //Get the directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    //Build the path to keep the database
    _databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"myEvents.db"]];
    NSLog(@"%@",_databasePath);
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if([filemgr fileExistsAtPath:_databasePath] == NO){
        const char *dbpath = [_databasePath UTF8String];
        
        if(sqlite3_open(dbpath, &_DB) == SQLITE_OK){
            char *errorMessage;
            const char *create_event_table_sql = "CREATE TABLE IF NOT EXISTS events (ID INTEGER PRIMARY KEY AUTOINCREMENT, TITLE TEXT, TIME TEXT)";
            const char *create_person_table_sql = "CREATE TABLE IF NOT EXISTS person (PID INTEGER PRIMARY KEY , FIRST_NAME TEXT , LAST_NAME TEXT)";
            const char *create_phone_table_sql = "CREATE TABLE IF NOT EXISTS phone (PID INTEGER, PHONE_NUMBER TEXT PRIMARY KEY)";
            const char * create_eid_pid_table_sql = "CREATE TABLE IF NOT EXISTS eid_pid(EID INTEGER , PID INTEGER)";
        
            if(sqlite3_exec(_DB, create_event_table_sql, NULL, NULL, &errorMessage) != SQLITE_OK){
                //[self showUIAlertWithMessage:@"Failed to create the table" andTitle:@"Error"];
                NSLog(@"Failed to create the table event");
            }
            if(sqlite3_exec(_DB, create_person_table_sql, NULL, NULL, &errorMessage) != SQLITE_OK){
                //[self showUIAlertWithMessage:@"Failed to create the table" andTitle:@"Error"];
                NSLog(@"Failed to create the table person");
            }
            if(sqlite3_exec(_DB, create_phone_table_sql, NULL, NULL, &errorMessage) != SQLITE_OK){
                //[self showUIAlertWithMessage:@"Failed to create the table" andTitle:@"Error"];
                NSLog(@"Failed to create the table phone");
            }
            if(sqlite3_exec(_DB, create_eid_pid_table_sql, NULL, NULL, &errorMessage) != SQLITE_OK){
                //[self showUIAlertWithMessage:@"Failed to create the table" andTitle:@"Error"];
                NSLog(@"Failed to create the table phone");
            }
            sqlite3_close(_DB);
        }
        else{
            //[self showUIAlertWithMessage:@"Failed to open/create the table" andTitle:@"Error"];
            NSLog(@"Failed to open/create the table");
        }
    }
}

-(int) executeSQLStatement : (NSString *) query{
    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String];
    if(sqlite3_open(dbpath, &_DB) == SQLITE_OK){
        const char *sql_statement = [query UTF8String];
        sqlite3_prepare_v2(_DB, sql_statement, -1, &statement, NULL);
        if(sqlite3_step(statement) == SQLITE_DONE){
            //[self showUIAlertWithMessage:@"Event added to the database Successful" andTitle:@"Message"];
            NSLog(@"Query Success %@",query);
        }
        else{
            //[self showUIAlertWithMessage:@"Failed to add the event" andTitle:@"Error"];
            NSLog(@"Query Failed %@",query);
            NSLog(@"%s",sqlite3_errmsg(_DB));
            return -1;
        }
        int eid = (int) sqlite3_last_insert_rowid(_DB);
        sqlite3_finalize(statement);
        sqlite3_close(_DB);
        return eid;
    }
    return -1;
    
}

-(void) insertEvent:(EventModel *)event withContacts:(NSMutableDictionary *)contacts{

    NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO events (title, time) VALUES (\"%@\", \"%@\")", event.title,[ [self getFormatter] stringFromDate:event.alarmTime ] ];
    
    int eid = [self executeSQLStatement:insertSQL];
    
    for (id key in contacts){
        Person * p = [contacts objectForKey:key];
        int pid = (int) key;
        NSString * insertPersonSQL = [NSString stringWithFormat: @"INSERT or IGNORE INTO person (pid, first_name, last_name) values (\"%d\",\"%@\",\"%@\")", pid, p.firstName, p.lastName];
        [self executeSQLStatement:insertPersonSQL];
        for(NSString * numbers in p.phoneNumbers){
            NSString * insertPhoneSQL = [NSString stringWithFormat:@"INSERT or IGNORE INTO phone (pid, phone_number ) values (\"%d\",\"%@\")" , pid,numbers];
            [self executeSQLStatement:insertPhoneSQL];
        }
        NSString * insertEidPidSQL = [NSString stringWithFormat:@"INSERT or IGNORE INTO eid_pid (eid,pid) values(\"%d\",\"%d\")",eid,pid];
        [self executeSQLStatement:insertEidPidSQL];
        
    }

    
}

-(NSDateFormatter * ) getFormatter{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm"];
    [format setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC+8"]];
    return format;
}

-(NSArray * ) selectEventById:(int) event_id{
    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String];
    
    NSMutableArray * ma = [[NSMutableArray alloc] init];
  //  EventModel *result = [[EventModel alloc] init];
    
    if(sqlite3_open(dbpath, &_DB) == SQLITE_OK){
        NSString *querySQL = [NSString stringWithFormat:@"SELECT id, title, time FROM events WHERE id = \"%d\"", event_id];
        const char *query_statement = [querySQL UTF8String];
        if(sqlite3_prepare_v2(_DB, query_statement, -1, &statement, NULL) == SQLITE_OK){
            if(sqlite3_step(statement) == SQLITE_ROW){
                
                sqlite3_stmt *statement2;
                NSString *querySQL2 = [NSString stringWithFormat:@"SELECT pid, first_name , last_name FROM person natural join eid_pid WHERE eid = \"%d\" ", event_id];
                //NSString *querySQL2 = [NSString stringWithFormat:@"SELECT pid, first_name , last_name FROM person"];
                
                NSLog(@"%@",querySQL2);
                const char *query_statement2 = [querySQL2 UTF8String];
                if(sqlite3_prepare_v2(_DB, query_statement2, -1, &statement2, NULL) == SQLITE_OK){
                    while(sqlite3_step(statement2)==SQLITE_ROW){
                        int pid = sqlite3_column_int(statement2,0);
                        NSLog(@"found person with pid %d",pid);
                        NSString * first_name = [[NSString alloc] initWithUTF8String: (char *) sqlite3_column_text(statement2, 1)];
                        NSString * last_name = [[NSString alloc] initWithUTF8String: (char *) sqlite3_column_text(statement2, 2)];
                        sqlite3_stmt * statement3;
                        NSString *querySQL3 = [NSString stringWithFormat:@"SELECT phone_number FROM phone , person WHERE person.pid = \"%d\"  and phone.pid = person.pid ", pid];
                        const char *query_statement3 = [querySQL3 UTF8String];
                        
                        NSMutableArray * phones = [[NSMutableArray alloc]init];
                        if(sqlite3_prepare_v2(_DB, query_statement3, -1, &statement3, NULL) == SQLITE_OK){
                            while(sqlite3_step(statement3)==SQLITE_OK){
                                [phones addObject: [[NSString alloc ] initWithUTF8String :(char *)(sqlite3_column_text(statement3,0))]];
                            }
                            sqlite3_finalize(statement3);
                        }else{
                            NSLog(@"%s",sqlite3_errmsg(_DB));
                        }
                        
                        Person * p = [[Person alloc] initWithPid:pid withFirstName:first_name withLastName:last_name withPhoneNumbers:phones];
                        [ma addObject:p];
                    }
                
                }else{
                    NSLog(@"%s",sqlite3_errmsg(_DB));
                }
                
                NSLog(@"Match %d found in database",event_id);
                
                sqlite3_finalize(statement2);
            }else{
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
    return ma;

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
    NSLog(@"select all events");
    NSMutableArray *returnData = [NSMutableArray new];
    
    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String];
    if(sqlite3_open(dbpath, &_DB) == SQLITE_OK){
        NSString *querySQL = [NSString stringWithFormat:@"SELECT id, title, time FROM events order by time asc"];
        const char *query_statement = [querySQL UTF8String];
        
        if(sqlite3_prepare_v2(_DB, query_statement, -1, &statement, NULL) == SQLITE_OK){
            while (sqlite3_step(statement) == SQLITE_ROW) {
                EventModel *event = [[EventModel alloc] init];
                event.ID = sqlite3_column_int(statement, 0);
                char *title = (char *) sqlite3_column_text(statement, 1);
                char *time = (char *) sqlite3_column_text(statement, 2);
                //NSString *stime = [[NSString alloc] initWithUTF8String:time];
                
                event.title = [[NSString alloc] initWithUTF8String:title];
                event.alarmTime = [[self getFormatter] dateFromString:[[NSString alloc] initWithUTF8String:time]];
                NSLog(@"alarm time = %s",time);
                [returnData addObject:event];
            }
            
            sqlite3_finalize(statement);
        }else{
            //[self showUIAlertWithMessage:@"Failed to search the database" andTitle:@"Error"];
            NSLog(@"Failed to search the database %s",sqlite3_errmsg(_DB));
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


