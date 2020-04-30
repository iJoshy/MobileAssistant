//
//  ViewController.h
//  MobileAssistant
//
//  Created by Joshua Balogun on 11/26/14.
//  Copyright (c) 2014 Etisalat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageContentViewController.h"
#import "AMSmoothAlertView.h"
#import "AMSmoothAlertConstants.h"

@interface ViewController : UIViewController <UIPageViewControllerDataSource, AMSmoothAlertViewDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) IBOutlet UIPageControl *pcDots;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
//@property (strong, nonatomic) IBOutlet UIButton *skipButton;
@property (strong, nonatomic) IBOutlet UIButton *startButton;
@property (strong, nonatomic) IBOutlet UIButton *subscribeButton;

@property (strong, nonatomic) NSArray *pageDescriptions;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages;

@property (nonatomic, strong) NSDictionary *jsonResponse;

- (IBAction)startWalkthrough:(id)sender;
- (IBAction)subscribeClicked;

@end
