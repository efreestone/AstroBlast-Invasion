// Elijah Freestone
// IAD 1412
// Week 4
// December 14th, 2014

//
//  MainMenuScene.m
//  Project4
//
//  Created by Elijah Freestone on 12/14/14.
//  Copyright (c) 2014 Elijah Freestone. All rights reserved.
//

#import "MainMenuScene.h"
#import "GameScene.h"
#import "GameViewController.h"
#import "HowToScene.h"
#import "AboutScene.h"
#import "LeaderboardScene.h"
#import "CustomPFLoginViewController.h"
#import "CustomPFSignUpViewController.h"
#import "ConnectionManagement.h"
#import "AchievementsScene.h"

@interface MainMenuScene ()

@property (strong, nonatomic) GameScene *gameScene;
@property (strong, nonatomic) HowToScene *howToScene;
@property (strong, nonatomic) AboutScene *aboutScene;
@property (strong, nonatomic) LeaderboardScene *leaderboardScene;
@property (strong, nonatomic) AchievementsScene *achievementsScene;

@end

@implementation MainMenuScene {
    ConnectionManagement *connectionMGMT;
    SKAction *waitDuration;
    SKAction *revealGameScene;
    SKAction *revealHowToScene;
    SKAction *revealAboutScene;
    SKAction *revealLeaderboardScene;
    SKAction *revealAchievementsScene;
    UIViewController *viewController;
    BOOL connectionExists;
    NSString *signInString;
    PFQuery *scoresQuery;
}

//Synthesize for getters/setters
@synthesize signInLabel;

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        signInString = @"Sign In";
        
        if (connectionMGMT == nil) {
            connectionMGMT = [[ConnectionManagement alloc] init];
        }
        
        connectionExists = [connectionMGMT checkConnection];
        
        SKSpriteNode *backgroundImage = [SKSpriteNode spriteNodeWithImageNamed:@"space"];
        backgroundImage.position = CGPointMake(self.size.width / 2, self.size.height / 2);
        [self addChild:backgroundImage];
        
        //Set color similar to the blue of default iOS button
        self.iOSBlueButtonColor = [SKColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0];
        
        //Adjust font size based on device
        CGFloat fontSize = 40;
        CGFloat labelGap = 22.5;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            fontSize = 75;
            labelGap = 45;
        }
        
//        float labelGapFromFont = fontSize / 2.65;
        
