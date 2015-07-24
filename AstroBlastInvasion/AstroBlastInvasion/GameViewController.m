//
//  GameViewController.m
//  AstroBlastInvasion
//
//  Created by Elijah Freestone on 7/9/15.
//  Copyright (c) 2015 Elijah Freestone. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"
#import "MainMenuScene.h"
#import "CustomPFLoginViewController.h"
#import "CustomPFSignUpViewController.h"
#import "Reachability.h"
#import "ConnectionManagement.h"
//#import <Parse/Parse.h>
#import <GameKit/GameKit.h>

@implementation GameViewController {
    ConnectionManagement *connectionMGMT;
    MainMenuScene *mainMenuScene;
    NSString *noConnectionMessage;
    BOOL connectionExists;
    NSUserDefaults *userDefaults;
}

@synthesize userSkippedLogin;

//Move scene creation from viewDidLoad to insure view is created
-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    connectionMGMT = [[ConnectionManagement alloc] init];
    connectionExists = [connectionMGMT checkConnection];
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    //_totalOfEnemiesDestroyed = 0;
    
    noConnectionMessage = @"No network connection available. Only local scores will be saved or shown.";
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    if (!skView.scene) {
        //                        skView.showsFPS = YES;
        //                        skView.showsNodeCount = YES;
        //                        skView.showsPhysics = YES;
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = YES;
        
        // Create and configure the Main Menu scene.
        mainMenuScene = [MainMenuScene sceneWithSize:skView.bounds.size];
        mainMenuScene.scaleMode = SKSceneScaleModeAspectFill;
        mainMenuScene.gameViewController = self;
        // Present the scene.
        [skView presentScene:mainMenuScene];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    //Make sure connection exists before allowing user to log in
    if (![connectionMGMT checkConnection]) {
        [self noConnectionAlert:noConnectionMessage];
    } else {
        if (!userSkippedLogin) {
            //[self isUserLoggedIn];
            [self authGameCenterLocalPlayer];
        }
    }
}

//Try to authenticate local play in Game Center
-(void)authGameCenterLocalPlayer {
    NSLog(@"authGameCenterLocalPlayer");
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController != nil) {
            NSLog(@"authenticationHandler IF");
            [self presentViewController:viewController animated:YES completion:nil];
        } else {
            NSLog(@"authenticationHandler ELSE");
            if ([GKLocalPlayer localPlayer].authenticated) {
                NSLog(@"localPlayer authenticated");
                _gameCenterEnabled = YES;
                
                // Get the default leaderboard identifier.
                [[GKLocalPlayer localPlayer] loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error) {
                    if (error != nil) {
                        NSLog(@"%@", [error localizedDescription]);
                    } else {
                        _leaderboardIdentifier = leaderboardIdentifier;
                        [userDefaults setObject:leaderboardIdentifier forKey:@"leaderboardIdentifier"];
                    }
                }];
            } else {
                NSLog(@"localPlayer NOT authenticated");
                _gameCenterEnabled = NO;
                //Create dialog for no Game Center
                [self noGameCenterUserAlert];
            }
        }
    };
}

