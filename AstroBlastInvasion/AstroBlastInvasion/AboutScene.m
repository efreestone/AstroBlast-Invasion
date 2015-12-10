//
//  AboutScene.m
//  AstroBlastInvasion
//
//  Created by Elijah Freestone on 7/9/15.
//  Copyright (c) 2015 Elijah Freestone. All rights reserved.
//

#import "AboutScene.h"
#import "MainMenuScene.h"

@implementation AboutScene {
    SKColor *iOSBlueButtonColor;
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        //Set background
        SKSpriteNode *backgroundImage = [SKSpriteNode spriteNodeWithImageNamed:@"space"];
        backgroundImage.position = CGPointMake(self.size.width / 2, self.size.height / 2);
        [self addChild:backgroundImage];
        
        //Set color similar to the blue of default iOS button
        iOSBlueButtonColor = [SKColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0];
        
        //Adjust font size based on device
        CGFloat fontSize = 20;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            fontSize = 38;
        }
        
        //Create and set message label
        self.backLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
        self.backLabel.text = @"Menu";
        self.backLabel.name = @"backLabel";
        self.backLabel.fontColor = iOSBlueButtonColor;
        self.backLabel.fontSize = fontSize;
        self.backLabel.zPosition = 3;
        float backLabelPlacement = self.backLabel.frame.size.height + fontSize;
        self.backLabel.position = CGPointMake(backLabelPlacement, self.size.height - (fontSize * 1.25));
        [self addChild:self.backLabel];
        
        //Create about sentence labels
        SKLabelNode *aboutLabelOne = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
        aboutLabelOne.text = @"AstroBlaster is a project by Elijah Freestone";
        aboutLabelOne.fontColor = [SKColor whiteColor];
        aboutLabelOne.fontSize = fontSize;
        aboutLabelOne.zPosition = 3;
        aboutLabelOne.position = CGPointMake(self.size.width / 2, self.size.height * 0.6);
        [self addChild:aboutLabelOne];
        
        SKLabelNode *aboutLabelTwo = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
        aboutLabelTwo.text = @"for Mobile Game Design 1411 at Full Sail University,";
        aboutLabelTwo.fontColor = [SKColor whiteColor];
        aboutLabelTwo.fontSize = fontSize;
        aboutLabelTwo.zPosition = 3;
        aboutLabelTwo.position = CGPointMake(self.size.width / 2, self.size.height * 0.5);
        [self addChild:aboutLabelTwo];
        
        SKLabelNode *aboutLabelThree = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
        aboutLabelThree.text = @"created with SpriteKit and Objective-C";
        aboutLabelThree.fontColor = [SKColor whiteColor];
        aboutLabelThree.fontSize = fontSize;
        aboutLabelThree.position = CGPointMake(self.size.width / 2, self.size.height * 0.4);
        [self addChild:aboutLabelThree];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    //Check if touch point is Try Again label
    SKNode *touchedLabel = [self nodeAtPoint:location];
    
    if ([touchedLabel.name isEqual: @"backLabel"]) {
        self.backLabel.fontColor = [SKColor grayColor];
        return;
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    //Check if touch point is Try Again label
    SKNode *touchedLabel = [self nodeAtPoint:location];
    
    if ([touchedLabel.name isEqual: @"backLabel"]) {
        //Change label back to iOS blue
        self.backLabel.fontColor = iOSBlueButtonColor;
        _mainMenuScene.gameViewController = _gameViewController;
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        [self.view presentScene:_mainMenuScene transition: reveal];
    }
}

@end