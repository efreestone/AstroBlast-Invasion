// Elijah Freestone
// IAD 1412
// Week 4
// December 14th, 2014

//
//  GameOverScene.m
//  Project4
//
//  Created by Elijah Freestone on 12/14/14.
//  Copyright (c) 2014 Elijah Freestone. All rights reserved.
//

#import "GameOverScene.h"
#import "GameScene.h"
#import "ConnectionManagement.h"
#import "Reachability.h"
#import <Parse/Parse.h>
#import <Social/Social.h>

@interface GameOverScene ()

@property (strong, nonatomic) GameScene *gameScene;

@end

@implementation GameOverScene {
    ConnectionManagement *connectionMGMT;
    SKLabelNode *messageLabel;
    SKAction *waitDuration;
    SKAction *revealGameScene;
    SKColor *iOSBlueButtonColor;
    CGFloat fontSize;
    int roundedScore;
    NSString *soundFileName;
    NSString *messageString;
    NSString *parseClassName;
    NSString *deviceType;
    NSString *localUserName;
    NSString *usernameString;
    NSUserDefaults *userDefaults;
    
    NSMutableArray *achievementsArray;
    UITableView *achievementsTable;
}

//Use custom init to pass in playerWin bool and change display accordingly
-(id)initWithSize:(CGSize)size didPlayerWin:(BOOL)playerWin withScore:(float)playerScore{
    if (self = [super initWithSize:size]) {
        //Set background image. It looks like SpriteKit automatically uses the correct asset for the device type.
        SKSpriteNode *backgroundImage = [SKSpriteNode spriteNodeWithImageNamed:@"space"];
        backgroundImage.position = CGPointMake(self.size.width / 2, self.size.height / 2);
        [self addChild:backgroundImage];
        
        if (connectionMGMT == nil) {
            connectionMGMT = [[ConnectionManagement alloc] init];
        }
        
        achievementsArray = [[NSMutableArray alloc] init];
        
        //Check device
        deviceType = @"iPad";
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            deviceType = @"iPhone";
        }
        
        //Set Parse class name
        parseClassName = @"userScore";
        
        //Set color similar to the blue of default iOS button
        iOSBlueButtonColor = [SKColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0];
        
        //Set sound file and message to lose by default
        soundFileName = @"lose.caf";
        messageString = @"Sorry, you lost.";
        
        //Round score to nearest whole number
        roundedScore = (int)roundf(playerScore);
        
        //Create sound action to play win/lose sound
        SKAction *playSoundAction = [SKAction playSoundFileNamed:soundFileName waitForCompletion:NO];
        [self runAction:playSoundAction];
        
        //Adjust font size based on device
        fontSize = 40;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            fontSize = 75;
        }
        
        self.twitterLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
        self.twitterLabel.text = @"Post to Twitter";
        self.twitterLabel.fontColor = iOSBlueButtonColor;
        self.twitterLabel.fontSize = fontSize;
        self.twitterLabel.position = CGPointMake(self.size.width / 2, fontSize / 2);
        [self addChild:self.twitterLabel];
        
        if (playerWin) {
            //messageString = @"Congratulations, you won!";
            messageString = [NSString stringWithFormat:@"Final Score: %i points", roundedScore];
            soundFileName = @"win.caf";
            
            userDefaults = [NSUserDefaults standardUserDefaults];
            
            //NSLog(@"Total: %d", _gameViewController.totalOfEnemiesDestroyed);
            
            if ([PFUser currentUser]) {
                [self saveScoreToParse:roundedScore];
                //Check connection and change twitter button accordingly
                if (![connectionMGMT checkConnection]) {
                    self.twitterLabel.fontColor = [SKColor grayColor];
                } else {
                    self.twitterLabel.name = @"twitterLabel";
                }
            } else {
                userDefaults = [NSUserDefaults standardUserDefaults];
                self.twitterLabel.fontColor = [SKColor grayColor];
            }
        }
        
        CGFloat yMessageLabel = self.size.height * 0.6;
        CGFloat yPlayAgainLabel = self.size.height * 0.4;
        
        if (_achievementReceived) {
            yMessageLabel = self.size.height * 0.8;
            yPlayAgainLabel = self.size.height * 0.6;
        }
        
        //Create and set message label
        messageLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
        messageLabel.text = messageString;
        messageLabel.fontColor = [SKColor whiteColor];
        messageLabel.fontSize = fontSize;
        messageLabel.position = CGPointMake(self.size.width / 2, yMessageLabel);
        [self addChild:messageLabel];
        
        //Create play again label which will act as a button to restart game
        //Declared as a property in H
        self.playAgainLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
        self.playAgainLabel.text = @"Try again?";
        self.playAgainLabel.name = @"playAgainLabel";
        self.playAgainLabel.zPosition = 4;
        self.playAgainLabel.fontColor = iOSBlueButtonColor;
        self.playAgainLabel.fontSize = fontSize;
        self.playAgainLabel.position = CGPointMake(self.size.width / 2, yPlayAgainLabel);
        [self addChild:self.playAgainLabel];
        
        //Create actions to wait and go back to Game Scene
        waitDuration = [SKAction waitForDuration:0.05];
        revealGameScene = [SKAction runBlock:^{
            //Change label back to iOS blue
            self.playAgainLabel.fontColor = iOSBlueButtonColor;
            SKTransition *reveal = [SKTransition doorsCloseVerticalWithDuration:0.5];
            //Pass back game view controller and main menu scene for sign in issue
            _gameScene = [[GameScene alloc] initWithSize:self.size];
            _gameScene.gameViewController = _gameViewController;
            _gameScene.mainMenuScene = _mainMenuScene;
            [self.view presentScene:_gameScene transition: reveal];
        }];
    }
    return self;
}

