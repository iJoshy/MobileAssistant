//
//  SetupViewController.m
//  MobileAssistant
//
//  Created by Joshua Balogun on 11/26/14.
//  Copyright (c) 2014 Etisalat. All rights reserved.
//

#import "SetupViewController.h"
#import "RadioButton.h"
#import "SVProgressHUD.h"
#import "WebServiceCall.h"
#import <QuartzCore/QuartzCore.h>
#import <sqlite3.h>

#define DEVICE_HEIGHT [[UIScreen mainScreen] bounds].size.height

@implementation SetupViewController
{
    AMSmoothAlertView * alert;
}

@synthesize radioButton, sendButton, mobileAssistantText;
@synthesize legendText1, legendText2, legendText3, jsonResponse;
@synthesize mobile, asstType, timelabel, asstTime, enableDisabled;


- (NSString *)dataFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:kFilename];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    dismisskeypad = 0;
    
    [self setTitle:@"Setup"];
    
    [self onRadioBtn:radioButton];
    
    self.sendButton.layer.borderWidth = 1;
    self.sendButton.layer.cornerRadius = 4.0;
    self.sendButton.layer.masksToBounds = YES;
    [self.sendButton setAdjustsImageWhenHighlighted:NO];
    self.sendButton.layer.borderColor = [[UIColor colorWithRed:87/255.0 green:127/255.0 blue:24/255.0 alpha:1] CGColor];
    
    self.legendText1.layer.borderWidth = 1;
    self.legendText1.layer.cornerRadius = 4.0;
    self.legendText1.layer.masksToBounds = YES;
    self.legendText1.layer.borderColor = [[UIColor colorWithRed:87/255.0 green:127/255.0 blue:24/255.0 alpha:1] CGColor];
    
    self.legendText2.layer.borderWidth = 1;
    self.legendText2.layer.cornerRadius = 4.0;
    self.legendText2.layer.masksToBounds = YES;
    self.legendText2.layer.borderColor = [[UIColor colorWithRed:87/255.0 green:127/255.0 blue:24/255.0 alpha:1] CGColor];
    
    self.legendText3.layer.borderWidth = 1;
    self.legendText3.layer.cornerRadius = 4.0;
    self.legendText3.layer.masksToBounds = YES;
    self.legendText3.layer.borderColor = [[UIColor colorWithRed:87/255.0 green:127/255.0 blue:24/255.0 alpha:1] CGColor];
    
    
    self.mobileAssistantText.layer.borderWidth = 1;
    self.mobileAssistantText.layer.cornerRadius = 4.0;
    self.mobileAssistantText.layer.masksToBounds = YES;
    self.mobileAssistantText.layer.borderColor = [[UIColor colorWithRed:87/255.0 green:127/255.0 blue:24/255.0 alpha:1] CGColor];
    
    
    UIBarButtonItem *leftbutton =  [[UIBarButtonItem alloc] initWithTitle:@"Subscribe" style:UIBarButtonItemStyleBordered target:self action:@selector(subscribeClicked)];
    [leftbutton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIColor whiteColor],NSForegroundColorAttributeName,[UIFont fontWithName:@"NeoTechAlt" size:13.0f],NSFontAttributeName,
                                        nil] forState:UIControlStateNormal];
    
    self.navigationItem.leftBarButtonItem = leftbutton;
    
    
    UIBarButtonItem *rightbutton =  [[UIBarButtonItem alloc] initWithTitle:@"Opt-out" style:UIBarButtonItemStyleBordered target:self action:@selector(optoutTapped)];
    [rightbutton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIColor whiteColor],NSForegroundColorAttributeName,[UIFont fontWithName:@"NeoTechAlt" size:13.0f],NSFontAttributeName,
                                         nil] forState:UIControlStateNormal];
    
    self.navigationItem.rightBarButtonItem = rightbutton;
    
    asstTime = @"10";
    enableDisabled = @"1";
    
    [[NSUserDefaults standardUserDefaults] setObject:@"3" forKey:@"SCREEN"];
    
}



- (IBAction)optoutTapped
{
    __weak SetupViewController *self_ = self;
    
    if (!alert || !alert.isDisplayed)
    {
        
        alert = [[AMSmoothAlertView alloc]initFadeAlertWithTitle:@"Notice" andText:@"This action will deactivate your Mobile Assistant subscription. Click ok to confirm." andCancelButton:YES forAlertType:AlertInfo];
        [alert setTitleFont:[UIFont fontWithName:@"NeoTechAlt-Medium" size:17.0f]];
        alert.completionBlock = ^void (AMSmoothAlertView *alertObj, UIButton *button)
        {
            if(button == alertObj.defaultButton)
            {
                NSLog(@"Default");
                [self_ gotoOptoutProcess];
            }
            else
            {
                NSLog(@"Others");
            }
        };
        
        alert.cornerRadius = 3.0f;
        [alert show];
    }
    else
    {
        [alert dismissAlertView];
    }
    
}


