//
//  EventList.m
//  safe_test3
//
//  Created by bbiiggppiigg on 2015/7/30.
//  Copyright (c) 2015年 bbiiggppiigg. All rights reserved.
//

#import "EventList.h"
#import "SqlHelper.h"
#import "Person.h"

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

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    EventModel * em = [self.eventList objectAtIndex:indexPath.row];
    NSLog(@"%d",em.ID);
    
    SqlHelper * helper = [[SqlHelper alloc] init];
    [helper createDB];
    NSArray * na = [helper selectEventById:(int)em.ID];
    NSLog(@"%lu",(unsigned long)[na count]);
    for (Person * p  in na){
        [p getName];
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    AddEvent * ae = [storyboard instantiateViewControllerWithIdentifier:@"EditEvent"];
    ae.event = em;
    
    for (Person * p in na){
        [ae.contacts setObject:p forKey: [NSNumber numberWithInt: p.pid ]];
    }
    NSLog(@"Num of coutacts %lu",(unsigned long)[ae.contacts count]);
    ae.delegate = self;
    [self.navigationController pushViewController:ae animated:YES];
}
@end
