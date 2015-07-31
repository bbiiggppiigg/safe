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
#import "EventList.h"
#import "Person.h"

@interface AddEvent()


@property (strong, nonatomic) IBOutlet UITextField *event_title;
@property (strong, nonatomic) IBOutlet UITextField *date;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *freq;


@end


@implementation AddEvent
-(id) initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    NSLog(@"Add Event Init Decoder");
    self.contacts = [[NSMutableDictionary alloc] init];
    return self;
}

-(id) init
{
    NSLog(@"Add Event Init");
    self = [super initWithNibName:@"EditView" bundle:nil];
    
    if(self != nil){
        NSLog(@"nice");
    }
    return self;
}
-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    NSLog(@"Add Event Init");
    
    if (self = [super initWithNibName:@"MyNibName" bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return nil;
}
-(void) viewDidLoad{
    
    [super viewDidLoad];
    NSLog(@"view did load ");
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,320,44)];
    UIBarButtonItem * doneBtn = [[UIBarButtonItem alloc]  initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(ShowSelectedDate) ];
    UIBarButtonItem * space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolBar setItems: [NSArray arrayWithObjects:space,doneBtn,nil]];
    
    datePicker = [[UIDatePicker alloc]init];
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    NSLocale *locale =  [[NSLocale alloc] initWithLocaleIdentifier:@"zh_TW"];;
    NSCalendar *cal = [NSCalendar currentCalendar];
    [cal setLocale:locale];
    [datePicker setCalendar:cal];
    
    
    [self.dateSelectionTextField setInputView:datePicker];
    [self.dateSelectionTextField setInputAccessoryView:toolBar];
    
    //SqlHelper *helper = [[SqlHelper alloc] init];
    //[helper createDB];
    [self.addContactTable addTarget:self action:@selector(transition) forControlEvents:UIControlEventTouchDown];
    
    if(_event == nil){
        NSLog(@"Initailzing new Event");
        _event = [[EventModel alloc] init];
        _event.title = @"";
        _event.alarmTime = [[NSDate alloc]init];
        _event.ID = -1;
    }
    
    
    [self.event_title addTarget:self action:@selector(textFieldsDidChange) forControlEvents:UIControlEventEditingDidEnd];
    [self.date addTarget:self action:@selector(textFieldsDidChange) forControlEvents:UIControlEventEditingDidEnd];
    _event_title.text =_event.title;
   
    _dateSelectionTextField.text = [[self getFormatter] stringFromDate:_event.alarmTime] ;
    if(_contacts ==nil){
        NSLog(@"Contacts nil!!! WHY!!!!");
        
    }
    [self textFieldsDidChange];
}

-(void) textFieldsDidChange{
   self.navigationItem.rightBarButtonItem.enabled = YES;
    if([self.event_title.text isEqualToString:@""]){
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    if([self.date.text isEqualToString:@""])
    {
         self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    if([self.contacts count] ==0){
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}
-(void) transition{
    NSLog(@"Onclick");
    AddContact * ac = [[AddContact alloc] initWithContacts:self.contacts];
    ac.delegate = self;
    [self.navigationController pushViewController:ac animated:YES];
}

-(void) childViewController:(AddContact *)viewController updateContacts:(NSMutableDictionary *)contacts{
    NSLog(@"Test Delegate");
    self.contacts = contacts;
    [self textFieldsDidChange];
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSDateFormatter * ) getFormatter{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm"];
    [format setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC+8"]];
    return format;
}

-(void) ShowSelectedDate{
    self.dateSelectionTextField.text = [[self getFormatter] stringFromDate:datePicker.date];
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


-(IBAction) onSaveEvent:(UIBarButtonItem *)sender{
    _event.title=self.event_title.text;
    _event.alarmTime = [[self getFormatter] dateFromString:self.date.text];
    SqlHelper *helper = [[SqlHelper alloc] init];
    [helper createDB];
    if(_event.ID == -1)
        [helper insertEvent:_event withContacts: self.contacts];
    [self.delegate EventListViewController: self];
}
-(void) setExistingEvent:(EventModel *) previous_event withContacts : (NSArray *) previous_contacts{
    _event = previous_event;
    for (Person * p in previous_contacts){
        [_contacts setObject:p forKey: [NSNumber numberWithInt: p.pid ]];
    }
    
    NSLog(@"Before Setting %@ with %@",_event_title.text,_event.title);
    _event_title.text =_event.title;
    NSLog(@"After Setting %@ with %@",_event_title.text,_event.title);
    _dateSelectionTextField.text = [[self getFormatter] stringFromDate:_event.alarmTime] ;
    
    
    NSLog(@"Reloading ");
}
@end
