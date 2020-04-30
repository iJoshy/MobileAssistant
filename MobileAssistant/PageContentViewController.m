//
//  PageContentViewController.m
//  MobileAssistant
//
//  Created by Joshua Balogun on 11/26/14.
//  Copyright (c) 2014 Etisalat. All rights reserved.
//

#import "PageContentViewController.h"

@interface PageContentViewController ()

@end

@implementation PageContentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.backgroundImageView.image = [UIImage imageNamed:self.imageFile];
    self.titleLabel.text = self.titleText;
    self.descrTextView.text = self.descrText;
    [self.descrTextView setTextAlignment:NSTextAlignmentCenter];
    [self.descrTextView setFont:[UIFont fontWithName:@"NeoTechAlt" size:14.0f]];
    
    self.titleLabel.layer.borderWidth = 1;
    self.titleLabel.layer.cornerRadius = 4.0;
    self.titleLabel.layer.masksToBounds = YES;
    self.titleLabel.layer.borderColor = [[UIColor colorWithRed:87/255.0 green:127/255.0 blue:24/255.0 alpha:1] CGColor];
    
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