//Use didMove to create tableview. Only added if achievements received
-(void)didMoveToView:(SKView *)view {
    //Get screen size and set frame for table. Used for both iPhone and iPad
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat screenHeight = self.view.bounds.size.height;
    CGFloat tableWidth = screenWidth * 0.5f;
    CGFloat tableHeight = (screenHeight * 0.6f) - 35.0f;
    
    //Create and place tableview
    achievementsTable = [[UITableView alloc] initWithFrame:CGRectMake(0,0, tableWidth, tableHeight)];
    achievementsTable.center = CGPointMake(screenWidth/2.0f, screenHeight * 0.75);
    achievementsTable.backgroundColor = [UIColor clearColor];
    achievementsTable.delegate = self;
    achievementsTable.dataSource = self;
    if (self.achievementReceived) {
        [self.view addSubview:achievementsTable];
    }
    
    //Create header for table view
    UIView *tableHeader = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tableWidth, 25.0f)];
    tableHeader.backgroundColor = [UIColor lightGrayColor];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, tableWidth, 25.0f)];
    nameLabel.text = @"Achievements Received";
    [tableHeader addSubview:nameLabel];
    [achievementsTable setTableHeaderView:tableHeader];
    achievementsTable.allowsSelection = NO;
    
    //Override to remove extra seperator lines after the last cell, no lines appear if no objects exist
    [achievementsTable setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0,0,0,0)]];
}

//Touch started. Change text color if touch is Retry label to simulate active state of a button
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    //Check if touch point is Try Again label
    SKNode *touchedLabel = [self nodeAtPoint:location];
    if ([touchedLabel.name isEqual: @"playAgainLabel"]) {
        //Change label color to signify touch
        self.playAgainLabel.fontColor = [SKColor grayColor];
        _gameScene.gameViewController = _gameViewController;
        return;
    }
}

//Touch end. Restart game if touch is retry label
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    //Check if touch point is Try Again label
    SKNode *touchedLabel = [self nodeAtPoint:location];
    if ([touchedLabel.name isEqual: @"playAgainLabel"]) {
        NSLog(@"touch ended");
        [achievementsTable removeFromSuperview];
        [self runAction:[SKAction sequence:@[waitDuration, revealGameScene]]];
        return;
    }
    //Twitter label
    if ([touchedLabel.name isEqual: @"twitterLabel"]) {
        NSLog(@"Twitter clicked");
        if ([connectionMGMT checkConnection]) {
            [self postToTwitter];
        } else {
            NSString *alertMessage = @"An internet connection is required to post to Twitter. Please check your connection and try again.";
            [self noConnectionAlert:alertMessage];
        }
    }
}

