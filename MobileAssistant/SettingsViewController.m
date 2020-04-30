//
//  SettingsViewController.m
//  MobileAssistant
//
//  Created by Joshua Balogun on 11/26/14.
//  Copyright (c) 2014 Etisalat. All rights reserved.
//


#import "SettingsViewController.h"
#import "RadioButton.h"
#import "SVProgressHUD.h"
#import "WebServiceCall.h"
#import <QuartzCore/QuartzCore.h>
#import <sqlite3.h>

#define DEVICE_HEIGHT [[UIScreen mainScreen] bounds].size.height

@implementation SettingsViewController
{
    AMSmoothAlertView * alert;
}

@synthesize sendButton, mobileAssistantText,enableDisabled;
@synthesize legendText1, legendText2, legendText3, jsonResponse;
@synthesize mobile, asstType, timelabel, asstTime;
@synthesize radioButton1, radioButton2, radioButton3;


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
    
    [self setTitle:@"Settings"];
    
    radioButton1.groupButtons = @[radioButton1, radioButton2, radioButton3];
    
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
    
    
    [self.navigationItem setHidesBackButton:YES];
    
    mobileAssistantText.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"ASSISTANT_NUMBER"];
    asstTime = [[NSUserDefaults standardUserDefaults] stringForKey:@"ASSISTANT_TIME"];
    enableDisabled = [[NSUserDefaults standardUserDefaults] stringForKey:@"ENABLED_DISABLED"];
    int selectedType = [[[NSUserDefaults standardUserDefaults] stringForKey:@"ASSISTANT_TYPE"] intValue];
    asstType = [NSString stringWithFormat:@"%d",selectedType];
    
    NSLog(@" asst number :: %@",mobileAssistantText.text);
    NSLog(@" selectedType :: %d",selectedType);
    NSLog(@" asst time :: %@",asstTime);
    NSLog(@" enableDisabled :: %@",enableDisabled);
    
    timelabel.hidden = YES;
    when = 1;
    
    // Determine type of assistant
    if ([asstType intValue] == 401)
    {
        when = 0;
        [self setTimer];
    }
    
    [radioButton1 setSelectedWithTag:selectedType];
    
    self.plainStepper.countLabel.text = [NSString stringWithFormat:@"%@ : seconds",asstTime];
    
    
    // Determin enalbed / disabled button
    NSString *title = @"";
    
    if ([enableDisabled isEqualToString:@"0"])
    {
        title = @"Activate";
        [self deActivateComponents];
    }
    else if ([enableDisabled isEqualToString:@"1"])
    {
        title = @"Suspend";
    }

    UIBarButtonItem *leftbutton =  [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:self action:@selector(enableORdisableTapped)];
    [leftbutton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIColor whiteColor],NSForegroundColorAttributeName,[UIFont fontWithName:@"NeoTechAlt" size:13.0f],NSFontAttributeName,
                                        nil] forState:UIControlStateNormal];
    
    self.navigationItem.leftBarButtonItem = leftbutton;
    
    
    UIBarButtonItem *rightbutton =  [[UIBarButtonItem alloc] initWithTitle:@"Opt-out" style:UIBarButtonItemStyleBordered target:self action:@selector(optoutTapped)];
    [rightbutton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIColor whiteColor],NSForegroundColorAttributeName,[UIFont fontWithName:@"NeoTechAlt" size:13.0f],NSFontAttributeName,
                                         nil] forState:UIControlStateNormal];
    
    self.navigationItem.rightBarButtonItem = rightbutton;
    
    [[NSUserDefaults standardUserDefaults] setObject:@"4" forKey:@"SCREEN"];
    
}


-(void) activateComponents
{
    self.mobileAssistantText.enabled = YES;
    
    self.radioButton1.enabled = YES;
    self.radioButton2.enabled = YES;
    self.radioButton3.enabled = YES;
    
    self.plainStepper.enabled = YES;
    
    self.sendButton.enabled = YES;
    [sendButton setBackgroundColor:[[UIColor colorWithRed:0.443 green:0.620 blue:0.094 alpha:1] colorWithAlphaComponent:1]];
}


-(void) deActivateComponents
{    
    self.mobileAssistantText.enabled = NO;
    
    self.radioButton1.enabled = NO;
    self.radioButton2.enabled = NO;
    self.radioButton3.enabled = NO;
    
    self.plainStepper.enabled = NO;
    
    self.sendButton.enabled = NO;
    [sendButton setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:1]];
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
        when = 1;
    }
    
}


