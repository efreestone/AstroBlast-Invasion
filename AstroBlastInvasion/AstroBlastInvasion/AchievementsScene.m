//
//  AchievementsScene.m
//  AstroBlastInvasion
//
//  Created by Elijah Freestone on 7/9/15.
//  Copyright (c) 2015 Elijah Freestone. All rights reserved.
//

#import "AchievementsScene.h"

@implementation AchievementsScene {
    SKColor *iOSBlueButtonColor;
    SKLabelNode *flawlessLabel;
    SKLabelNode *quickDrawLabel;
    SKLabelNode *halfDozenLabel;
    SKLabelNode *aDozenLabel;
    SKLabelNode *dozenAndAHalfLabel;
    SKLabelNode *lateBloomerLabel;
    
    NSString *flawlessKey;
    NSString *quickDrawKey;
    NSString *halfDozenKey;
    NSString *aDozenKey;
    NSString *dozenAndAHalfKey;
    NSString *lateBloomerKey;
    
    NSString *flawlessTitle;
    NSString *quickDrawTitle;
    NSString *halfDozenTitle;
    NSString *aDozenTitle;
    NSString *dozenAndAHalfTitle;
    NSString *lateBloomerTitle;
    
    NSString *flawlessDesc;
    NSString *quickDrawDesc;
    NSString *halfDozenDesc;
    NSString *aDozenDesc;
    NSString *dozenAndAHalfDesc;
    NSString *lateBloomerDesc;
    
    SKColor *flawlessColor;
    SKColor *quickDrawColor;
    SKColor *halfDozenColor;
    SKColor *aDozenColor;
    SKColor *dozenAndAHalfColor;
    SKColor *lateBloomerColor;
    
    BOOL flawlessBOOL;
    BOOL quickDrawBOOL;
    BOOL halfDozenBOOL;
    BOOL aDozenBool;
    BOOL dozenAndAHalfBOOL;
    BOOL lateBloomerBOOL;
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        //Set background image. It looks like SpriteKit automatically uses the correct asset for the device type.
        SKSpriteNode *backgroundImage = [SKSpriteNode spriteNodeWithImageNamed:@"space"];
        backgroundImage.position = CGPointMake(self.size.width / 2, self.size.height / 2);
        [self addChild:backgroundImage];
        
        //Set keys for achievements
        flawlessKey = @"Flawless_Achievement";
        quickDrawKey = @"Wheres_The_Fire";
        halfDozenKey = @"Half_Dozen";
        aDozenKey = @"One_Dozen";
        dozenAndAHalfKey = @"Dozen_And_Half";
        lateBloomerKey = @"Late_Bloomer";
        
        //Set titles
        flawlessTitle = @"Flawless Victory!";
        quickDrawTitle = @"Where's the fire?!";
        halfDozenTitle = @"Half a dozen down!";
        aDozenTitle = @"A whole dozen!";
        dozenAndAHalfTitle = @"Dozen and a half down!";
        lateBloomerTitle = @"We don't got all day.";
        
        //Set descriptions for achievements
        flawlessDesc = @"Beat the level without missing any enemy ships or any asteroids.";
        quickDrawDesc = @"Beat the level in 6 seconds or less.";
        halfDozenDesc = @"Destroy 6 enemy ships in a row without missing any.";
        aDozenDesc = @"Destroy 12 enemy ships in a row without missing any.";
        dozenAndAHalfDesc = @"Destroy 18 enemy ships in a row without missing any.";
        lateBloomerDesc = @"Take longer than 12 seconds to beat the level.";
        
        flawlessColor = [SKColor darkGrayColor];
        quickDrawColor = [SKColor darkGrayColor];
        halfDozenColor = [SKColor darkGrayColor];
        aDozenColor = [SKColor darkGrayColor];
        dozenAndAHalfColor = [SKColor darkGrayColor];
        lateBloomerColor = [SKColor darkGrayColor];
        
        //Adjust font size based on device
        CGFloat fontSize = 35;
        CGFloat labelGap = 22.5;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            fontSize = 70;
            labelGap = 45;
        }
        
        //Set color similar to the blue of default iOS button
        iOSBlueButtonColor = [SKColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0];
        
        //Create and set back label
        self.backLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
        self.backLabel.text = @"Menu";
        self.backLabel.name = @"backLabel";
        self.backLabel.zPosition = 2;
        self.backLabel.fontColor = iOSBlueButtonColor;
        self.backLabel.fontSize = fontSize * 0.5;
        float backLabelPlacement = self.backLabel.frame.size.height + fontSize * 0.5;
        self.backLabel.position = CGPointMake(backLabelPlacement, self.size.height - (fontSize * 0.6));
        [self addChild:self.backLabel];
        
        //Create and place labels
        SKLabelNode *titleLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
        titleLabel.text = @"Achievements (touch for description)";
        titleLabel.fontColor = [SKColor whiteColor];
        titleLabel.fontSize = fontSize * 0.5;
        float titleLabelHeightPlus = titleLabel.frame.size.height + fontSize / 5;
        titleLabel.position = CGPointMake(self.size.width / 2, self.size.height - titleLabelHeightPlus);
        [self addChild:titleLabel];
        
        flawlessLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
        flawlessLabel.text = flawlessTitle;
        flawlessLabel.name = @"flawlessLabel";
        flawlessLabel.fontColor = flawlessColor;
        flawlessLabel.fontSize = fontSize;
        flawlessLabel.position = CGPointMake(self.size.width / 2, self.size.height * 0.8);
        [self addChild:flawlessLabel];
        
        quickDrawLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
        quickDrawLabel.text = quickDrawTitle;
        quickDrawLabel.name = @"quickDrawLabel";
        quickDrawLabel.fontColor = quickDrawColor;
        quickDrawLabel.fontSize = fontSize;
        quickDrawLabel.position = CGPointMake(self.size.width / 2, self.size.height * 0.65);
        [self addChild:quickDrawLabel];
        
        halfDozenLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
        halfDozenLabel.text = halfDozenTitle;
        halfDozenLabel.name = @"halfDozenLabel";
        halfDozenLabel.fontColor = halfDozenColor;
        halfDozenLabel.fontSize = fontSize;
        halfDozenLabel.position = CGPointMake(self.size.width / 2, self.size.height * 0.5);
        [self addChild:halfDozenLabel];
        
        aDozenLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
        aDozenLabel.text = aDozenTitle;
        aDozenLabel.name = @"aDozenLabel";
        aDozenLabel.fontColor = aDozenColor;
        aDozenLabel.fontSize = fontSize;
        aDozenLabel.position = CGPointMake(self.size.width / 2, self.size.height * 0.35);
        [self addChild:aDozenLabel];
        
        dozenAndAHalfLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
        dozenAndAHalfLabel.text = dozenAndAHalfTitle;
        dozenAndAHalfLabel.name = @"dozenAndAHalfLabel";
        dozenAndAHalfLabel.fontColor = dozenAndAHalfColor;
        dozenAndAHalfLabel.fontSize = fontSize;
        dozenAndAHalfLabel.position = CGPointMake(self.size.width / 2, self.size.height * 0.2);
        [self addChild:dozenAndAHalfLabel];
        
        lateBloomerLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
        lateBloomerLabel.text = lateBloomerTitle;
        lateBloomerLabel.name = @"lateBloomerLabel";
        lateBloomerLabel.fontColor = lateBloomerColor;
        lateBloomerLabel.fontSize = fontSize;
        lateBloomerLabel.position = CGPointMake(self.size.width / 2, self.size.height * 0.05);
        [self addChild:lateBloomerLabel];
    }
    return self;
}

