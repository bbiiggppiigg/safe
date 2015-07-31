//
//  SqlHelper.m
//  safe_test3
//
//  Created by Man-Chun Hsieh on 7/30/15.
//  Copyright (c) 2015 bbiiggppiigg. All rights reserved.
//

#import "SqlHelper.h"
#import "Person.h"
#import "DateHelper.h"


@implementation SqlHelper

-(void)createDB{
    NSString *docsDir;
    NSArray *dirPaths;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    _databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"myEvents.db"]];
    //NSLog(@"%@",_databasePath);
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
                NSLog(@"Failed to create the table event");
            }
            if(sqlite3_exec(_DB, create_person_table_sql, NULL, NULL, &errorMessage) != SQLITE_OK){
                NSLog(@"Failed to create the table person");
            }
            if(sqlite3_exec(_DB, create_phone_table_sql, NULL, NULL, &errorMessage) != SQLITE_OK){
                NSLog(@"Failed to create the table phone");
            }
            if(sqlite3_exec(_DB, create_eid_pid_table_sql, NULL, NULL, &errorMessage) != SQLITE_OK){
                NSLog(@"Failed to create the table phone");
            }
            sqlite3_close(_DB);
        }
        else{
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
         //   NSLog(@"Query Success %@",query);
        }
        else{
            //NSLog(@"Query Failed %@",query);
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

    NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO events (title, time) VALUES (\"%@\", \"%@\")", event.title,[ [DateHelper getFormatter] stringFromDate:event.alarmTime ] ];
    //NSLog(insertSQL);
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

/*-(NSDateFormatter * ) getFormatter{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm"];
    [format setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC+8"]];
    return format;
}
*/

-(NSArray * ) selectEventByIdWithPhoneNumbers:(int) event_id{
    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String];
    
    NSMutableArray * ma = [[NSMutableArray alloc] init];
    
    if(sqlite3_open(dbpath, &_DB) == SQLITE_OK){
        NSString *querySQL = [NSString stringWithFormat:@"SELECT id, title, time FROM events WHERE id = \"%d\"", event_id];
        const char *query_statement = [querySQL UTF8String];
        if(sqlite3_prepare_v2(_DB, query_statement, -1, &statement, NULL) == SQLITE_OK){
            if(sqlite3_step(statement) == SQLITE_ROW){
                
                sqlite3_stmt *statement2;
                NSString *querySQL2 = [NSString stringWithFormat:@"SELECT pid, first_name , last_name FROM person natural join eid_pid WHERE eid = \"%d\" ", event_id];
                
               // NSLog(@"%@",querySQL2);
                const char *query_statement2 = [querySQL2 UTF8String];
                if(sqlite3_prepare_v2(_DB, query_statement2, -1, &statement2, NULL) == SQLITE_OK){
                    while(sqlite3_step(statement2)==SQLITE_ROW){
                        int pid = sqlite3_column_int(statement2,0);
                        //NSLog(@"found person with pid %d",pid);
                        NSString * first_name = [[NSString alloc] initWithUTF8String: (char *) sqlite3_column_text(statement2, 1)];
                        NSString * last_name = [[NSString alloc] initWithUTF8String: (char *) sqlite3_column_text(statement2, 2)];
                        sqlite3_stmt * statement3;
                        NSString *querySQL3 = [NSString stringWithFormat:@"SELECT phone_number FROM phone , person WHERE person.pid = \"%d\"  and phone.pid = person.pid ", pid];
                        const char *query_statement3 = [querySQL3 UTF8String];
                        
                        NSMutableArray * phones = [[NSMutableArray alloc]init];
                        if(sqlite3_prepare_v2(_DB, query_statement3, -1, &statement3, NULL) == SQLITE_OK){
                            while(sqlite3_step(statement3)==SQLITE_ROW){
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
                
                //NSLog(@"Match %d found in database",event_id);
                
                sqlite3_finalize(statement2);
            }else{
                NSLog(@"Match not found in databse");
            }
            sqlite3_finalize(statement);
        }
        else{
            NSLog(@"Failed to search the database");
        }
        sqlite3_close(_DB);
    }
    return ma;
    
}


-(NSArray * ) selectEventById:(int) event_id{
    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String];
    
    NSMutableArray * ma = [[NSMutableArray alloc] init];
    
    if(sqlite3_open(dbpath, &_DB) == SQLITE_OK){
        NSString *querySQL = [NSString stringWithFormat:@"SELECT id, title, time FROM events WHERE id = \"%d\"", event_id];
        const char *query_statement = [querySQL UTF8String];
        if(sqlite3_prepare_v2(_DB, query_statement, -1, &statement, NULL) == SQLITE_OK){
            if(sqlite3_step(statement) == SQLITE_ROW){
                
                sqlite3_stmt *statement2;
                NSString *querySQL2 = [NSString stringWithFormat:@"SELECT pid, first_name , last_name FROM person natural join eid_pid WHERE eid = \"%d\" ", event_id];
                
                //NSLog(@"%@",querySQL2);
                const char *query_statement2 = [querySQL2 UTF8String];
                if(sqlite3_prepare_v2(_DB, query_statement2, -1, &statement2, NULL) == SQLITE_OK){
                    while(sqlite3_step(statement2)==SQLITE_ROW){
                        int pid = sqlite3_column_int(statement2,0);
                       // NSLog(@"found person with pid %d",pid);
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
                
                //NSLog(@"Match %d found in database",event_id);
                
                sqlite3_finalize(statement2);
            }else{
                NSLog(@"Match not found in databse");
            }
            sqlite3_finalize(statement);
        }else{
            NSLog(@"Failed to search the database");
        }
        sqlite3_close(_DB);
    }
    return ma;

}
-(NSArray *) selectAllDueEvent{
    //NSLog(@"select all events");
    NSMutableArray *returnData = [NSMutableArray new];
    NSString * currentTime = [[DateHelper getFormatter] stringFromDate:[NSDate date]];
    
    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String];
    if(sqlite3_open(dbpath, &_DB) == SQLITE_OK){
        NSString *querySQL = [NSString stringWithFormat:@"SELECT id, title, time FROM events where time < \"%@\" sorder by time asc",currentTime];
        const char *query_statement = [querySQL UTF8String];
        
        if(sqlite3_prepare_v2(_DB, query_statement, -1, &statement, NULL) == SQLITE_OK){
            while (sqlite3_step(statement) == SQLITE_ROW) {
                EventModel *event = [[EventModel alloc] init];
                event.ID = sqlite3_column_int(statement, 0);
                char *title = (char *) sqlite3_column_text(statement, 1);
                char *time = (char *) sqlite3_column_text(statement, 2);
                event.title = [[NSString alloc] initWithUTF8String:title];
                event.alarmTime = [[DateHelper getFormatter] dateFromString:[[NSString alloc] initWithUTF8String:time]];
                [returnData addObject:event];
            }
            sqlite3_finalize(statement);
        }else{
            NSLog(@"Failed to search the database %s",sqlite3_errmsg(_DB));
        }
        sqlite3_close(_DB);
    }
    //NSLog(@"%@", returnData);
    return returnData;
}

-(NSArray *) selectAllEvent{
    //NSLog(@"select all events");
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
                event.title = [[NSString alloc] initWithUTF8String:title];
                event.alarmTime = [[DateHelper getFormatter] dateFromString:[[NSString alloc] initWithUTF8String:time]];
                [returnData addObject:event];
            }
            sqlite3_finalize(statement);
        }else{
            NSLog(@"Failed to search the database %s",sqlite3_errmsg(_DB));
        }
        sqlite3_close(_DB);
    }
    //NSLog(@"%@", returnData);
    return returnData;
}

-(void) removeEventById: (int) event_id{
    NSString *delete_event_SQL = [NSString stringWithFormat:@"DELETE FROM events WHERE id = \"%d\"", event_id];
    [self executeSQLStatement:delete_event_SQL];
    NSString * delete_eid_pid_SQL = [NSString stringWithFormat:@"Delete from eid_pid where eid = \"%d\"",event_id];
    [self executeSQLStatement:delete_eid_pid_SQL];
    
}
-(void) removeEvent:(int)event_id{
    const char *dbpath = [_databasePath UTF8String];
    char *errorMessage;
    
    if(sqlite3_open(dbpath, &_DB) == SQLITE_OK){
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM events WHERE id = \"%d\"", event_id];
        const char *query_statement = [querySQL UTF8String];
        if(sqlite3_exec(_DB, query_statement, NULL, NULL, &errorMessage) == SQLITE_OK){
            NSLog(@"Deleted %d from database",event_id);
        }else{
            NSLog(@"Failed to delete from database");
        }
    }else{
        NSLog(@"Failed to delete from database");
        sqlite3_close(_DB);
    }
}


