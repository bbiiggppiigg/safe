//
//  Person.m
//  safe_test3
//
//  Created by bbiiggppiigg on 2015/7/29.
//  Copyright (c) 2015年 bbiiggppiigg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"

@implementation Person : NSObject 
-(id) copyWithZone: (NSZone *) zone
{
    Person *obj = [[[self class] alloc] init];
    obj.firstName = self.firstName;
    obj.lastName = self.lastName;
    obj.phoneNumbers = [[NSMutableArray alloc] initWithArray : self.phoneNumbers ];
    return obj;
}

-(id) initWithFirstName:(NSString *)fname withLastName:(NSString *)lname withPhoneNumbers:(NSMutableArray *)parray{
    self.firstName = [fname copy];
    self.lastName = [lname copy];
    self.phoneNumbers = [parray copy];
    self.pid = -1;
    return self;
}
-(void) printStatus{

}
-(NSString * ) getName{
    NSLog(@"%@ %@",self.firstName,self.lastName);
    return [NSString stringWithFormat:@"%@ %@",self.firstName,self.lastName];
}
-(id) initWithPid :(int) pid withFirstName : (NSString *) fname withLastName : (NSString *) lname withPhoneNumbers : (NSMutableArray * ) parray{
    self.firstName = [fname copy];
    self.lastName = [lname copy];
    self.phoneNumbers = [parray copy];
    self.pid = pid;
    return self;
}

@end