-(void)gotoOptoutProcess
{
    NSLog(@" :::: optout process call :::: ");
    
    [SVProgressHUD showWithStatus:@"Please wait ..."];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       WebServiceCall *ws = [[WebServiceCall alloc] init];
                       
                       NSDictionary *response = [ws unsubscribe];
                       
                       [self setJsonResponse:response];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [SVProgressHUD dismiss];
                           [self optOutAssistant];
                       });
                   });
    
    
}


-(void)optOutAssistant
{
    
    NSLog(@" reponse : %@",[self jsonResponse]);
    
    NSDictionary *response = [self jsonResponse];
    
    int code = [[response objectForKey:@"code"] intValue];
    NSString *description = [response objectForKey:@"description"];
    
    
    NSString *origin = [[NSUserDefaults standardUserDefaults] stringForKey:@"ORIGIN"];
    if([origin intValue] == 2)
    {
        code = 200;
        description = @"Successful";
        mobile = @"08099440449";
        asstType = @"402";
        asstTime = @"15";
        enableDisabled = @"1";
    }
    
    /*
     code = 200;
     mobile = @"08099440203";
     asstType = @"402";
     */
    
    NSLog(@" code : %d",code);
    NSLog(@" description : %@",description);
    
    if (code == 200)
    {
        [self deleteRecordDB];
    }
    else
    {
        NSString *msg = @"";
        
        if (code == 230)
            msg = @"Please ensure your device is connected to etisalat mobile data";
        else
            msg = @"Your request was not succesful. Please try again later";
        
        [self showError:msg];
        
    }
    
}



-(void)deleteRecordDB
{
    
    NSLog(@" ::: deleteing db  :::: ");
    
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK)
    {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    //NSLog(@"Database Created !");
    
    char *errorMsg;
    
    // Note that the continuation char on next line is not part of string...
    //create PDDB
    
    NSString *createSQL = @"DROP TABLE IF EXISTS USER;";
    if (sqlite3_exec (database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
    {
        sqlite3_close(database);
        NSAssert1(0, @"Error creating DB tables: %s", errorMsg);
    }
    
    sqlite3_close(database);
    
    [self showDeleteSucess];
    
}


- (void)showDeleteSucess
{
    
    NSLog(@" ::: delete alert  :::: ");
    
    __weak SetupViewController *self_ = self;
    
    alert = [[AMSmoothAlertView alloc]initDropAlertWithTitle:@"Notice" andText:@"You have been deactivated from the Mobile Assistant service." andCancelButton:NO forAlertType:AlertSuccess];
    [alert.defaultButton setTitle:@"OK" forState:UIControlStateNormal];
    [alert setTitleFont:[UIFont fontWithName:@"NeoTechAlt-Medium" size:17.0f]];
    alert.completionBlock = ^void (AMSmoothAlertView *alertObj, UIButton *button)
    {
        if(button == alertObj.defaultButton)
        {
            //NSLog(@"Default");
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"UNSUBSCRIBED"];
            [self_ unwindtoWalkthrough];
        }
        else
        {
            NSLog(@"Others");
        }
    };
    
    
    alert.cornerRadius = 3.0f;
    [alert show];
    
}


-(void) unwindtoWalkthrough
{
    NSLog(@" ::: delete unwinding  :::: ");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UNWINDFROMSETTINGS" object:nil userInfo:nil];
}



- (IBAction)subscribeClicked
{
    
    __weak SetupViewController *self_ = self;
    
    if (!alert || !alert.isDisplayed)
    {
        
        alert = [[AMSmoothAlertView alloc]initFadeAlertWithTitle:@"Notice" andText:@"You will be charged N750 for this service. Do you wish to continue?" andCancelButton:YES forAlertType:AlertInfo];
        [alert.defaultButton setTitle:@"ok" forState:UIControlStateNormal];
        [alert setTitleFont:[UIFont fontWithName:@"NeoTechAlt" size:17.0f]];
        alert.completionBlock = ^void (AMSmoothAlertView *alertObj, UIButton *button)
        {
            if(button == alertObj.defaultButton)
            {
                NSLog(@"Default");
                [self_ actionTaken];
            }
            else
            {
                NSLog(@"Others");
            }
        };
        
        
        alert.cornerRadius = 3.0f;
        [alert show];
    }
    else
    {
        [alert dismissAlertView];
    }
    
    
}


-(void)actionTaken
{
    [SVProgressHUD showWithStatus:@"Please wait ..."];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       WebServiceCall *ws = [[WebServiceCall alloc] init];
                       
                       NSDictionary *response = [ws subscribe];
                       
                       [self setJsonResponse:response];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [SVProgressHUD dismiss];
                           [self processSubscribe];
                       });
                   });
}


