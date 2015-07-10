// Elijah Freestone
// IAD 1412
// Week 4
// December 14th, 2014

//
//  CustomPFSignUpViewController.m
//  Project4
//
//  Created by Elijah Freestone on 12/14/14.
//  Copyright (c) 2014 Elijah Freestone. All rights reserved.
//

#import "CustomPFSignUpViewController.h"

@interface CustomPFSignUpViewController ()

@end

@implementation CustomPFSignUpViewController

- (void)viewDidLoad {
    [self.signUpView setLogo:nil];
    
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
    CGFloat screenWidth = self.signUpView.bounds.size.width;
    
    [self.signUpView.usernameField setFrame:CGRectMake(35.0f, 50.0f, 250.0f, 50.0f)];
    self.signUpView.usernameField.center = CGPointMake(screenWidth/2.0f, 50.0f);
    [self.signUpView.passwordField setFrame:CGRectMake(35.0f, 100.0f, 250.0f, 50.0f)];
    self.signUpView.passwordField.center = CGPointMake(screenWidth/2.0f, 100.0f);
    //    [self.fieldsBackground setFrame:CGRectMake(35.0f, 100.0f, 250.0f, 100.0f)];
    [self.signUpView.emailField setFrame:CGRectMake(35.0f, 150.0f, 250.0f, 50.0f)];
    self.signUpView.emailField.center = CGPointMake(screenWidth/2.0f, 150.0f);
    [self.signUpView.signUpButton setFrame:CGRectMake(35.0f, 200.0f, 250.0f, 40.0f)];
    self.signUpView.signUpButton.center = CGPointMake(screenWidth/2.0f, 200.0f);
    //self.signUpView.passwordForgottenButton.center = CGPointMake(screenWidth/2.0f, 250.0f);
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
