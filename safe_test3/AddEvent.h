//
//  AddEvent.h
//  safe_test3
//
//  Created by bbiiggppiigg on 2015/7/29.
//  Copyright (c) 2015年 bbiiggppiigg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "AddContact.h"
#import "EventModel.h"


@protocol AddEventDelegate;

@interface AddEvent : UITableViewController <UITableViewDelegate,AddContactDelegate>
{

    UIDatePicker * datePicker;
}
@property (weak, nonatomic) IBOutlet UITextField * dateSelectionTextField;
@property (weak, nonatomic) IBOutlet UIButton *addContactTable;
@property NSString * eventTitle;
@property NSDate * eventTime;
@property NSMutableDictionary * contacts;
@property NSInteger * updateFrequency;
@property (nonatomic,weak) id<AddEventDelegate> delegate;
@property EventModel * event;
-(void) setExistingEvent:(EventModel *) previous_event withContacts : (NSArray *) previous_contacts;


@end

@protocol AddEventDelegate <NSObject>
-(void)EventListViewController: (AddEvent * ) viewController;
@end