-(void)processSubscribe
{
    
    NSLog(@" reponse : %@",[self jsonResponse]);
    
    NSDictionary *response = [self jsonResponse];
    
    int code = [[response objectForKey:@"code"] intValue];
    NSString *description = [response objectForKey:@"description"];
    
    /*
     code = 200;
     mobile = @"08099440203";
     asstType = @"402";
     */
    
    NSLog(@" code : %d",code);
    NSLog(@" description : %@",description);
    
    //code = 200;
    
    if (code == 200)
    {
        [self showSubscribeSucess];
    }
    else
    {
        NSString *msg = @"";
        
        if (code == 230)
            msg = @"Please ensure your device is connected to etisalat mobile data";
        else
            msg = @"Your request was not succesful. Please try again later";
        
        [self showError:msg];
        
    }
    
}


- (IBAction)showSubscribeSucess
{
    //__weak SetupViewController *self_ = self;
    
    if (!alert || !alert.isDisplayed)
    {
        
        alert = [[AMSmoothAlertView alloc]initDropAlertWithTitle:@"Congratulations" andText:@"Your request is being processed please wait for a confirmation SMS thank you." andCancelButton:NO forAlertType:AlertSuccess];
        [alert.defaultButton setTitle:@"OK" forState:UIControlStateNormal];
        [alert setTitleFont:[UIFont fontWithName:@"NeoTechAlt-Medium" size:17.0f]];
        alert.completionBlock = ^void (AMSmoothAlertView *alertObj, UIButton *button)
        {
            if(button == alertObj.defaultButton)
            {
                NSLog(@"Default");
            }
            else
            {
                NSLog(@"Others");
            }
        };
        
        
        alert.cornerRadius = 3.0f;
        [alert show];
    }
    else
    {
        [alert dismissAlertView];
    }
    
}


-(IBAction)onRadioBtn:(RadioButton*)sender
{
    //NSLog(@"%@",[NSString stringWithFormat:@"Selected: %@", sender.titleLabel.text]);
    
    UIButton *clickedButton = (UIButton*)sender;

    asstType = [NSString stringWithFormat:@"%li", (long)clickedButton.tag];
    
    if ([asstType intValue] == 401)
    {
        [self setTimer];
    }
    else
    {
        
        timelabel.hidden = YES;
        
        UIView *v = [self.view viewWithTag:330];
        v.hidden = YES;
        [self.view bringSubviewToFront:v];
        [v removeFromSuperview];
        
        self.plainStepper = NULL;
    }
}


-(void) setTimer
{
    NSLog(@"Show and set timer dialog");
    
    if (! self.plainStepper)
    {
        UIAlertView *alert1 = [[UIAlertView alloc]initWithTitle:nil message:@"The default delay time is 10 seconds. Select your prefered delay time below" delegate:nil  cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert1 show];
        
        timelabel.hidden = NO;
        
        float width = 250.0f;
        float screenWidth = [UIScreen mainScreen].bounds.size.width;
        float x = (screenWidth - width) / 2.0;
        __weak SetupViewController *self_ = self;
        
        // plain
        self.plainStepper = [[PKYStepper alloc] initWithFrame:CGRectMake(x, 420, width, 36)];
        self.plainStepper.value = 10.0f;
        self.plainStepper.minimum = 10.0f;
        self.plainStepper.maximum = 60.0f;
        self.plainStepper.valueChangedCallback = ^(PKYStepper *stepper, float count) {
            self_.asstTime = [NSString stringWithFormat:@"%@", @(count)];
            stepper.countLabel.text = [NSString stringWithFormat:@"%@ : seconds", self_.asstTime];
        };
        [self.plainStepper setTag:330];
        [self.plainStepper setup];
        [self.view addSubview:self.plainStepper];
    }
    
}


-(IBAction) settingsTap:(id)sender
{
    NSLog(@"Setting");
}