//Query Game Center for achievements for the user
-(void)queryGameCenterForAchievements {
    [GKAchievement loadAchievementsWithCompletionHandler: ^(NSArray *scores, NSError *error) {
        if (!error) {
            NSLog(@"Achievements = %@", scores);
            for (GKAchievement* achievement in scores) {
                //Check for each achievement and set bools accordingly
                //Flawless
                if ([achievement.identifier isEqualToString:flawlessKey]) {
                    flawlessBOOL = YES;
                    //NSLog(@"Flawless Exists");
                }
                //Quickdraw
                if ([achievement.identifier isEqualToString:quickDrawKey]) {
                    quickDrawBOOL = YES;
                    //NSLog(@"Quickdraw Exists");
                }
                //Half Dozen
                if ([achievement.identifier isEqualToString:halfDozenKey]) {
                    halfDozenBOOL = YES;
                    //NSLog(@"Half Dozen Exists");
                }
                //One Dozen
                if ([achievement.identifier isEqualToString:aDozenKey]) {
                    aDozenBool = YES;
                    //NSLog(@"One Dozen Exists");
                }
                //Dozen and Half
                if ([achievement.identifier isEqualToString:dozenAndAHalfKey]) {
                    dozenAndAHalfBOOL = YES;
                    //NSLog(@"Dozen and a Half Exists");
                }
                //Late Bloomer
                if ([achievement.identifier isEqualToString:lateBloomerKey]) {
                    lateBloomerBOOL = YES;
                    //NSLog(@"Late Bloomer Exists");
                }
            }
        } else {
            NSLog(@"Achievement Error: %@", [error localizedDescription]);
        }
        //Change label color for achievements completed
        [self setLabelColors];
    }];
}