-(void) updateExistingEvent:(EventModel *)event withContacts:(NSMutableDictionary *)contacts{
    //NSLog(@"update existing events");
    NSString *updateSQL = [NSString stringWithFormat:@"Update events set title = \"%@\", time =\"%@\" where id =\"%d\" ",event.title, [[DateHelper getFormatter]stringFromDate:event.alarmTime] ,event.ID];
   
    [self executeSQLStatement:updateSQL];
    
    NSString * delete_eid_pid_SQL = [NSString stringWithFormat:@"delete from eid_pid where eid = \"%d\" ",event.ID ];
    
    [self executeSQLStatement:delete_eid_pid_SQL];
    
    for (id key in contacts){
        Person * p = [contacts objectForKey:key];
        int pid = (int) key;
        NSString * insertPersonSQL = [NSString stringWithFormat: @"INSERT or IGNORE INTO person (pid, first_name, last_name) values (\"%d\",\"%@\",\"%@\")", pid, p.firstName, p.lastName];
        [self executeSQLStatement:insertPersonSQL];
        for(NSString * numbers in p.phoneNumbers){
            NSString * insertPhoneSQL = [NSString stringWithFormat:@"INSERT or IGNORE INTO phone (pid, phone_number ) values (\"%d\",\"%@\")" , pid,numbers];
            [self executeSQLStatement:insertPhoneSQL];
        }
        NSString * insertEidPidSQL = [NSString stringWithFormat:@"INSERT or IGNORE INTO eid_pid (eid,pid) values(\"%d\",\"%d\")",event.ID,pid];
        [self executeSQLStatement:insertEidPidSQL];
    }
    //NSLog(@"Update Succeed");
}



@end


