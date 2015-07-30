//
//  AddEvent.m
//  safe_test3
//
//  Created by bbiiggppiigg on 2015/7/29.
//  Copyright (c) 2015年 bbiiggppiigg. All rights reserved.
//

#import "AddEvent.h"
#import "Database.h"

#import "EventModel.h"
#import "SqlHelper.h"
#import "AddContact.h"
@interface AddEvent()

+ (sqlite3 *)database;
+ (void)setDatabase :(sqlite3 *)newDatabase;

@property (strong, nonatomic) IBOutlet UITextField *event_title;
@property (strong, nonatomic) IBOutlet UITextField *date;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *freq;


@end


@implementation AddEvent


-(void) viewDidLoad{
    
    [super viewDidLoad];
    NSLog(@"view did load ");
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,320,44)];
    UIBarButtonItem * doneBtn = [[UIBarButtonItem alloc]  initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(ShowSelectedDate) ];
    UIBarButtonItem * space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolBar setItems: [NSArray arrayWithObjects:space,doneBtn,nil]];
    
    datePicker = [[UIDatePicker alloc]init];
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    [self.dateSelectionTextField setInputView:datePicker];
    [self.dateSelectionTextField setInputAccessoryView:toolBar];
    
    SqlHelper *helper = [[SqlHelper alloc] init];
    [helper createDB];
    [self.addContactTable addTarget:self action:@selector(transition) forControlEvents:UIControlEventTouchDown];
    
    self.eventTitle = @"";
    self.eventTime = [[NSDate alloc]init];
    self.phoneNumbers = [[NSMutableDictionary alloc]init];
    self.updateFrequency = 0;
}

-(void) transition{
    NSLog(@"Onclick");
    AddContact * ac = [[AddContact alloc] initWithContacts:self.phoneNumbers];
    ac.delegate = self;
    [self.navigationController pushViewController:ac animated:YES];
}

-(void) childViewController:(AddContact *)viewController updatePhoneNumbers:(NSMutableDictionary *)phones{
    NSLog(@"Test Delegate");
    self.phoneNumbers = phones;
    [self.navigationController popViewControllerAnimated:YES];
}
-(void) ShowSelectedDate{
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY/MMM/dd hh:mm"];
    self.dateSelectionTextField.text =[NSString stringWithFormat:@"%@", [formatter stringFromDate: datePicker.date ] ];
    [self.dateSelectionTextField resignFirstResponder];
    self.eventTime = datePicker.date;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [super tableView:tableView numberOfRowsInSection : (section)];
}
-(UITableViewCell *) tableView : (UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
}


-(void) showUIAlertWithMessage:(NSString*)message andTitle:(NSString*)title{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
}

- (IBAction)onFindBtn:(UIButton *)sender {

    // delete example
//    SqlHelper *helper =[[SqlHelper alloc] init];
//    [helper createDB];
//    [helper removeEvent:6];
    
    // select example
//    SqlHelper *helper =[[SqlHelper alloc] init];
//    [helper createDB];
//    EventModel *event = [helper selectEvent:1];
//    NSLog(@"%@", event.title);
    
    // select all example
//    SqlHelper *helper = [[SqlHelper alloc] init];
//    [helper createDB];
//    [helper selectAllEvent];
}

- (IBAction)onButntest:(UIButton *)sender {

    // insert example
    EventModel *event = [[EventModel alloc]init];
    event.title=self.event_title.text;
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy/MM/dd hh:mm"];
    [format setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8]];
    event.alarmTime = [format dateFromString:self.date.text];

    SqlHelper *helper = [[SqlHelper alloc] init];
    [helper createDB];
    [helper insertEvent:event];
    
}



@end
