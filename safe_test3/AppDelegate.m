//
//  AppDelegate.m
//  safe_test3
//
//  Created by bbiiggppiigg on 2015/7/28.
//  Copyright (c) 2015年 bbiiggppiigg. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import "Person.h"
#import "EventModel.h"
#import "SqlHelper.h"
#import "EventList.h"
#import "DateHelper.h"


@interface AppDelegate () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) SqlHelper *sqlhelper;
@end


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.sqlhelper = [[SqlHelper alloc] init];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
    
    return YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *location = [locations lastObject];
    [self.sqlhelper createDB];
    NSArray *array = [self.sqlhelper selectAllEvent];
    for (EventModel *item in array) {
        NSLog(@"%@, alarm:%@",[NSDate date],item.alarmTime);
        
        if ([[NSDate date] compare:item.alarmTime] == NSOrderedDescending) {
            [manager stopUpdatingLocation];
            NSArray * arr = [self.sqlhelper selectEventByIdWithPhoneNumbers:item.ID];
            for (Person * p in arr){
                NSLog(@"Sending SMS to %@ %@:",p.firstName,p.lastName);
                NSArray * phones = p.phoneNumbers;
                for(NSString * phone in phones){
                    NSLog(@"\tSending SMS to phone number %@",phone);
                }
                NSLog(@"=========================");
            }
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://smsserviceapi.azurewebsites.net/SendSMS?to=886905303061&msg=Emily:latitude:%f,longitude:%f&key=abcde",location.coordinate.latitude,location.coordinate.longitude]];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
            [request setHTTPMethod:@"POST"];
            [[NSURLConnection alloc] initWithRequest:request delegate:self];
            [self.sqlhelper removeEvent:item.ID];

            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshView" object:nil];
        }
    }
    
    //[self.window.rootViewController loadView];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
