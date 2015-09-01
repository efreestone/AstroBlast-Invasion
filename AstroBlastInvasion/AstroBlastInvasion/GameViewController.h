//
//  GameViewController.h
//  AstroBlastInvasion
//

//  Copyright (c) 2015 Elijah Freestone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>

@interface GameViewController : UIViewController

//-(void)isUserLoggedIn;
-(void)authGameCenterLocalPlayer;
-(int)incrementTotalDestroyed:(int)totalDestroyed;
-(void)checkPlayerAndConnection;

@property (nonatomic) BOOL userSkippedLogin;
@property (nonatomic) int totalOfEnemiesDestroyed;

@property (nonatomic) BOOL gameCenterEnabled;
@property (strong, nonatomic) NSString *leaderboardIdentifier;


@end