//Create and save a new score object to Parse
-(void)saveScoreToParse:(int)newScore {
    //Grab user and create and save PFObject
    PFUser *user = [PFUser currentUser];
    usernameString = [user objectForKey:@"username"];
    PFObject *newScoreObject = [PFObject objectWithClassName:parseClassName];
    newScoreObject[@"scoreUserName"] = usernameString;
    newScoreObject[@"newScore"] = [NSNumber numberWithInt:newScore];
    newScoreObject[@"deviceType"] = deviceType;
    
    //Check connection and save locally if it doesn't exist
    if (![connectionMGMT checkConnection]) {
        NSLog(@"No connection, saved locally");
        NSString *alertMessage = @"No connection is available so the score will only be saved locally.";
        userDefaults = [NSUserDefaults standardUserDefaults];
        [self noConnectionAlert:alertMessage];
        [self saveLocalScore:usernameString];
    } else {
        //NSLog(@"Connection exists, save to Parse");
        [newScoreObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"New score saved.");
            } else {
                NSLog(@"%@", error);
                //Error alert
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"An error occured trying to save. Please try again.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
            }
        }];
    }
}

//Post score to twitter
-(void)postToTwitter {
    //Create string with username and score
    NSString *tweetString = [NSString stringWithFormat: @"I just got a score of %d in AstroBlaster! Username: %@", roundedScore, usernameString];
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:tweetString];
        [_gameViewController presentViewController:tweetSheet animated:YES completion:nil];
    } else {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"There is no twitter account available on your device. Please check your account settings and try again", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    }
}

-(void)saveLocalScore:(NSString *)enteredUserName {
    NSLog(@"Save local: %@", enteredUserName);
    NSMutableArray *localScoresArray;
    NSData *dataOfScoresArray = [userDefaults objectForKey:@"localScoresArray"];
    if (dataOfScoresArray != nil) {
        NSArray *oldScoresArray = [NSKeyedUnarchiver unarchiveObjectWithData:dataOfScoresArray];
        if (oldScoresArray != nil) {
            localScoresArray = [[NSMutableArray alloc] initWithArray:oldScoresArray];
        }
    } else {
        localScoresArray = [[NSMutableArray alloc] init];
    }
    
    //NSDictionary *newLocalScore = [NSDictionary dictionaryWithObjectsAndKeys:keysArray, objectArray, nil];
    NSMutableDictionary *newLocalScore = [[NSMutableDictionary alloc] init];
    [newLocalScore setObject:enteredUserName forKey:@"scoreUserName"];
    [newLocalScore setObject:[NSNumber numberWithInt:roundedScore] forKey:@"newScore"];
    [newLocalScore setObject:deviceType forKey:@"deviceType"];

    [localScoresArray addObject:newLocalScore];
    
    NSData *newScoresData = [NSKeyedArchiver archivedDataWithRootObject:localScoresArray];
    
    [userDefaults setObject:newScoresData forKey:@"localScoresArray"];
    [userDefaults synchronize];
}

//Create and show alert view if there is no internet connectivity
-(void)noUserAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No User!"
                                                    message:@"No user is logged in so the score will only be saved locally. Please enter your initials and press save."
                                                   delegate:self
                                          cancelButtonTitle:@"Save"
                                          otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

-(void)noConnectionAlert:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Connection!" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    localUserName = [alertView textFieldAtIndex:0].text;
    //NSLog(@"%@", localUserName);
    if (localUserName.length != 0) {
        [self saveLocalScore:localUserName];
    }
}

-(void)achievementReceived:(NSString *)key withTitle:(NSString *)title {
    //Add title of achievements to array for display
    [achievementsArray addObject:title];
    NSLog(@"Achievements: %@", achievementsArray);
    _achievementReceived = YES;
    PFQuery *achievementQuery = [PFQuery queryWithClassName:@"achievements"];
    [achievementQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            object[key] = @YES;
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"New achievement saved.");
                } else {
                    NSLog(@"%@", error);
                    //Error alert
                    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"An error occured trying to save. Please try again.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
                }
            }];
        } else {
            NSLog(@"Error saving achievement");
        }
    }];
    //Change positions of existing labels to make room for the tableview
    messageLabel.position = CGPointMake(self.size.width / 2, self.size.height * 0.85);
    self.playAgainLabel.position = CGPointMake(self.size.width / 2, self.size.height * 0.7);
    self.twitterLabel.position = CGPointMake(self.size.width / 2, self.size.height * 0.55);
    
    //[self.view addSubview:achievementsTable];
    [achievementsTable reloadData];
    
}

#pragma mark - Table View Delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [achievementsArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSString *achievementTitle = [achievementsArray objectAtIndex:indexPath.row];
    
    static NSString *cellId = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    tableView.rowHeight = 44;
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.75f];
    cell.textLabel.text = [achievementsArray objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    return cell;
}

@end