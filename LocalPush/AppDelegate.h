//
//  AppDelegate.h
//  LocalPush
//
//  Created by Mritunjay Kumar on 26/11/12.
//  Copyright (c) 2012 Mritunjay Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ToDoItem.h"
@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    
    UIBackgroundTaskIdentifier  bgTask;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

- (void)scheduleNotificationWithItem:(ToDoItem *)item interval:(int)minutesBefore;
- (void) _showAlert:(NSString*)pushmessage withTitle:(NSString*)title;
@end
