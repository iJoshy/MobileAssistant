//
//  SplashViewController.m
//  MobileAssistant
//
//  Created by Joshua Balogun on 11/26/14.
//  Copyright (c) 2014 Etisalat. All rights reserved.
//

#import "SplashViewController.h"
#import "SVProgressHUD.h"
#import "WebServiceCall.h"
#import <sqlite3.h>

@interface SplashViewController ()

@end


@implementation SplashViewController
{
    AMSmoothAlertView * alert;
}


@synthesize jsonResponse;
@synthesize mobile, asstMobile, asstType, asstTime, enableDisabled;


- (NSString *)dataFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:kFilename];
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unwind) name:@"UNWINDFROMSETTINGS" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidAppear:) name:@"RELOADSPLASH" object:nil];
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    
    [SVProgressHUD showWithStatus:@"loading ..."];
    
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://preorder.etisalat.com.ng/geo/index.php"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [theRequest setHTTPMethod:@"POST"];
    
    NSURLResponse* response;
    NSError* error;
    NSData* result = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
    NSString *serverResponse = [[NSString alloc] initWithData:result encoding:NSASCIIStringEncoding];
    
    
    //NSLog(@"The serverResponse -> %@",serverResponse);
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"SCREEN"];
    [[NSUserDefaults standardUserDefaults] setObject:serverResponse forKey:@"ORIGIN"];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       WebServiceCall *ws = [[WebServiceCall alloc] init];
                       
                       NSDictionary *response = [ws query];
                       
                       [self setJsonResponse:response];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [SVProgressHUD dismiss];
                           [self processResult];
                       });
                   });
    
}


-(void)processResult
{
    
    NSLog(@" reponse : %@",[self jsonResponse]);
    
    NSDictionary *response = [self jsonResponse];
    
    code = [[response objectForKey:@"code"] intValue];
    NSString *description = [response objectForKey:@"description"];
    mobile = [response objectForKey:@"msisdn"];
    asstMobile = [response objectForKey:@"asst_msisdn"];
    asstType = [response objectForKey:@"asst_type"];
    asstTime = [response objectForKey:@"timeout"];
    enableDisabled = [response objectForKey:@"enabled"];
    
    
    NSString *origin = [[NSUserDefaults standardUserDefaults] stringForKey:@"ORIGIN"];
    if([origin intValue] == 2)
    {
        code = 200;
        description = @"Successful";
        mobile = @"08099440203";
        asstMobile = @"08099440449";
        asstType = @"Control";
        asstTime = @"15";
        enableDisabled = @"true";
    }
    

    if ([asstMobile isEqual:[NSNull null]])
    {
        asstMobile = @"";
        asstType = @"";
        asstTime = @"";
        enableDisabled = @"";
    }
    else
    {
        
        if ([[asstMobile substringToIndex:3] isEqualToString:@"234"])
        {
            asstMobile = [NSString stringWithFormat:@"0%@",[asstMobile substringFromIndex:3]];
        }
        
        
        if ([asstType isEqualToString:@"Live"])
        {
            asstType = @"400";
        }
        else if ([asstType isEqualToString:@"Timed"])
        {
            asstType = @"401";
        }
        else if ([asstType isEqualToString:@"Control"])
        {
            asstType = @"402";
        }
        
        
        if ([asstTime isEqual:[NSNull null]])
        {
            asstTime = @"10";
        }
        
        
        if ([enableDisabled isEqualToString:@"true"])
        {
            enableDisabled = @"1";
        }
        else if ([enableDisabled isEqualToString:@"false"])
        {
            enableDisabled = @"0";
        }
        
    }
    
    /*
    code = 200;
    description = @"Successful";
    mobile = @"08099440203";
    asstMobile = @"08099440449";
    asstType = @"Control";
    asstTime = @"15";
    enableDisabled = @"true";
    */
    
    NSLog(@" code : %d",code);
    NSLog(@" description : %@",description);
    NSLog(@" msisdn : %@",mobile);
    NSLog(@" assistant_msisdn  : %@",asstMobile);
    NSLog(@" assistant_type : %@",asstType);
    NSLog(@" assistant_time : %@",asstTime);
    NSLog(@" enableDisabled : %@",enableDisabled);
    
    //code = 304;
    
    if (code == 200)
    {
        [self EligibleSubscribedSetup];
    }
    else if (code == 304)
    {
        [self EligibleSubscribed];
    }
    else
    {
        [self CheckEligiblitiy];
    }
    
}


-(void)EligibleSubscribedSetup
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
        sqlite3_bind_text(stmt, 2, [asstMobile UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 3, [asstTime UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 4, [enableDisabled UTF8String], -1, NULL);
    }
    
    if (sqlite3_step(stmt) != SQLITE_DONE)
        NSAssert(0, @"Error updating table");
    
    NSLog(@"Record has been updated in USER !");
    
    
    sqlite3_finalize(stmt);
    
    sqlite3_close(database);
    
    
    [[NSUserDefaults standardUserDefaults] setObject:asstType forKey:@"ASSISTANT_TYPE"];
    [[NSUserDefaults standardUserDefaults] setObject:asstMobile forKey:@"ASSISTANT_NUMBER"];
    [[NSUserDefaults standardUserDefaults] setObject:asstTime forKey:@"ASSISTANT_TIME"];
    [[NSUserDefaults standardUserDefaults] setObject:enableDisabled forKey:@"ENABLED_DISABLED"];
    
    [self showCreatedSucess];
    
}


