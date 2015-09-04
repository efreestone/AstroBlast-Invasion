//
//  AboutScene.h
//  AstroBlastInvasion
//
//  Created by Elijah Freestone on 7/9/15.
//  Copyright (c) 2015 Elijah Freestone. All rights reserved.
//

#import "GameViewController.h"
#import "MainMenuScene.h"
#import <SpriteKit/SpriteKit.h>

@interface AboutScene : SKScene

@property (strong, nonatomic) SKLabelNode *backLabel;

@property (weak, nonatomic) GameViewController *gameViewController;
@property (strong, nonatomic) MainMenuScene *mainMenuScene;

@end
