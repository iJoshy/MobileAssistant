//
//  SetupViewController.h
//  MobileAssistant
//
//  Created by Joshua Balogun on 11/26/14.
//  Copyright (c) 2014 Etisalat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKYStepper.h"
#import "AMSmoothAlertView.h"
#import "AMSmoothAlertConstants.h"

#define kFilename @"mobileassistantAPP.sqlite3"

@class RadioButton;

@interface SetupViewController : UIViewController <UITextFieldDelegate>
{
    UITextField *mobileAssistantText;
    
    int animatedDis;
    int dismisskeypad;
}

@property (nonatomic, strong) IBOutlet UITextField *mobileAssistantText;
@property (nonatomic, strong) IBOutlet UITextField *legendText1;
@property (nonatomic, strong) IBOutlet UITextField *legendText2;
@property (nonatomic, strong) IBOutlet UITextField *legendText3;
@property (nonatomic, strong) IBOutlet UILabel *timelabel;
@property (nonatomic, strong) IBOutlet RadioButton* radioButton;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;

@property (nonatomic, strong) NSDictionary *jsonResponse;
@property (nonatomic, strong) PKYStepper *plainStepper;
@property (nonatomic, strong) NSString *mobile;
@property (nonatomic, strong) NSString *asstType;
@property (nonatomic, strong) NSString *asstTime;
@property (nonatomic, strong) NSString *enableDisabled;

-(IBAction)onRadioBtn:(id)sender;
-(IBAction) sendTap:(id)sender;
-(IBAction) settingsTap:(id)sender;
-(IBAction) backgroundTap:(id)sender;
- (NSString *)dataFilePath;

@end