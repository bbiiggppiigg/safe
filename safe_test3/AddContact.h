//
//  AddContact.h
//  safe_test3
//
//  Created by bbiiggppiigg on 2015/7/29.
//  Copyright (c) 2015年 bbiiggppiigg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>


@interface AddContact : UITableViewController <ABPeoplePickerNavigationControllerDelegate>
@property (nonatomic,strong) ABPeoplePickerNavigationController * addressBookController;
@property (nonatomic,strong) NSMutableArray * arrContactsData;
@property NSMutableDictionary * _objects;
@property NSMutableArray * _objects2;
@property NSMutableArray * _objects3;
-(void) showAddressBook;
@end
