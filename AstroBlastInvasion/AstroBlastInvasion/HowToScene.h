//
//  HowToScene.h
//  AstroBlastInvasion
//
//  Created by Elijah Freestone on 7/9/15.
//  Copyright (c) 2015 Elijah Freestone. All rights reserved.
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
