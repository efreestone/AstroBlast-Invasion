// Elijah Freestone
// IAD 1412
// Week 4
// December 14th, 2014

//
//  HowToScene.h
//  Project4
//
//  Created by Elijah Freestone on 12/14/14.
//  Copyright (c) 2014 Elijah Freestone. All rights reserved.
//

#import "GameViewController.h"
#include "MainMenuScene.h"
#import <SpriteKit/SpriteKit.h>

@interface HowToScene : SKScene

@property (strong, nonatomic) SKLabelNode *backLabel;
@property (strong, nonatomic) SKLabelNode *nextLabel;
@property (strong, nonatomic) SKSpriteNode *backgroundImage;

@property (weak, nonatomic) GameViewController *gameViewController;
@property (strong, nonatomic) MainMenuScene *mainMenuScene;


@end
