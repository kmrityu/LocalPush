//
//  AppDelegate.m
//  LocalPush
//
//  Created by Mritunjay Kumar on 26/11/12.
//  Copyright (c) 2012 Mritunjay Kumar. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"
//#import "ToDoItem.h"
@implementation AppDelegate

#define ToDoItemKey @"eventkey"
#define MessageTitleKey @"MessageKey"

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    /*
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController" bundle:nil] autorelease];
    self.window.rootViewController = self.viewController;
    */
    
    
    
    UILocalNotification *localNotif = [launchOptions
                                       objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    
    if (localNotif) {
        NSString *itemName = [localNotif.userInfo objectForKey:ToDoItemKey];
        // [viewController displayItem:itemName]; // custom method
        application.applicationIconBadgeNumber = localNotif.applicationIconBadgeNumber-1;
        NSLog(@"has localNotif %@",itemName);
    }
    else {
        
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        NSDate *now = [NSDate date];
        NSLog(@"now is %@",now);
        NSDate *scheduled = [now dateByAddingTimeInterval:120] ; //get x minute after
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        unsigned int unitFlags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit;
        
        NSDateComponents *comp = [calendar components:unitFlags fromDate:scheduled];
        
        NSLog(@"scheduled is %@",scheduled);
        
        ToDoItem *todoitem = [[ToDoItem alloc] init];
        
        todoitem.day = [comp day];
        todoitem.month = [comp month];
        todoitem.year = [comp year];
        todoitem.hour = [comp hour];
        todoitem.minute = [comp minute];
        todoitem.eventName = @"Testing Event";
        
        [self scheduleNotificationWithItem:todoitem interval:1];
        [todoitem release];
        NSLog(@"scheduleNotificationWithItem");
    }
    
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notif {
    
    
    NSLog(@"application: didReceiveLocalNotification:");
    
    NSString *itemName = [notif.userInfo objectForKey:ToDoItemKey];
    NSString *messageTitle = [notif.userInfo objectForKey:MessageTitleKey];
    
    // [viewController displayItem:itemName]; // custom method
    [self _showAlert:itemName withTitle:messageTitle];
    NSLog(@"Receive Local Notification while the app is still running...");
    NSLog(@"current notification is %@",notif);
    application.applicationIconBadgeNumber = notif.applicationIconBadgeNumber-1;
    
    
}

- (void) _showAlert:(NSString*)pushmessage withTitle:(NSString*)title
{
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:pushmessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    if (alertView) {
        [alertView release];
    }
}


- (void)scheduleNotificationWithItem:(ToDoItem *)item interval:(int)minutesBefore {
    
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    [dateComps setDay:item.day];
    [dateComps setMonth:item.month];
    [dateComps setYear:item.year];
    [dateComps setHour:item.hour];
    [dateComps setMinute:item.minute];
    NSDate *itemDate = [calendar dateFromComponents:dateComps];
    [dateComps release];
    
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    localNotif.fireDate = [itemDate dateByAddingTimeInterval:-(minutesBefore*60)];
    NSLog(@"fireDate is %@",localNotif.fireDate);
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    localNotif.alertBody = [NSString stringWithFormat:NSLocalizedString(@"%@ in %i minutes.", nil),
                            item.eventName, minutesBefore];
    localNotif.alertAction = NSLocalizedString(@"View Details", nil);
    
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = 1;
    // NSDictionary *infoDict = [NSDictionary dictionaryWithObject:item.eventName forKey:ToDoItemKey];
    NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:item.eventName,ToDoItemKey, @"Local Push received while running", MessageTitleKey, nil];
    localNotif.userInfo = infoDict;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    NSLog(@"scheduledLocalNotifications are %@", [[UIApplication sharedApplication] scheduledLocalNotifications]);
    [localNotif release];
}

- (NSString *) checkForIncomingChat {
    
    return @"javacom";
};

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    
    NSLog(@"Application entered background state.");
    // UIBackgroundTaskIdentifier bgTask is instance variable
    // UIInvalidBackgroundTask has been renamed to UIBackgroundTaskInvalid
    NSAssert(self->bgTask == UIBackgroundTaskInvalid, nil);
    
    bgTask = [application beginBackgroundTaskWithExpirationHandler: ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [application endBackgroundTask:self->bgTask];
            self->bgTask = UIBackgroundTaskInvalid;
        });
        
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        while ([application backgroundTimeRemaining] > 1.0) {
            NSString *friend = [self checkForIncomingChat];
            if (friend) {
                UILocalNotification *localNotif = [[UILocalNotification alloc] init];
                if (localNotif) {
                    localNotif.alertBody = [NSString stringWithFormat:
                                            NSLocalizedString(@"%@ has a message for you.", nil), friend];
                    localNotif.alertAction = NSLocalizedString(@"Read Msg", nil);
                    localNotif.soundName = @"alarmsound.caf";
                    localNotif.applicationIconBadgeNumber = 1;
                    NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Your Background Task works",ToDoItemKey, @"Message from javacom", MessageTitleKey, nil];
                    localNotif.userInfo = infoDict;
                    [application presentLocalNotificationNow:localNotif];
                    [localNotif release];
                    friend = nil;
                    break;
                }
            }
        }
        [application endBackgroundTask:self->bgTask];
        self->bgTask = UIBackgroundTaskInvalid;
    });
    
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