//Set label color to green for achievements received
-(void)setLabelColors {
    if (flawlessBOOL) {
        flawlessColor = [SKColor greenColor];
        flawlessLabel.fontColor = flawlessColor;
    }
    if (quickDrawBOOL) {
        quickDrawColor = [SKColor greenColor];
        quickDrawLabel.fontColor = quickDrawColor;
    }
    if (halfDozenBOOL) {
        halfDozenColor = [SKColor greenColor];
        halfDozenLabel.fontColor = halfDozenColor;
    }
    if (aDozenBool) {
        aDozenColor = [SKColor greenColor];
        aDozenLabel.fontColor = aDozenColor;
    }
    if (dozenAndAHalfBOOL) {
        dozenAndAHalfColor = [SKColor greenColor];
        dozenAndAHalfLabel.fontColor = dozenAndAHalfColor;
    }
    if (lateBloomerBOOL) {
        lateBloomerColor = [SKColor greenColor];
        lateBloomerLabel.fontColor = lateBloomerColor;
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    //Check if touch point is Try Again label
    SKNode *touchedLabel = [self nodeAtPoint:location];
    
    //Menu Label
    if ([touchedLabel.name isEqual: @"backLabel"]) {
        self.backLabel.fontColor = [SKColor grayColor];
        return;
    }
    
    //Flawless
    if ([touchedLabel.name isEqual: @"flawlessLabel"]) {
        flawlessLabel.fontColor = [SKColor grayColor];
        return;
    }
    
    //Quick Draw
    if ([touchedLabel.name isEqual: @"quickDrawLabel"]) {
        quickDrawLabel.fontColor = [SKColor grayColor];
        return;
    }
    
    //Half Dozen
    if ([touchedLabel.name isEqual: @"halfDozenLabel"]) {
        halfDozenLabel.fontColor = [SKColor grayColor];
        return;
    }
    
    //One Dozen
    if ([touchedLabel.name isEqual: @"aDozenLabel"]) {
        aDozenLabel.fontColor = [SKColor grayColor];
        return;
    }
    
    //Dozen and a Half
    if ([touchedLabel.name isEqual: @"dozenAndAHalfLabel"]) {
        dozenAndAHalfLabel.fontColor = [SKColor grayColor];
        return;
    }
    
    //Late Bloomer
    if ([touchedLabel.name isEqual: @"lateBloomerLabel"]) {
        lateBloomerLabel.fontColor = [SKColor grayColor];
        return;
    }
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    //Check if touch point is Try Again label
    SKNode *touchedLabel = [self nodeAtPoint:location];
    
    if ([touchedLabel.name isEqual: @"backLabel"]) {
        self.backLabel.fontColor = iOSBlueButtonColor;
        _mainMenuScene.gameViewController = _gameViewController;
        SKTransition *reveal = [SKTransition doorwayWithDuration:0.5];
        [self.view presentScene:_mainMenuScene transition: reveal];
    }
    
    //Flawless
    if ([touchedLabel.name isEqual: @"flawlessLabel"]) {
        flawlessLabel.fontColor = flawlessColor;
        [self showDescAlert:flawlessDesc withTitle:flawlessTitle];
        return;
    }
    
    //Quick Draw
    if ([touchedLabel.name isEqual: @"quickDrawLabel"]) {
        quickDrawLabel.fontColor = quickDrawColor;
        [self showDescAlert:quickDrawDesc withTitle:quickDrawTitle];
        return;
    }
    
    //Half Dozen
    if ([touchedLabel.name isEqual: @"halfDozenLabel"]) {
        halfDozenLabel.fontColor = halfDozenColor;
        [self showDescAlert:halfDozenDesc withTitle:halfDozenTitle];
        return;
    }
    
    //One Dozen
    if ([touchedLabel.name isEqual: @"aDozenLabel"]) {
        aDozenLabel.fontColor = aDozenColor;
        [self showDescAlert:aDozenDesc withTitle:aDozenTitle];
        return;
    }
    
    //Dozen and a Half
    if ([touchedLabel.name isEqual: @"dozenAndAHalfLabel"]) {
        dozenAndAHalfLabel.fontColor = dozenAndAHalfColor;
        [self showDescAlert:dozenAndAHalfDesc withTitle:dozenAndAHalfTitle];
        return;
    }
    
    //Late Bloomer
    if ([touchedLabel.name isEqual: @"lateBloomerLabel"]) {
        lateBloomerLabel.fontColor = lateBloomerColor;
        [self showDescAlert:lateBloomerDesc withTitle:lateBloomerTitle];
        return;
    }
}

//Create and display alert with title and description of achievement
-(void)showDescAlert:(NSString *)description withTitle:(NSString *)title {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

@end