//        //Create and set sign in label. Will be modified to say Sign Out when user is logged in
//        signInLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
//        //signInLabel.text = signInString;
//        signInLabel.name = @"signInLabel";
//        signInLabel.fontColor = [SKColor whiteColor];
//        signInLabel.fontSize = fontSize / 2.65;
//        signInLabel.position = CGPointMake(labelGapFromFont, self.size.height - labelGap);
//        signInLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
//        
//        //Change sign in label to sign out if user is already logged in.
//        //This is to fix issue in iPhone sim when game is launched with user already logged in
//        [self setTextOfSignInLabel];
//
//        [self addChild:signInLabel];
        
        //Create and set message label
        SKLabelNode *titleLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
        titleLabel.text = @"AstroBlast Invasion";
        titleLabel.fontColor = [SKColor whiteColor];
        titleLabel.fontSize = fontSize * 0.75;
        float titleLabelHeightPlus = titleLabel.frame.size.height + fontSize / 2;
        titleLabel.position = CGPointMake(self.size.width / 2, self.size.height - titleLabelHeightPlus);
        [self addChild:titleLabel];
        
        //Create play button label
        self.playButtonLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
        self.playButtonLabel.text = @"Play Game";
        self.playButtonLabel.name = @"playButtonLabel";
        self.playButtonLabel.fontColor = self.iOSBlueButtonColor;
        self.playButtonLabel.fontSize = fontSize;
        self.playButtonLabel.position = CGPointMake(self.size.width / 2, self.size.height * 0.7);
        [self addChild:self.playButtonLabel];
        
        //Create how to (tutorial) button label
        self.howToPlayLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
        self.howToPlayLabel.text = @"How To Play";
        self.howToPlayLabel.name = @"howToPlayLabel";
        self.howToPlayLabel.fontColor = self.iOSBlueButtonColor;
        self.howToPlayLabel.fontSize = fontSize;
        self.howToPlayLabel.position = CGPointMake(self.size.width / 2, self.size.height * 0.55);
        [self addChild:self.howToPlayLabel];
        
        //Create about button label
        self.aboutLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
        self.aboutLabel.text = @"About";
        self.aboutLabel.name = @"aboutLabel";
        self.aboutLabel.fontColor = self.iOSBlueButtonColor;
        self.aboutLabel.fontSize = fontSize;
        self.aboutLabel.position = CGPointMake(self.size.width / 2, self.size.height * 0.4);
        [self addChild:self.aboutLabel];
        
        //Create leaderboard button label
        self.leaderboardLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
        self.leaderboardLabel.text = @"Leaderboard";
        self.leaderboardLabel.name = @"leaderboardLabel";
        self.leaderboardLabel.fontColor = self.iOSBlueButtonColor;
        self.leaderboardLabel.fontSize = fontSize;
        self.leaderboardLabel.position = CGPointMake(self.size.width / 2, self.size.height * 0.25);
        [self addChild:self.leaderboardLabel];
        
        //Create achievements button label
        self.achievementsLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
        self.achievementsLabel.text = @"Achievements";
        self.achievementsLabel.name = @"achievementsLabel";
        if ([PFUser currentUser] && [connectionMGMT checkConnection]) {
            self.achievementsLabel.fontColor = self.iOSBlueButtonColor;
        } else {
            self.achievementsLabel.fontColor = [SKColor darkGrayColor];
        }
        self.achievementsLabel.fontSize = fontSize;
        self.achievementsLabel.position = CGPointMake(self.size.width / 2, self.size.height * 0.1);
        [self addChild:self.achievementsLabel];
        
        //Alloc scenes
        _gameScene = [[GameScene alloc] initWithSize:self.size];
        _howToScene = [[HowToScene alloc] initWithSize:self.size];
        _aboutScene = [[AboutScene alloc] initWithSize:self.size];
        _leaderboardScene = [[LeaderboardScene alloc] initWithSize:self.size];
        _achievementsScene = [[AchievementsScene alloc] initWithSize:self.size];
        
        //Create actions to wait and go to appropriate scene
        waitDuration = [SKAction waitForDuration:0.05];
        revealGameScene = [SKAction runBlock:^{
            //If game scene already exists, init new to restart
            if (_gameScene != nil) {
                _gameScene = [[GameScene alloc] initWithSize:self.size];
            }
            //Change label back to iOS blue
            self.playButtonLabel.fontColor = self.iOSBlueButtonColor;
            SKTransition *reveal = [SKTransition doorsOpenVerticalWithDuration:0.5];
            [self.view presentScene:_gameScene transition:reveal];
            //self.gameViewController.userSkippedLogin = NO;
            _gameScene.gameViewController = _gameViewController;
            _gameScene.mainMenuScene = self;
        }];
        revealHowToScene = [SKAction runBlock:^{
            //Change label back to iOS blue
            self.howToPlayLabel.fontColor = self.iOSBlueButtonColor;
            SKTransition *reveal = [SKTransition flipVerticalWithDuration:0.5];
            [self.view presentScene:_howToScene transition:reveal];
            _howToScene.gameViewController = _gameViewController;
            _howToScene.mainMenuScene = self;
        }];
        revealAboutScene = [SKAction runBlock:^{
            //Change label back to iOS blue
            self.aboutLabel.fontColor = self.iOSBlueButtonColor;
            SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
            [self.view presentScene:_aboutScene transition:reveal];
            _aboutScene.gameViewController = _gameViewController;
            _aboutScene.mainMenuScene = self;
        }];
        revealLeaderboardScene = [SKAction runBlock:^{
            //Change label back to iOS blue
            self.leaderboardLabel.fontColor = self.iOSBlueButtonColor;
            SKTransition *reveal = [SKTransition doorsOpenHorizontalWithDuration:0.5];
            [self.view presentScene:_leaderboardScene transition:reveal];
            _leaderboardScene.gameViewController = _gameViewController;
            _leaderboardScene.mainMenuScene = self;
        }];
        revealAchievementsScene = [SKAction runBlock:^{
            //Change label back to iOS blue
            self.achievementsLabel.fontColor = self.iOSBlueButtonColor;
            SKTransition *reveal = [SKTransition doorwayWithDuration:0.5];
            [self.view presentScene:_achievementsScene transition:reveal];
            _achievementsScene.gameViewController = _gameViewController;
            _achievementsScene.mainMenuScene = self;
        }];
    }
    return self;
}

