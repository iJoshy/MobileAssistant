//
//  SplashViewController.h
//  MobileAssistant
//
//  Created by Joshua Balogun on 11/26/14.
//  Copyright (c) 2014 Etisalat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMSmoothAlertView.h"
#import "AMSmoothAlertConstants.h"

#define kFilename @"mobileassistantAPP.sqlite3"

@interface SplashViewController : UIViewController
{
    int code;
}

@property (nonatomic, strong) NSDictionary *jsonResponse;
@property (nonatomic, strong) NSString *mobile;
@property (nonatomic, strong) NSString *asstMobile;
@property (nonatomic, strong) NSString *asstType;
@property (nonatomic, strong) NSString *asstTime;
@property (nonatomic, strong) NSString *enableDisabled;

- (NSString *)dataFilePath;

@end
