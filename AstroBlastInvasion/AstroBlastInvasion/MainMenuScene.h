// Elijah Freestone
// IAD 1412
// Week 4
// December 14th, 2014

//
//  MainMenuScene.h
//  Project4
//
//  Created by Elijah Freestone on 12/14/14.
//  Copyright (c) 2014 Elijah Freestone. All rights reserved.
//

#import "GameViewController.h"
#import <SpriteKit/SpriteKit.h>
<<<<<<< HEAD
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <GameKit/GameKit.h>

@interface MainMenuScene : SKScene <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, GKGameCenterControllerDelegate>
=======
#import <GameKit/GameKit.h>

@interface MainMenuScene : SKScene
>>>>>>> workingbranch

//Declare labels which will act as a buttons
@property (strong, nonatomic) SKLabelNode *playButtonLabel;
@property (strong, nonatomic) SKLabelNode *howToPlayLabel;
@property (strong, nonatomic) SKLabelNode *aboutLabel;
@property (strong, nonatomic) SKLabelNode *leaderboardLabel;
@property (strong, nonatomic) SKLabelNode *achievementsLabel;

@property (weak, nonatomic) GameViewController *gameViewController;
@property (strong, nonatomic) SKColor *iOSBlueButtonColor;

//-(void)setTextOfSignInLabel;
-(void)setAchievemetsLabelColor;

@end
