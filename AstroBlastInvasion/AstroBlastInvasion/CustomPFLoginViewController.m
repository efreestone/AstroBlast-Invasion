// Elijah Freestone
// IAD 1412
// Week 4
// December 14th, 2014

//
//  CustomPFLoginViewController.m
//  Project4
//
//  Created by Elijah Freestone on 12/14/14.
//  Copyright (c) 2014 Elijah Freestone. All rights reserved.
//

#import "CustomPFLoginViewController.h"

@interface CustomPFLoginViewController ()

@end

@implementation CustomPFLoginViewController

- (void)viewDidLoad {
    [self.logInView setLogo:nil];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate {
    return NO;
}

//Set orientation to landscape only
- (NSUInteger)supportedInterfaceOrientations {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskLandscape;
    } else {
        return UIInterfaceOrientationMaskLandscape;
    }
}

//Set frames for overide items (login field, etc)
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    //Get screen width and set frame for elements. Used for both iPhone and iPad
    CGFloat screenWidth = self.logInView.bounds.size.width;
    
    self.logInView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];

    [self.logInView.usernameField setFrame:CGRectMake(35.0f, 50.0f, 250.0f, 50.0f)];
    self.logInView.usernameField.center = CGPointMake(screenWidth/2.0f, 50.0f);
//    self.logInView.usernameField.backgroundColor = [UIColor lightGrayColor];
    [self.logInView.passwordField setFrame:CGRectMake(35.0f, 100.0f, 250.0f, 50.0f)];
    self.logInView.passwordField.center = CGPointMake(screenWidth/2.0f, 100.0f);
//    [self.fieldsBackground setFrame:CGRectMake(35.0f, 100.0f, 250.0f, 100.0f)];
    [self.logInView.logInButton setFrame:CGRectMake(35.0f, 155.0f, 250.0f, 40.0f)];
    self.logInView.logInButton.center = CGPointMake(screenWidth/2.0f, 155.0f);
    [self.logInView.signUpButton setFrame:CGRectMake(35.0f, 200.0f, 250.0f, 40.0f)];
    self.logInView.signUpButton.center = CGPointMake(screenWidth/2.0f, 200.0f);
    self.logInView.passwordForgottenButton.center = CGPointMake(screenWidth/2.0f, 250.0f);
} //viewDidLayoutSubviews close

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



@end