-(IBAction) sendTap:(id)sender
{
    mobile = mobileAssistantText.text;
    
    if (mobile.length == 0)
    {
        
        //__weak SetupViewController *self_ = self;
        
        if (!alert || !alert.isDisplayed)
        {
            
            alert = [[AMSmoothAlertView alloc]initFadeAlertWithTitle:@"Sorry !" andText:@"Please enter your assistants mobile number to setup." andCancelButton:NO forAlertType:AlertFailure];
            [alert.defaultButton setTitle:@"OK" forState:UIControlStateNormal];
            [alert setTitleFont:[UIFont fontWithName:@"NeoTechAlt-Medium" size:17.0f]];
            alert.completionBlock = ^void (AMSmoothAlertView *alertObj, UIButton *button)
            {
                if(button == alertObj.defaultButton)
                {
                    //NSLog(@"Default");
                    //[self_ gotoHomeScreen];
                }
                else
                {
                    NSLog(@"Others");
                }
            };
            
            
            alert.cornerRadius = 3.0f;
            [alert show];
        }
        else
        {
            [alert dismissAlertView];
        }

    }
    else
    {
        
        NSLog(@"mobile :: %@",mobile);
        NSLog(@"assistant_type :: %@",asstType);
        NSLog(@"assistant_time :: %@",asstTime);
        NSLog(@"enableDisabled :: %@",enableDisabled);
    
        [SVProgressHUD showWithStatus:@"Please wait ..."];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                       {
                           WebServiceCall *ws = [[WebServiceCall alloc] init];
                           
                           NSDictionary *response = [ws setupassistant:mobile :asstType :asstTime];
                           
                           [self setJsonResponse:response];
                           
                           dispatch_async(dispatch_get_main_queue(), ^{
                               [SVProgressHUD dismiss];
                               [self processResult];
                           });
                       });
         
    }
    
}


-(void)processResult
{
    
    NSLog(@" reponse : %@",[self jsonResponse]);
    
    NSDictionary *response = [self jsonResponse];
    
    int code = [[response objectForKey:@"code"] intValue];
    NSString *description = [response objectForKey:@"description"];
    
    /*
     code = 200;
     mobile = @"08099440203";
     asstType = @"402";
     */
    
    NSLog(@" code : %d",code);
    NSLog(@" description : %@",description);
    
    //code = 200;
    
    if (code == 200)
    {
        [self saveToDB];
    }
    else
    {
        NSString *msg = @"";
        
        if (code == 201)
            msg = @"Mobile Assistant cost N750, check your balance and subscribe again";
        else if (code == 230)
            msg = @"Please ensure your device is connected to etisalat mobile data";
        else
            msg = @"Your request was not succesful. Please try again later";
        
        [self showError:msg];
        
    }
    
}


- (IBAction)showError :(NSString *)error
{
    //__weak SetupViewController *self_ = self;
    
    if (!alert || !alert.isDisplayed)
    {
        
        alert = [[AMSmoothAlertView alloc]initFadeAlertWithTitle:@"Sorry !" andText:error andCancelButton:NO forAlertType:AlertFailure];
        [alert.defaultButton setTitle:@"OK" forState:UIControlStateNormal];
        [alert setTitleFont:[UIFont fontWithName:@"NeoTechAlt-Medium" size:17.0f]];
        alert.completionBlock = ^void (AMSmoothAlertView *alertObj, UIButton *button)
        {
            if(button == alertObj.defaultButton)
            {
                //NSLog(@"Default");
                //[self_ gotoSettingsScreen];
            }
            else
            {
                NSLog(@"Others");
            }
        };
        
        
        alert.cornerRadius = 3.0f;
        [alert show];
    }
    else
    {
        [alert dismissAlertView];
    }
    
}


