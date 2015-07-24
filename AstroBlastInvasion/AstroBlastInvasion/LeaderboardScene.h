// Elijah Freestone
// IAD 1412
// Week 4
// December 14th, 2014

//
//  LeaderboardScene.h
//  Project4
//
//  Created by Elijah Freestone on 12/14/14.
//  Copyright (c) 2014 Elijah Freestone. All rights reserved.
//

#import "GameViewController.h"
#import "MainMenuScene.h"
#import <SpriteKit/SpriteKit.h>

@interface LeaderboardScene : SKScene <UITableViewDelegate, UITableViewDataSource>

-(void)queryParseForScores;
-(void)queryUserDefaults;
-(void)querryGameCenterForLeaderboard;

@property (strong, nonatomic) SKLabelNode *backLabel;
@property (strong, nonatomic) UITableView *leaderboardTableView;
@property (strong, nonatomic) NSArray *scoresArray;

@property (strong, nonatomic) SKLabelNode *allLabel;
@property (strong, nonatomic) SKLabelNode *iPadLabel;
@property (strong, nonatomic) SKLabelNode *iPhoneLabel;

@property (weak, nonatomic) GameViewController *gameViewController;
@property (strong, nonatomic) MainMenuScene *mainMenuScene;

@end
