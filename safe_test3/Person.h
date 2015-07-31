//
//  Person.h
//  safe_test3
//
//  Created by bbiiggppiigg on 2015/7/29.
//  Copyright (c) 2015年 bbiiggppiigg. All rights reserved.
//

@interface Person : NSObject <NSCopying>
@property NSString *firstName;
@property NSString *lastName;
@property NSArray * phoneNumbers;
@property int  pid;
-(id) initWithFirstName : (NSString *) fname withLastName : (NSString *) lname withPhoneNumbers : (NSMutableArray * ) parray;
-(id) initWithPid : (int) pid withFirstName : (NSString *) fname withLastName : (NSString *) lname withPhoneNumbers : (NSMutableArray * ) parray;

-(void) printStatus;
-(NSString *) getName;
-(id) copyWithZone: (NSZone *) zone;
@end
