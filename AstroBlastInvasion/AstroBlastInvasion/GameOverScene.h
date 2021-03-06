//
//  GameOverScene.h
//  AstroBlastInvasion
//
//  Created by Elijah Freestone on 7/9/15.
//  Copyright (c) 2015 Elijah Freestone. All rights reserved.
//

#import "GameViewController.h"
#import "MainMenuScene.h"
#import <SpriteKit/SpriteKit.h>

@interface GameOverScene : SKScene <UITableViewDelegate, UITableViewDataSource>

//Create custom init to pass in playerWin bool and change display accordingly
-(id)initWithSize:(CGSize)size didPlayerWin:(BOOL)playerWin withScore:(float)playerScore;
-(void)noUserAlert;
-(void)achievementReceived:(NSString *)key withTitle:(NSString *)title;

//Declare play again label which will act as a button
@property (strong, nonatomic) SKLabelNode *playAgainLabel;
@property (strong, nonatomic) SKLabelNode *twitterLabel;

@property (weak, nonatomic) GameViewController *gameViewController;
@property (strong, nonatomic) MainMenuScene *mainMenuScene;
@property (nonatomic) BOOL achievementReceived;


@end
