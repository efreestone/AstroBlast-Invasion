//
//  GameViewController.h
//  AstroBlastInvasion
//

//  Copyright (c) 2015 Elijah Freestone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface GameViewController : UIViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

-(void)isUserLoggedIn;
-(int)incrementTotalDestroyed:(int)totalDestroyed;

@property (nonatomic) BOOL userSkippedLogin;
@property (nonatomic) int totalOfEnemiesDestroyed;


@end
