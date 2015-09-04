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
#import "Reachability.h"
#import "ConnectionManagement.h"
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
    [self checkPlayerAndConnection];
    
}

-(void)checkPlayerAndConnection {
    //Make sure connection exists before checking for user
    if (![connectionMGMT checkConnection]) {
        [self noConnectionAlert:noConnectionMessage];
    } else {
        if (!userSkippedLogin) {
            //Authenticate the local player
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
                //Set achievements label to Blue
                [mainMenuScene setAchievemetsLabelColor];
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

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

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

-(int)incrementTotalDestroyed:(int)totalDestroyed {
    self.totalOfEnemiesDestroyed = self.totalOfEnemiesDestroyed + totalDestroyed;
    //NSLog(@"Total in increment: %d", self.totalOfEnemiesDestroyed);
    
    return self.totalOfEnemiesDestroyed;
}

@end
