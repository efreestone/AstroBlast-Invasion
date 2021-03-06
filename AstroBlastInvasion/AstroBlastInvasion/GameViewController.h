//
//  GameViewController.h
//  AstroBlastInvasion
//
//  Created by Elijah Freestone on 7/9/15.
//  Copyright (c) 2015 Elijah Freestone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>

@interface GameViewController : UIViewController

//-(void)isUserLoggedIn;
-(void)authGameCenterLocalPlayer;
-(int)incrementTotalDestroyed:(int)totalDestroyed;
-(void)checkPlayerAndConnection:(NSString *)from;

@property (nonatomic) BOOL userSkippedLogin;
@property (nonatomic) int totalOfEnemiesDestroyed;

@property (nonatomic) BOOL gameCenterEnabled;
@property (strong, nonatomic) NSString *leaderboardIdentifier;


@end