////Check if a user is signed in, present login view if not.
//-(void)isUserLoggedIn {
//    //Check if user is already logged
//    if (![PFUser currentUser]) { // No user logged in
//        // Create the log in view controller
//        CustomPFLoginViewController *logInViewController = [[CustomPFLoginViewController alloc] init];
//        [logInViewController setDelegate:self]; // Set ourselves as the delegate
//        
//        // Create the sign up view controller
//        CustomPFSignUpViewController *signUpViewController = [[CustomPFSignUpViewController alloc] init];
//        [signUpViewController setDelegate:self]; // Set ourselves as the delegate
//        
//        // Assign our sign up controller to be displayed from the login controller
//        [logInViewController setSignUpController:signUpViewController];
//        
//        // Present the log in view controller
//        [self presentViewController:logInViewController animated:YES completion:NULL];
//    } else {
//        [mainMenuScene setTextOfSignInLabel];
//        if ([connectionMGMT checkConnection]) {
//            [self queryParseForAchievements];
//        }
//    }
//}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskLandscape;
    } else {
        return UIInterfaceOrientationMaskLandscape;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

////Query parse for achievements. Create default ones if they don't exist
//-(void)queryParseForAchievements {
//    //Query Parse to see if achievements exist for the user
//    PFQuery *achievementQuery = [PFQuery queryWithClassName:@"achievements"];
//    [achievementQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//        if (!error) {
//            NSLog(@"Achievements exist");
//        } else {
//            NSLog(@"No achievements");
//            //Create default Parse object and set ACL to user only
//            PFObject *achievementObject = [PFObject objectWithClassName:@"achievements"];
//            achievementObject.ACL = [PFACL ACLWithUser:[PFUser currentUser]];
//            achievementObject[@"flawless"] = @NO;
//            achievementObject[@"quickDraw"] = @NO;
//            achievementObject[@"halfDozen"] = @NO;
//            achievementObject[@"aDozen"] = @NO;
//            achievementObject[@"dozenAndAHalf"] = @NO;
//            achievementObject[@"lateBloomer"] = @NO;
//            
//            [achievementObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                if (succeeded) {
//                    NSLog(@"Default achievements saved.");
//                } else {
//                    NSLog(@"%@", error);
//                    //Error alert
//                    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"An error occured trying to save default achievements. Please try again.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
//                }
//            }];
//        }
//    }];
//    //Set achievements label to iOS blue
//    mainMenuScene.achievementsLabel.fontColor = mainMenuScene.iOSBlueButtonColor;
//}

//Create and show alert view if there is no internet connectivity
-(void)noConnectionAlert:(NSString *)alertMessage {
    UIAlertView *connectionAlert = [[UIAlertView alloc] initWithTitle:@"No Connection!" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //Show alert
    [connectionAlert show];
} //noConnectionAlert close

//Create and show alert view if there is no Game Center user logged in
-(void)noGameCenterUserAlert {
    NSString *noUserMessage = @"Game Center was cancelled so scores will only be saved locally and achievements won't be available. Please log into the Game Center app on your device if you would like to save scores to the main leaderboard or earn achievements";
    UIAlertView *noUserAlert = [[UIAlertView alloc] initWithTitle:@"Game Center Cancelled!" message:noUserMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //Show alert
    [noUserAlert show];
} //noConnectionAlert close

//#pragma mark - PFLogin Delegate methods from Parse login tutorial
//
////Sent to the delegate to determine whether the log in request should be submitted to the server.
//-(BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
//    // Check if both fields are completed
//    if (username && password && username.length != 0 && password.length != 0) {
//        //mainMenuScene.signInLabel.text = @"Sign Out";
//        return YES; // Begin login process
//    }
//    
//    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
//                                message:@"Make sure you fill out all of the information!"
//                               delegate:nil
//                      cancelButtonTitle:@"ok"
//                      otherButtonTitles:nil] show];
//    return NO; // Interrupt login process
//}
//
////Sent to the delegate when a PFUser is logged in.
//-(void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
//    [self dismissViewControllerAnimated:YES completion:NULL];
//    //mainMenuScene.signInLabel.text = @"Sign Out";
//    [self isUserLoggedIn];
//}
//
////Sent to the delegate when the log in attempt fails.
//-(void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
//    NSLog(@"Failed to log in...");
//    mainMenuScene.signInLabel.text = @"Sign In";
//}
//
////Sent to the delegate when the log in screen is dismissed.
//-(void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
//    NSLog(@"User dismissed the logInViewController");
//    [self.navigationController popViewControllerAnimated:YES];
//    //Set skipped login bool to not reshow login on iPhone after dismissed. Not needed for iPad
//    userSkippedLogin = YES;
//}
//
////Log user out
//-(void)logUserOut {
//    [PFUser logOut];
//    if (![PFUser currentUser]) {
//        NSLog(@"No user logged in");
//    }
//}
//
//#pragma mark - PFSignup Delegate methods from Parse login tutorial
//
////Sent to the delegate to determine whether the sign up request should be submitted to the server.
//-(BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
//    BOOL informationComplete = YES;
//    
//    //Double check connection
//    if (![connectionMGMT checkConnection]) {
//        [self noConnectionAlert:@"A network connection is required to sign in or create an account. Please check your network connection and try again"];
//        //[PFUser logOut];
//    } else {
//        // loop through all of the submitted data
//        for (id key in info) {
//            NSString *field = [info objectForKey:key];
//            if (!field || !field.length) { // check completion
//                informationComplete = NO;
//                break;
//            }
//        }
//    }
//    
//    // Display an alert if a field wasn't completed
//    if (!informationComplete) {
//        [[[UIAlertView alloc] initWithTitle:@"Missing Information"
//                                    message:@"Make sure you fill out all of the information!"
//                                   delegate:nil
//                          cancelButtonTitle:@"ok"
//                          otherButtonTitles:nil] show];
//    }
//    
//    return informationComplete;
//}
//
////Sent to the delegate when a PFUser is signed up.
//-(void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
//    [self dismissViewControllerAnimated:YES completion:NULL]; // Dismiss the PFSignUpViewController
//    //Update text of sign in label
//    mainMenuScene.signInLabel.text = @"Sign Out";
//}
//
////Sent to the delegate when the sign up attempt fails.
//-(void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
//    NSLog(@"Failed to sign up...");
//}
//
////Sent to the delegate when the sign up screen is dismissed.
//-(void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
//    NSLog(@"User dismissed the signUpViewController");
//}

-(int)incrementTotalDestroyed:(int)totalDestroyed {
    self.totalOfEnemiesDestroyed = self.totalOfEnemiesDestroyed + totalDestroyed;
    //NSLog(@"Total in increment: %d", self.totalOfEnemiesDestroyed);
    
    return self.totalOfEnemiesDestroyed;
}

@end
