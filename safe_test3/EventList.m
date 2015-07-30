//
//  EventList.m
//  safe_test3
//
//  Created by bbiiggppiigg on 2015/7/30.
//  Copyright (c) 2015年 bbiiggppiigg. All rights reserved.
//

#import "EventList.h"
#import "SqlHelper.h"

@implementation EventList

-(void) viewDidLoad{
    [self loadData];
    self.navigationItem.hidesBackButton = YES;
    
}
-(void) loadData{
    self.eventList = [[NSMutableArray alloc] init];
    SqlHelper * helper = [[SqlHelper alloc] init];
    [helper createDB];
    [self.eventList addObjectsFromArray:[helper selectAllEvent]];
}
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"addEventSegue"]){
        AddEvent * ae = segue.destinationViewController;
        ae.delegate = self;
        NSLog(@"Set Delegate Success");
    }
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.eventList count];
}
-(UITableViewCell *) tableView : (UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [[UITableViewCell alloc]init];

   EventModel * em = [self.eventList objectAtIndex:indexPath.row];
    static NSString * AddContactTableIdentifier = @"AddContactItem";
    if(cell==nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AddContactTableIdentifier];
    }
    cell.textLabel.text = em.title;
    return cell;
    
}
-(void) EventListViewController:(AddEvent *)viewController{
    //NSLog(@"Data Reloaaded");
    [self loadData];
    [self.tableView reloadData];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