-(void)saveToDB
{
    
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK)
    {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    NSLog(@"Opened DB so as to save Record !");
    
    char *errorMsg;
    
    // Note that the continuation char on next line is not part of string...
    //create USER
    
    NSString *createSQL = @"CREATE TABLE IF NOT EXISTS USER (ASSISTANT_TYPE TEXT, ASSISTANT_NUMBER TEXT, ASSISTANT_TIME TEXT, ENABLED_DISABLED TEXT);";
    if (sqlite3_exec (database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
    {
        sqlite3_close(database);
        NSAssert1(0, @"Error creating DB tables: %s", errorMsg);
    }
    
    NSLog(@"USER Created !");
    
    
    NSString *updateS;
    sqlite3_stmt *stmt;
    
    updateS = @"INSERT OR REPLACE INTO USER (ASSISTANT_TYPE, ASSISTANT_NUMBER, ASSISTANT_TIME, ENABLED_DISABLED) VALUES (?, ?, ?, ?);";
    NSLog(@"insert into user-> %@",updateS);
    
    const char *update2 = [updateS UTF8String];
    
    if (sqlite3_prepare_v2(database, update2, -1, &stmt, nil) == SQLITE_OK)
    {
        sqlite3_bind_text(stmt, 1, [asstType UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 2, [mobile UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 3, [asstTime UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 4, [enableDisabled UTF8String], -1, NULL);
    }
    
    if (sqlite3_step(stmt) != SQLITE_DONE)
        NSAssert(0, @"Error updating table");
    
    NSLog(@"Record has been updated in USER !");
    
    
    sqlite3_finalize(stmt);
    
    sqlite3_close(database);
    
    
    [[NSUserDefaults standardUserDefaults] setObject:asstType forKey:@"ASSISTANT_TYPE"];
    [[NSUserDefaults standardUserDefaults] setObject:mobile forKey:@"ASSISTANT_NUMBER"];
    [[NSUserDefaults standardUserDefaults] setObject:asstTime forKey:@"ASSISTANT_TIME"];
    [[NSUserDefaults standardUserDefaults] setObject:enableDisabled forKey:@"ENABLED_DISABLED"];
    
    [self showSucess];
    
}


- (IBAction)showSucess
{
    __weak SetupViewController *self_ = self;
    
    if (!alert || !alert.isDisplayed)
    {
        
        alert = [[AMSmoothAlertView alloc]initDropAlertWithTitle:@"Congratulations" andText:@"Your Mobile Assistant service is now fully activated." andCancelButton:NO forAlertType:AlertSuccess];
        [alert.defaultButton setTitle:@"OK" forState:UIControlStateNormal];
        [alert setTitleFont:[UIFont fontWithName:@"NeoTechAlt-Medium" size:17.0f]];
        alert.completionBlock = ^void (AMSmoothAlertView *alertObj, UIButton *button)
        {
            if(button == alertObj.defaultButton)
            {
                NSLog(@"Default");
                [self_ gotoSettingsScreen];
            }
            else
            {
                NSLog(@"Others");
            }
        };
        
        
        alert.cornerRadius = 3.0f;
        [alert show];
    }
    else
    {
        [alert dismissAlertView];
    }
    
}


-(void)gotoSettingsScreen
{
    [self performSegueWithIdentifier: @"SettingsSegue" sender:self];
    
}


-(IBAction)backgroundTap:(id)sender
{
    [mobileAssistantText resignFirstResponder];
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField:textField up:YES method:@"showpad"];
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField:textField up:NO method:@"dismisspad"];
}


-(IBAction) doneEditing:(id) sender
{
    [self animateTextField:sender up:NO method:@"return"];
}


- (void) animateTextField: (UITextField*) textField up: (BOOL) up method: (NSString *) method
{
    
    if ( dismisskeypad == 0 )
    {
        CGPoint temp = [textField.superview convertPoint:textField.frame.origin toView:nil];
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        if(orientation == UIInterfaceOrientationPortrait)
        {
            if(up)
            {
                int moveUpValue = temp.y + textField.frame.size.height;
                animatedDis = 252 - (DEVICE_HEIGHT - moveUpValue - 15);
                
                NSLog(@":::: Here ::::");
            }
        }
        else if(orientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            if(up)
            {
                int moveUpValue = 568-temp.y + textField.frame.size.height;
                animatedDis = 252 - (DEVICE_HEIGHT - moveUpValue - 15);
            }
            
        }
        
        
        if(animatedDis > 0)
        {
            const int movementDistance = animatedDis;
            const float movementDuration = 0.3f;
            int movement = (up ? -movementDistance : movementDistance);
            
            [UIView beginAnimations: nil context: nil];
            [UIView setAnimationBeginsFromCurrentState: YES];
            [UIView setAnimationDuration: movementDuration];
            
            if(orientation == UIInterfaceOrientationPortrait)
            {
                self.view.superview.frame = CGRectOffset(self.view.superview.frame, 0, movement);
            }
            else if(orientation == UIInterfaceOrientationPortraitUpsideDown)
            {
                self.view.superview.frame = CGRectOffset(self.view.superview.frame, 0, -movement);
            }
            
            [UIView commitAnimations];
        }
        
    }
    
    if ([method isEqualToString:@"dismisspad"])
    {
        dismisskeypad = 0;
    }
    
    if ([method isEqualToString:@"return"])
    {
        dismisskeypad = 1;
    }
    
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    NSString *expression = @"^([0-9]+)?$";
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:newString
                                                        options:0
                                                          range:NSMakeRange(0, [newString length])];
    if (numberOfMatches == 0)
        return NO;
    
    return YES;
    
}


@end