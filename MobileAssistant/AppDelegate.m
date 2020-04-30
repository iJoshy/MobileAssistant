//
//  AppDelegate.m
//  MobileAssistant
//
//  Created by Joshua Balogun on 11/26/14.
//  Copyright (c) 2014 Etisalat. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:87.0/255.0 green:127.0/255.0 blue:24.0/255.0 alpha:1]];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    }
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent]; 
    
    NSDictionary *attributes = @{ NSFontAttributeName: [UIFont fontWithName:@"NeoTechAlt" size:18],
                                  NSForegroundColorAttributeName: [UIColor whiteColor]};
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];
    
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        UIPageControl *pageControl = [UIPageControl appearance];
        pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:87.0/255.0 green:127.0/255.0 blue:24.0/255.0 alpha:1];
        pageControl.backgroundColor = [UIColor clearColor];
        
        [[UITextField appearance] setTintColor:[UIColor colorWithRed:87.0/255.0 green:127.0/255.0 blue:24.0/255.0 alpha:1]];
    }    
    
    // Override point for customization after application launch.
    return YES;
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
    
    NSString *screen = [[NSUserDefaults standardUserDefaults] stringForKey:@"SCREEN"];
    if ([screen intValue] == 1)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RELOADSPLASH" object:nil userInfo:nil];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
