// Elijah Freestone
// IAD 1412
// Week 4
// December 16th, 2014

//
//  AchievementsScene.h
//  Project4
//
//  Created by Elijah Freestone on 12/16/14.
//  Copyright (c) 2014 Elijah Freestone. All rights reserved.
//

#import "GameViewController.h"
#import "MainMenuScene.h"
#import <SpriteKit/SpriteKit.h>

@interface AchievementsScene : SKScene

@property (strong, nonatomic) SKLabelNode *backLabel;

@property (weak, nonatomic) GameViewController *gameViewController;
@property (strong, nonatomic) MainMenuScene *mainMenuScene;

-(void)queryGameCenterForAchievements;

@end