-(void)showCreatedSucess
{
    
    if (!alert || !alert.isDisplayed)
    {
        
        alert = [[AMSmoothAlertView alloc]initFadeAlertWithTitle:@"Welcome" andText:@"You are an active mobile assistant service subscriber. You may now update your settings." andCancelButton:NO forAlertType:AlertCustom];
        [alert.defaultButton setTitle:@"OK" forState:UIControlStateNormal];
        [alert setTitleFont:[UIFont fontWithName:@"NeoTechAlt-Medium" size:17.0f]];
        
        [self performSegueWithIdentifier: @"CreatedSegue" sender:self];

        alert.cornerRadius = 3.0f;
        [alert show];
    }
    else
    {
        [alert dismissAlertView];
    }
    
}


-(void)EligibleSubscribed
{
    
    if (!alert || !alert.isDisplayed)
    {
        
        alert = [[AMSmoothAlertView alloc]initFadeAlertWithTitle:@"Welcome" andText:@"You have already subscribed for the mobile assistant service. You can now setup your assistant." andCancelButton:NO forAlertType:AlertCustom];
        [alert.defaultButton setTitle:@"OK" forState:UIControlStateNormal];
        [alert setTitleFont:[UIFont fontWithName:@"NeoTechAlt-Medium" size:17.0f]];
        
        [self performSegueWithIdentifier: @"SubcribedSegue" sender:self];
        
        alert.cornerRadius = 3.0f;
        [alert show];
    }
    else
    {
        [alert dismissAlertView];
    }
    
}


-(void)CheckEligiblitiy
{
    
    [SVProgressHUD showWithStatus:@"loading ..."];
    
    jsonResponse  = nil;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       WebServiceCall *ws = [[WebServiceCall alloc] init];
                       
                       NSDictionary *response = [ws verify];
                       
                       [self setJsonResponse:response];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [SVProgressHUD dismiss];
                           [self processResult2];
                       });
                   });
    
}


-(void)processResult2
{
    
    NSLog(@" reponse : %@",[self jsonResponse]);
    
    NSDictionary *response = [self jsonResponse];
    
    code = [[response objectForKey:@"code"] intValue];
    NSString *description = [response objectForKey:@"description"];
    
    /*
      code = 302;
      mobile = @"08099440203";
      asstType = @"402";
    */
    
    NSLog(@" code : %d",code);
    NSLog(@" description : %@",description);
    
    //code = 302;
    
    if (code == 302)
    {
        [self showSucessWithDuration];
    }
    else
    {
        NSString *msg = @"";
        
        if (code == 230) msg = @"Please ensure your device is connected to etisalat mobile data";
        else if (code == 303) msg = @"Eligible packages are Easybusiness, Easyflex 5000, Classic & Easylife Hybrid (PostPaid)";
        else
            msg = @"Your request was not succesful. Please try again later";
        
        [self showError:msg];
        
    }
    
}


- (IBAction)showError :(NSString *)error
{
    //__weak SplashViewController *self_ = self;
    
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


- (IBAction)showSucessWithDuration
{
    
    if (!alert || !alert.isDisplayed)
    {
        
        alert = [[AMSmoothAlertView alloc]initFadeAlertWithTitle:@"Welcome" andText:@"You're eligible for the mobile assistant service. Simply subscribe and add an assistant." andCancelButton:NO forAlertType:AlertCustom];
        [alert.defaultButton setTitle:@"OK" forState:UIControlStateNormal];
        [alert setTitleFont:[UIFont fontWithName:@"NeoTechAlt-Medium" size:17.0f]];

        alert.cornerRadius = 3.0f;
        [alert show];
        
        [self createDB];
    }
    else
    {
        [alert dismissAlertView];
    }
    
}


-(void)createDB
{
    
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
    
    NSString *createSQL = @"CREATE TABLE IF NOT EXISTS USER (ASSISTANT_TYPE TEXT, ASSISTANT_NUMBER TEXT, ASSISTANT_TIME TEXT, ENABLED_DISABLED TEXT);";
    if (sqlite3_exec (database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
    {
        sqlite3_close(database);
        NSAssert1(0, @"Error creating DB tables: %s", errorMsg);
    }
    
    NSLog(@"USER Created !");
    
    sqlite3_close(database);
    
    
    [self performSegueWithIdentifier: @"iPhoneSplashSegue" sender:self];
    
}

-(void)unwind
{
    [self performSegueWithIdentifier: @"iPhoneSplashSegue" sender:self];
}


@end