//
//  AddContact.m
//  safe_test3
//
//  Created by bbiiggppiigg on 2015/7/29.
//  Copyright (c) 2015年 bbiiggppiigg. All rights reserved.
//

#import "AddContact.h"
#import "Person.h"

@implementation AddContact
-(AddContact * ) initWithContacts:(NSMutableDictionary *)initialContacts{
    self._objects =[[NSMutableDictionary alloc] initWithDictionary:initialContacts];
    self._objects2 = [NSMutableArray arrayWithArray:[self._objects allValues]];
    self._objects3 =[ NSMutableArray arrayWithArray:[self._objects allKeys]];
    return self;
}
-(void) viewDidLoad{
    [super viewDidLoad];
    //self.navigationItem.leftBarButtonItem = self.;
    UIBarButtonItem * addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showAddressBook)];
    self.navigationItem.rightBarButtonItem = addButton;
    UIBarButtonItem * saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveContacts)];
    self.navigationItem.leftBarButtonItem = saveButton;
    if(self._objects ==nil){
        self._objects = [[NSMutableDictionary alloc] init];
        self._objects2 = [[NSMutableArray alloc] init];
        self._objects3 = [[NSMutableArray alloc] init];
    }
    
    self.navigationItem.title = @"Contact Lists";
}
-(void) saveContacts{
    [self.delegate childViewController:self updateContacts:self._objects];
}
- (void)listPeopleInAddressBook:(ABAddressBookRef)addressBook
{
    NSArray *allPeople = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
    NSInteger numberOfPeople = [allPeople count];
    
    for (NSInteger i = 0; i < numberOfPeople; i++) {
        ABRecordRef person = (__bridge ABRecordRef)allPeople[i];
        
        NSString *firstName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *lastName  = CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
        NSLog(@"Name:%@ %@", firstName, lastName);
        
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        
        CFIndex numberOfPhoneNumbers = ABMultiValueGetCount(phoneNumbers);
        
        //NSMutableArray * parray = [[NSMutableArray alloc]init];
        for (CFIndex i = 0; i < numberOfPhoneNumbers; i++) {
            NSString *phoneNumber = CFBridgingRelease(ABMultiValueCopyValueAtIndex(phoneNumbers, i));
            NSLog(@"  phone:%@", phoneNumber);
        //    [parray addObject: phoneNumber];
        }
        //[_objects addObject: [[Person alloc] initWithFirstName:firstName withLastName:lastName withPhoneNumbers:parray]];
        
        CFRelease(phoneNumbers);
        
        NSLog(@"=============================================");
    }
}
-(void) peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    [_addressBookController dismissViewControllerAnimated:YES completion:nil];
}

-(void) showAddressBook{
    _addressBookController = [[ABPeoplePickerNavigationController alloc] init];
    [_addressBookController setPeoplePickerDelegate:self];
    [self presentViewController:_addressBookController animated: YES completion:nil];
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    
    if (status == kABAuthorizationStatusDenied || status == kABAuthorizationStatusRestricted) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"This app requires access to your contacts to function properly. Please visit to the \"Privacy\" section in the iPhone Settings app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    if (!addressBook) {
        NSLog(@"ABAddressBookCreateWithOptions error: %@", CFBridgingRelease(error));
        return;
    }
    
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        if (error) {
            NSLog(@"ABAddressBookRequestAccessWithCompletion error: %@", CFBridgingRelease(error));
        }
        
        if (granted) {
            puts("Permission Granted");
            
            //[self listPeopleInAddressBook :addressBook];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:nil message:@"This app requires access to your contacts to function properly. Please visit to the \"Privacy\" section in the iPhone Settings app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            });
        }
        CFRelease(addressBook);
    });
}

-(void) peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person{
    puts("TouchedB");
    NSLog(@"%@" , person);
    NSString *firstName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
    NSString *lastName  = CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
    NSLog(@"Name:%@ %@", firstName, lastName);
    
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
    
    CFIndex numberOfPhoneNumbers = ABMultiValueGetCount(phoneNumbers);
    
    NSMutableArray * parray = [[NSMutableArray alloc]init];
    for (CFIndex i = 0; i < numberOfPhoneNumbers; i++) {
        NSString *phoneNumber = CFBridgingRelease(ABMultiValueCopyValueAtIndex(phoneNumbers, i));
        NSLog(@"  phone:%@", phoneNumber);
            [parray addObject: phoneNumber];
    }
    
    Person * p  =  [[Person alloc] initWithPid: (int)ABRecordGetRecordID(person)  withFirstName:firstName withLastName:lastName withPhoneNumbers:parray];
    
    ABRecordID abid = ABRecordGetRecordID(person);
    NSNumber * rec = [NSNumber numberWithInt: (int) (abid) ];
    [self._objects setObject:p forKey:rec ];
    self._objects2 = [NSMutableArray arrayWithArray:[self._objects allValues]];
    self._objects3 =[ NSMutableArray arrayWithArray:[self._objects allKeys]];
    [self.tableView reloadData];
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self._objects count];
}
-(UITableViewCell *) tableView : (UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    static NSString * AddContactTableIdentifier = @"AddContactItem";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:AddContactTableIdentifier];
    if(cell==nil){
         cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AddContactTableIdentifier];
    }
    
    cell.textLabel.text = [[self._objects2 objectAtIndex:indexPath.row] getName];
    //printf("%lu\n",(unsigned long)[self._objects count]);
    return cell;
    
}
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self._objects removeObjectForKey: [self._objects3  objectAtIndex:indexPath.row]];
    self._objects2 = [NSMutableArray arrayWithArray:[self._objects allValues]];
    self._objects3 =[ NSMutableArray arrayWithArray:[self._objects allKeys]];
    [self.tableView reloadData];
}
@end
