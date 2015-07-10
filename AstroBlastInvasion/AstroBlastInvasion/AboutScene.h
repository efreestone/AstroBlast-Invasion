// Elijah Freestone
// IAD 1412
// Week 4
// December 14th, 2014

//
//  AboutScene.h
//  Project4
//
//  Created by Elijah Freestone on 12/14/14.
//  Copyright (c) 2014 Elijah Freestone. All rights reserved.
//

#import "GameViewController.h"
#import "MainMenuScene.h"
#import <SpriteKit/SpriteKit.h>

@interface AboutScene : SKScene

@property (strong, nonatomic) SKLabelNode *backLabel;

@property (weak, nonatomic) GameViewController *gameViewController;
@property (strong, nonatomic) MainMenuScene *mainMenuScene;

@end