-(void) setTimer
{
    NSLog(@"Show and set timer dialog");
    
    if (! self.plainStepper)
    {
        
        NSLog(@"Show and set timer dialog");
        
        if (when == 1)
        {
            UIAlertView *alert1 = [[UIAlertView alloc]initWithTitle:nil message:@"The default delay time is 10 seconds. Select your prefered delay time below" delegate:nil  cancelButtonTitle:@"ok" otherButtonTitles: nil];
            [alert1 show];
        }
        
        timelabel.hidden = NO;
        
        float width = 250.0f;
        float screenWidth = [UIScreen mainScreen].bounds.size.width;
        float x = (screenWidth - width) / 2.0;
        __weak SettingsViewController *self_ = self;
        
        // plain
        self.plainStepper = [[PKYStepper alloc] initWithFrame:CGRectMake(x, 420, width, 36)];
        self.plainStepper.value = [asstTime floatValue];
        self.plainStepper.minimum = 10.0f;
        self.plainStepper.maximum = 60.0f;
        self.plainStepper.valueChangedCallback = ^(PKYStepper *stepper, float count) {
            self_.asstTime = [NSString stringWithFormat:@"%@", @(count)];
            stepper.countLabel.text = [NSString stringWithFormat:@"%@ : seconds", self_.asstTime];
        };
        [self.plainStepper setTag:330];
        [self.plainStepper setup];
        [self.view addSubview:self.plainStepper];
        
        when = 2;
    }
}


- (IBAction)enableORdisableTapped
{
    
    __weak SettingsViewController *self_ = self;
    
    
    NSString *title = @"";
    
    if ([enableDisabled isEqualToString:@"0"])
    {
        title = @"This action will activate your Mobile Assistant subscription. Click ok to confirm.";
    }
    else if ([enableDisabled isEqualToString:@"1"])
    {
        title = @"This action will suspend your Mobile Assistant subscription. Click ok to confirm.";
    }
    
    
    if (!alert || !alert.isDisplayed)
    {
        
        alert = [[AMSmoothAlertView alloc]initFadeAlertWithTitle:@"Notice" andText:title andCancelButton:YES forAlertType:AlertInfo];
        [alert setTitleFont:[UIFont fontWithName:@"NeoTechAlt-Medium" size:17.0f]];
        alert.completionBlock = ^void (AMSmoothAlertView *alertObj, UIButton *button)
        {
            if(button == alertObj.defaultButton)
            {
                NSLog(@"enableDisabled ==>> %@", self_.enableDisabled);

                if ([self_.enableDisabled isEqualToString:@"0"])
                {
                    [self_ gotoActivateProcess];
                }
                else if ([self_.enableDisabled isEqualToString:@"1"])
                {
                    [self_ gotoSuspendProcess];
                }
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


- (IBAction)optoutTapped
{
    __weak SettingsViewController *self_ = self;
    
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


-(void)gotoActivateProcess
{
    NSLog(@" :::: actiavte process call :::: ");
    
    [SVProgressHUD showWithStatus:@"Please wait ..."];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       WebServiceCall *ws = [[WebServiceCall alloc] init];
                       
                       NSDictionary *response = [ws enable];
                       
                       [self setJsonResponse:response];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [SVProgressHUD dismiss];
                           [self enableDisabledAssistant:@"0"];
                       });
                   });
    
    
}


-(void)gotoSuspendProcess
{
    NSLog(@" :::: suspend process call :::: ");
    
    [SVProgressHUD showWithStatus:@"Please wait ..."];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       WebServiceCall *ws = [[WebServiceCall alloc] init];
                       
                       NSDictionary *response = [ws disable];
                       
                       [self setJsonResponse:response];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [SVProgressHUD dismiss];
                           [self enableDisabledAssistant:@"1"];
                       });
                   });
    
    
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


-(void)enableDisabledAssistant:(NSString *)status
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
        [self updateDB:status];
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
        
        if (code == 201)
            msg = @"As a postpaid subscriber, Please visit any experience center closest to you.";
        else if (code == 230)
            msg = @"Please ensure your device is connected to etisalat mobile data.";
        else
            msg = @"Your request was not succesful. Please try again later.";
        
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
    
    __weak SettingsViewController *self_ = self;
    
    alert = [[AMSmoothAlertView alloc]initDropAlertWithTitle:@"Notice" andText:@"You have successfully unsubscribed from the mobile assistan service." andCancelButton:NO forAlertType:AlertSuccess];
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
        NSLog(@"assistant :: %@",asstType);
        NSLog(@"assistant_time :: %@",asstTime);
        
        [SVProgressHUD showWithStatus:@"Please wait ..."];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                       {
                           WebServiceCall *ws = [[WebServiceCall alloc] init];
                           
                           NSDictionary *response = [ws setupassistant:mobile :asstType :asstTime];
                           
                           [self setJsonResponse:response];
                           
                           dispatch_async(dispatch_get_main_queue(), ^{
                               [SVProgressHUD dismiss];
                               [self UpdateAssistant];
                           });
                       });
    }
    
}


