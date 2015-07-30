//
//  Database.h
//  safe_test3
//
//  Created by Man-Chun Hsieh on 7/29/15.
//  Copyright (c) 2015 bbiiggppiigg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface Database : NSObject {
}
+(NSString* )getDatabasePath;
+(NSMutableArray *)executeQuery:(NSString*)str;
+(NSString*)encodedString:(const unsigned char *)ch;
+(BOOL)executeScalarQuery:(NSString*)str;
@end