//Query parse for scores
-(void)queryParseForScores {
    scoresQuery = [PFQuery queryWithClassName:@"userScore"];
    [scoresQuery orderByAscending:@"newScore"];
    [scoresQuery findObjectsInBackgroundWithBlock:^(NSArray *scores, NSError *error) {
        
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu scores.", (unsigned long)scores.count);
            
            _leaderboardScene.scoresArray = [[NSArray alloc] initWithArray:scores];
            //_leaderboardScene.scoresArray = scores;
            [self runAction:[SKAction sequence:@[waitDuration, revealLeaderboardScene]]];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    //Check if touch point is Try Again label
    SKNode *touchedLabel = [self nodeAtPoint:location];
    
    //Sign in/out button
    if ([touchedLabel.name isEqual:@"signInLabel"]) {
        if ([signInLabel.text isEqualToString:@"Sign In"]) {
            NSLog(@"Sign In Pressed");
            
        } else {
            NSLog(@"Sign Out Pressed");
        }
    }
    
    //Play button label
    if ([touchedLabel.name isEqual: @"playButtonLabel"]) {
        self.playButtonLabel.fontColor = [SKColor grayColor];
        return;
    }
    
    //How to button label
    if ([touchedLabel.name isEqual: @"howToPlayLabel"]) {
        self.howToPlayLabel.fontColor = [SKColor grayColor];
        return;
    }
    
    //About button label
    if ([touchedLabel.name isEqual: @"aboutLabel"]) {
        self.aboutLabel.fontColor = [SKColor grayColor];
        return;
    }
    
    //Leaderboard button label
    if ([touchedLabel.name isEqual: @"leaderboardLabel"]) {
        self.leaderboardLabel.fontColor = [SKColor grayColor];
        return;
    }
    
    if ([touchedLabel.name isEqual: @"achievementsLabel"]) {
        self.achievementsLabel.fontColor = [SKColor grayColor];
        return;
    }
}

//Touch end. Check label
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    //Check if touch point is Try Again label
    SKNode *touchedLabel = [self nodeAtPoint:location];
    
//    //Sign in/out button
//    if ([touchedLabel.name isEqual: @"signInLabel"]) {
//        
//        if ([signInLabel.text isEqualToString:@"Sign In"]) {
//            NSLog(@"Sign In Pressed");
//            //Check connection and present login if exists
//            if ([connectionMGMT checkConnection]) {
//                //[self.gameViewController isUserLoggedIn];
//                [self.gameViewController authGameCenterLocalPlayer];
//            } else {
//                NSString *signInMessage = @"No network connection available. Internet is required to sign in. Please check your connection and try again.";
//                [self noConnectionAlert:signInMessage];
//            }
//        } else {
//            NSLog(@"Sign Out Pressed");
//            [PFUser logOut];
//            //[self.gameViewController isUserLoggedIn];
//            signInLabel.text = signInString;
//            self.achievementsLabel.fontColor = [SKColor darkGrayColor];
//            _achievementsScene = [[AchievementsScene alloc] initWithSize:self.size];
//        }
//    }
    
    //Play button label
    if ([touchedLabel.name isEqual: @"playButtonLabel"]) {
        [self runAction:[SKAction sequence:@[waitDuration, revealGameScene]]];
        return;
    }
    
    //How to button label
    if ([touchedLabel.name isEqual: @"howToPlayLabel"]) {
        [self runAction:[SKAction sequence:@[waitDuration, revealHowToScene]]];
        return;
    }
    
    //About button label
    if ([touchedLabel.name isEqual: @"aboutLabel"]) {
        [self runAction:[SKAction sequence:@[waitDuration, revealAboutScene]]];
        return;
    }
    
    //Leaderboard button label
    if ([touchedLabel.name isEqual: @"leaderboardLabel"]) {
        //[self queryParseForScores];
        if ([connectionMGMT checkConnection] && [PFUser currentUser]) {
            [_leaderboardScene queryParseForScores];
            [self runAction:[SKAction sequence:@[waitDuration, revealLeaderboardScene]]];
        } else {
            self.leaderboardLabel.fontColor = self.iOSBlueButtonColor;
            NSString *noConnectString;
            //Check user and connection, notify and initial user defaults
            if (![PFUser currentUser] && ![connectionMGMT checkConnection]) { //No connection and no user
                noConnectString = @"No user is signed in and no network connection is available. Only the local leaderboard will be shown if one is available";
            } else if (![PFUser currentUser]) { //No user logged in
                noConnectString = @"No user is signed in. Only the local leaderboard will be shown if one is available";
            //No conection
            } else {
                noConnectString = @"No network connection is available. Only the local leaderboard will be shown if one is available";
            }
            
            [self noConnectionAlert:noConnectString];
            
            [self runAction:[SKAction sequence:@[waitDuration, revealLeaderboardScene]]];
            [_leaderboardScene queryUserDefaults];
        }
        return;
    }
    
    if ([touchedLabel.name isEqual: @"achievementsLabel"]) {
        if ([PFUser currentUser] && [connectionMGMT checkConnection]) {
            [_achievementsScene queryParseForAchievements];
            [self runAction:[SKAction sequence:@[waitDuration, revealAchievementsScene]]];
        } else {
            NSString *achievementMessage = @"A user must be logged in and a network connection must be available to view the achievements. Please log in and/or check your internet connection before trying again";
            [self noConnectionAlert:achievementMessage];
            self.achievementsLabel.fontColor = [SKColor darkGrayColor];
        }
    }
}

//Create and show alert view if there is no internet connectivity
-(void)noConnectionAlert:(NSString *)alertMessage {
    UIAlertView *connectionAlert = [[UIAlertView alloc] initWithTitle:@"Error!"
        message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //Show alert
    [connectionAlert show];
} //noConnectionAlert close

-(void)setTextOfSignInLabel {
    NSString *labelString = signInString;
    if ([PFUser currentUser]) {
        labelString = @"Sign Out";
    }
    signInLabel.text = labelString;
}

@end
