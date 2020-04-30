//
//  ViewController.m
//  MobileAssistant
//
//  Created by Joshua Balogun on 11/26/14.
//  Copyright (c) 2014 Etisalat. All rights reserved.
//

#import "ViewController.h"
#import "SetupViewController.h"
#import "SVProgressHUD.h"
#import "WebServiceCall.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

@end

NSString *kSuccessTitle = @"Congratulations";
NSString *kErrorTitle = @"Connection error";
NSString *kNoticeTitle = @"Notice";
NSString *kWarningTitle = @"Warning";
NSString *kInfoTitle = @"Info";
NSString *kSubtitle = @"You've just displayed this awesome Pop Up View";
NSString *kButtonTitle = @"Done";
NSString *kAttributeTitle = @"Attributed string operation successfully completed.";


@implementation ViewController
{
    AMSmoothAlertView * alert;
}

@synthesize startButton, subscribeButton, pcDots;
@synthesize /*skipButton,*/ titleLabel, jsonResponse;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES];
    
	// Create the data model
    _pageDescriptions = @[@"A service that enables a user - in this case an Executive - to pair another number (an Assistant) such that when the Executive number is called it rings on both the Executive and the Assistant’s number.", @"This is the default service mode. It is set up in such a way that when the call is rejected by the Executive, it starts ringing on the Assistant’s number.", @"This is set up in such a way that once the Executive’s phone rings unanswered after the configured time – for example 10 seconds - the Assistant’s number will start to ring.", @"This is set up in such a way that when the Executive number is called it rings on the Executive and Assistant phones simultaneously; therefore, whoever answers the call first attends to the caller."];
    
    _pageTitles = @[@"mobile assistant", @"1. controlled assistant", @"2. timed assistant", @"3. live assistant"];
    
    _pageImages = @[@"background.png", @"background_grey.png", @"background.png", @"background_grey.png"];
    
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    PageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height + 37);
    //[[self.pageViewController view] setFrame:[[self view] bounds]];
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    
    self.subscribeButton.layer.borderWidth = 1;
    self.subscribeButton.layer.cornerRadius = 4.0;
    self.subscribeButton.layer.masksToBounds = YES;
    [self.subscribeButton setAdjustsImageWhenHighlighted:NO];
    self.subscribeButton.layer.borderColor = [[UIColor colorWithRed:87/255.0 green:127/255.0 blue:24/255.0 alpha:1] CGColor];
    
    
    // Bring the common controls to the foreground (they were hidden since the frame is taller)
    [self.view bringSubviewToFront:self.pcDots];
    [self.view bringSubviewToFront:self.titleLabel];
    //[self.view bringSubviewToFront:self.skipButton];
    [self.view bringSubviewToFront:self.startButton];
    [self.view bringSubviewToFront:self.subscribeButton];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"2" forKey:@"SCREEN"];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [NSThread sleepForTimeInterval:2.0];
    
    [self.pcDots setCurrentPage:1];
    
    PageContentViewController *startingViewController = [self viewControllerAtIndex:1];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startWalkthrough:(id)sender
{
    [self.pcDots setCurrentPage:0];
    
    PageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
}

- (IBAction)subscribeClicked
{
    
    __weak ViewController *self_ = self;
    
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
                           [self processResult];
                       });
                   });
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
    
    NSLog(@" code  : %d",code);
    NSLog(@" description : %@",description);
    
    //code = 200;
    
    if (code == 200)
    {
        [self showSucess];
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
    //__weak ViewController *self_ = self;
    
    
    alert = [[AMSmoothAlertView alloc]initFadeAlertWithTitle:@"Sorry !" andText:error andCancelButton:NO forAlertType:AlertFailure];
    [alert.defaultButton setTitle:@"OK" forState:UIControlStateNormal];
    [alert setTitleFont:[UIFont fontWithName:@"NeoTechAlt-Medium" size:17.0f]];
    alert.completionBlock = ^void (AMSmoothAlertView *alertObj, UIButton *button)
    {
        if(button == alertObj.defaultButton)
        {
            //NSLog(@"Default");
        }
        else
        {
            NSLog(@"Others");
        }
    };
    
    
    alert.cornerRadius = 3.0f;
    [alert show];
    
    
}


- (IBAction)showSucess
{
        
    alert = [[AMSmoothAlertView alloc]initDropAlertWithTitle:@"Congratulations" andText:@"Your request is being processed please wait for a confirmation SMS thank you." andCancelButton:NO forAlertType:AlertSuccess];
    [alert.defaultButton setTitle:@"OK" forState:UIControlStateNormal];
    [alert setTitleFont:[UIFont fontWithName:@"NeoTechAlt-Medium" size:17.0f]];
    alert.delegate = self;
    
    alert.cornerRadius = 3.0f;
    [alert show];

}


#pragma mark - Delegates
- (void)alertView:(AMSmoothAlertView *)alertView didDismissWithButton:(UIButton *)button
{
    if (alertView == alert)
    {
        if (button == alert.defaultButton)
        {
            NSLog(@"Default button touched!");
            [self performSegueWithIdentifier:@"AppSubscribeSegue" sender:self];
        }
        if (button == alert.cancelButton) {
            NSLog(@"Cancel button touched!");
        }
    }
}


- (PageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    PageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    pageContentViewController.imageFile = self.pageImages[index];
    pageContentViewController.titleText = self.pageTitles[index];
    pageContentViewController.descrText = self.pageDescriptions[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    [self.pcDots setCurrentPage:index];
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
     [self.pcDots setCurrentPage:index];
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageTitles count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    NSInteger dotCount = [self.pageTitles count];
    [self.pcDots setNumberOfPages:dotCount];
    
    return dotCount;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}


@end
