//
//  LeaderboardScene.h
//  AstroBlastInvasion
//
//  Created by Elijah Freestone on 7/9/15.
//  Copyright (c) 2015 Elijah Freestone. All rights reserved.
//

#import "GameViewController.h"
#import "MainMenuScene.h"
#import <SpriteKit/SpriteKit.h>

@interface LeaderboardScene : SKScene <UITableViewDelegate, UITableViewDataSource>

-(void)queryUserDefaults;
-(void)querryGameCenterForLeaderboard;

@property (strong, nonatomic) SKLabelNode *backLabel;
@property (strong, nonatomic) UITableView *leaderboardTableView;
@property (strong, nonatomic) NSArray *scoresArray;
@property (nonatomic) BOOL playerAndConnectionExist;

@property (strong, nonatomic) SKLabelNode *allLabel;
@property (strong, nonatomic) SKLabelNode *iPadLabel;
@property (strong, nonatomic) SKLabelNode *iPhoneLabel;

@property (weak, nonatomic) GameViewController *gameViewController;
@property (strong, nonatomic) MainMenuScene *mainMenuScene;

@end