-(void)UpdateAssistant
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
    code = 300;
    mobile = @"08099440203";
    asstType = @"402";
     */
    
    NSLog(@" code : %d",code);
    NSLog(@" description : %@",description);
    
    if (code == 200)
    {
        [self updateDB];
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



- (IBAction)showError :(NSString *)error
{

    alert = [[AMSmoothAlertView alloc]initFadeAlertWithTitle:@"Sorry !" andText:error andCancelButton:NO forAlertType:AlertFailure];
    [alert.defaultButton setTitle:@"OK" forState:UIControlStateNormal];
    [alert setTitleFont:[UIFont fontWithName:@"NeoTechAlt-Medium" size:17.0f]];
    alert.completionBlock = ^void (AMSmoothAlertView *alertObj, UIButton *button)
    {
        if(button == alertObj.defaultButton)
        {
            NSLog(@"Default");
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


-(void)updateDB :(NSString *)status
{
    
    if ([status isEqualToString:@"0"])
    {
        status = @"1";
        self.navigationItem.leftBarButtonItem.title = @"Suspend";
        
        [self activateComponents];
    }
    else if ([status isEqualToString:@"1"])
    {
        status = @"0";
        self.navigationItem.leftBarButtonItem.title = @"Activate";
        
        [self deActivateComponents];
    }
    
    enableDisabled = status;
    
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK)
    {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    char *update = "UPDATE USER SET ASSISTANT_TYPE = ?, ASSISTANT_NUMBER = ?, ASSISTANT_TIME = ?, ENABLED_DISABLED = ?";
    
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK)
    {
        sqlite3_bind_text(stmt, 1, [asstType UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 2, [mobile UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 3, [asstTime UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 4, [status UTF8String], -1, NULL);
    }
    
    if (sqlite3_step(stmt) != SQLITE_DONE)
    NSAssert(0, @"Error updating table ");
    
    sqlite3_finalize(stmt);
    sqlite3_close(database);
    
    
    [[NSUserDefaults standardUserDefaults] setObject:asstType forKey:@"ASSISTANT_TYPE"];
    [[NSUserDefaults standardUserDefaults] setObject:mobile forKey:@"ASSISTANT_NUMBER"];
    [[NSUserDefaults standardUserDefaults] setObject:asstTime forKey:@"ASSISTANT_TIME"];
    [[NSUserDefaults standardUserDefaults] setObject:enableDisabled forKey:@"ENABLED_DISABLED"];
    
    
    
    [self showUpdateSucess];
    
}


-(void)updateDB
{
    
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK)
    {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    char *update = "UPDATE USER SET ASSISTANT_TYPE = ?, ASSISTANT_NUMBER = ?, ASSISTANT_TIME = ?, ENABLED_DISABLED = ?";
    
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK)
    {
        sqlite3_bind_text(stmt, 1, [asstType UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 2, [mobile UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 3, [asstTime UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 4, [enableDisabled UTF8String], -1, NULL);
    }
    
    if (sqlite3_step(stmt) != SQLITE_DONE)
        NSAssert(0, @"Error updating table ");
    
    sqlite3_finalize(stmt);
    sqlite3_close(database);
    
    
    [[NSUserDefaults standardUserDefaults] setObject:asstType forKey:@"ASSISTANT_TYPE"];
    [[NSUserDefaults standardUserDefaults] setObject:mobile forKey:@"ASSISTANT_NUMBER"];
    [[NSUserDefaults standardUserDefaults] setObject:asstTime forKey:@"ASSISTANT_TIME"];
    [[NSUserDefaults standardUserDefaults] setObject:enableDisabled forKey:@"ENABLED_DISABLED"];
    
    [self showUpdateSucess];
    
}


- (IBAction)showUpdateSucess 
{
    //__weak SettingsViewController *self_ = self;
    
    if (!alert || !alert.isDisplayed)
    {
        
        alert = [[AMSmoothAlertView alloc]initDropAlertWithTitle:@"Congratulations" andText:@"You have successfully updated your mobile assistant profile." andCancelButton:NO forAlertType:AlertSuccess];
        [alert.defaultButton setTitle:@"OK" forState:UIControlStateNormal];
        [alert setTitleFont:[UIFont fontWithName:@"NeoTechAlt-Medium" size:17.0f]];
        alert.completionBlock = ^void (AMSmoothAlertView *alertObj, UIButton *button)
        {
            if(button == alertObj.defaultButton)
            {
                NSLog(@"Default");
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
    
    /*
    if (textField.text.length > 11 && range.length == 0)
    {
        return NO; // return NO to not change text
    }
    */
    
    return YES;
    
}


@end
