//
//  LeaderboardScene.m
//  AstroBlastInvasion
//
//  Created by Elijah Freestone on 7/9/15.
//  Copyright (c) 2015 Elijah Freestone. All rights reserved.
//

#import "LeaderboardScene.h"
#import "CustomTableViewCell.h"
#import "ConnectionManagement.h"

@implementation LeaderboardScene {
    SKColor *iOSBlueButtonColor;
    CustomTableViewCell *customCell;
    ConnectionManagement *connectionMGMT;
    NSMutableArray *allScoresArray;
    NSMutableArray *iPadArray;
    NSMutableArray *iPhoneArray;
    NSUserDefaults *userDefaults;
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        //init connection manager
        if (connectionMGMT == nil) {
            connectionMGMT = [[ConnectionManagement alloc] init];
        }
        userDefaults = [NSUserDefaults standardUserDefaults];
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
        
        allScoresArray = [[NSMutableArray alloc] init];
        iPhoneArray = [[NSMutableArray alloc] init];
        iPadArray = [[NSMutableArray alloc] init];
        
<<<<<<< HEAD
//        CGFloat deviceWidth = self.size.width;
        
=======
>>>>>>> workingbranch
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
<<<<<<< HEAD
        
//        //Create and set all label
//        self.allLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
//        self.allLabel.text = @"All Scores";
//        self.allLabel.name = @"allLabel";
//        self.allLabel.fontColor = [SKColor grayColor];
//        self.allLabel.fontSize = fontSize;
//        float allLabelPlacement = deviceWidth * 0.25f;
//        self.allLabel.position = CGPointMake(allLabelPlacement, self.size.height - (fontSize * 1.25));
//        [self addChild:self.allLabel];
//        
//        //Create and set iPone label
//        self.iPhoneLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
//        self.iPhoneLabel.text = @"iPhone Only";
//        self.iPhoneLabel.name = @"iPhoneLabel";
//        self.iPhoneLabel.fontColor = iOSBlueButtonColor;
//        self.iPhoneLabel.fontSize = fontSize;
//        float iPhoneLabelPlacement = deviceWidth * 0.5f;
//        self.iPhoneLabel.position = CGPointMake(iPhoneLabelPlacement, self.size.height - (fontSize * 1.25));
//        [self addChild:self.iPhoneLabel];
//        
//        //Create and set iPad label
//        self.iPadLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
//        self.iPadLabel.text = @"iPad Only";
//        self.iPadLabel.name = @"iPadLabel";
//        self.iPadLabel.fontColor = iOSBlueButtonColor;
//        self.iPadLabel.fontSize = fontSize;
//        float iPadLabelPlacement = deviceWidth * 0.75f;
//        self.iPadLabel.position = CGPointMake(iPadLabelPlacement, self.size.height - (fontSize * 1.25));
//        [self addChild:self.iPadLabel];
=======
>>>>>>> workingbranch
    }
    return self;
}

//Check user defaults for local scores and display if any exist
-(void)queryUserDefaults {
    NSMutableArray *unsortedArray = [[NSMutableArray alloc] init];
    NSMutableArray *sortedScoresArray = [[NSMutableArray alloc] init];
    NSData *dataOfScoresArray = [userDefaults objectForKey:@"localScoresArray"];
    if (dataOfScoresArray != nil) {
        //Pass NSData of score into unsorted array
        unsortedArray = [NSKeyedUnarchiver unarchiveObjectWithData:dataOfScoresArray];
        //Sort scores in descending order
        NSSortDescriptor *scoreDescriptor = [[NSSortDescriptor alloc] initWithKey:@"newScore" ascending:NO];
        NSArray *sortDescriptors = [NSArray arrayWithObject:scoreDescriptor];
        NSArray *sortedArray = [unsortedArray sortedArrayUsingDescriptors:sortDescriptors];
        //Cast sorted array to mutable array
        sortedScoresArray = (NSMutableArray *) sortedArray;
        //NSLog(@"Local Array: %@", localScoresArray);
    } else {
        NSLog(@"Data nil");
    }
    
    //Pass the sorted local scores array to the main array that feeds the table and the master array
    allScoresArray = sortedScoresArray;
    self.scoresArray = sortedScoresArray;
    [_leaderboardTableView reloadData];
}

//Use didMove to set up tableview
-(void)didMoveToView:(SKView *)view {
    //Get screen size and set frame for table. Used for both iPhone and iPad
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat screenHeight = self.view.bounds.size.height;
    CGFloat tableWidth = screenWidth * 0.65f;
    CGFloat tableHeight = (screenHeight *0.9f) + 35.0f;
    
    //Add UITableView to scene
    _leaderboardTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0, tableWidth, tableHeight)];
    _leaderboardTableView.center = CGPointMake(screenWidth/2.0f, screenHeight/2.0f + 25.0f);
    _leaderboardTableView.backgroundColor = [UIColor clearColor];
    _leaderboardTableView.delegate = self;
    _leaderboardTableView.dataSource = self;
    [self.view addSubview:_leaderboardTableView];
    
    //Grab measurements of table and adjust to align header labels better with custom cell
    CGFloat tableThird = tableWidth / 3;
    CGFloat middleOfThird = tableThird / 2;
    CGFloat firstLabelX = middleOfThird - 25.0f;
    CGFloat thirdLabelX = (tableThird * 2) + middleOfThird - 30.0f;
    //Create header for table view
    UIView *tableHeader = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tableWidth, 25.0f)];
    tableHeader.backgroundColor = [UIColor lightGrayColor];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(firstLabelX, 0.0f, 100.0f, 25.0f)];
    nameLabel.text = @"Username";
    UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(thirdLabelX, 0.0f, 100.0f, 25.0f)];
    numberLabel.text = @"Score";
    [tableHeader addSubview:nameLabel];
    [tableHeader addSubview:numberLabel];
    [_leaderboardTableView setTableHeaderView:tableHeader];
    //Stop highlighting of selected rows. Doesn't work from storyboard in this case for some reason
    _leaderboardTableView.allowsSelection = NO;
    
    //Override to remove extra seperator lines after the last cell, no lines appear if no objects exist
    [_leaderboardTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0,0,0,0)]];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    //Check if touch point is Try Again label
    SKNode *touchedLabel = [self nodeAtPoint:location];
    
    //Back button
    if ([touchedLabel.name isEqual: @"backLabel"]) {
        self.backLabel.fontColor = [SKColor grayColor];
        //Remove table view. Removing this causes the table to remain on top of the menu scene
        [_leaderboardTableView removeFromSuperview];
        //_leaderboardTableView = nil;
        allScoresArray = nil;
        return;
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    //Check if touch point is Try Again label
    SKNode *touchedLabel = [self nodeAtPoint:location];
    
    //Back button
    if ([touchedLabel.name isEqual: @"backLabel"]) {
        //Change label back to iOS blue
        self.backLabel.fontColor = iOSBlueButtonColor;
        //_mainMenuScene = [[MainMenuScene alloc] initWithSize:self.size];
        _mainMenuScene.gameViewController = _gameViewController;
        SKTransition *reveal = [SKTransition doorsCloseHorizontalWithDuration:0.5];
        [self.view presentScene:_mainMenuScene transition: reveal];
        
//        //Toggle other buttons color
//        self.allLabel.fontColor = [SKColor grayColor];
//        self.iPhoneLabel.fontColor = iOSBlueButtonColor;
//        self.iPadLabel.fontColor = iOSBlueButtonColor;
    }
}

#pragma mark - TableView Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [allScoresArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *scoreUserName, *scoreString;
    
<<<<<<< HEAD
    NSString *scoreUserName = gkScore.player.alias;
    NSString *scoreString = gkScore.formattedValue;
<<<<<<< HEAD
    
    NSLog(@"User Name = %@", scoreUserName);
    
//    NSString *scoreUserName = [[allScoresArray objectAtIndex:indexPath.row] objectForKey:@"alias"];
//    NSNumber *scoreNumber = [[allScoresArray objectAtIndex:indexPath.row] objectForKey:@"formattedValue"];
//    NSString *scoreString = [scoreNumber stringValue];
    //NSString *deviceType = [[allScoresArray objectAtIndex:indexPath.row] objectForKey:@"deviceType"];
=======
>>>>>>> workingbranch
=======
    if (self.playerAndConnectionExist) {
        GKScore *gkScore = [allScoresArray objectAtIndex:indexPath.row];
        scoreUserName = gkScore.player.alias;
        scoreString = gkScore.formattedValue;
    } else {
        //No Game Center, show local leaderboard only
        scoreUserName = [[allScoresArray objectAtIndex:indexPath.row] objectForKey:@"scoreUserName"];
        NSNumber *scoreNumber = [[allScoresArray objectAtIndex:indexPath.row] objectForKey:@"newScore"];
        scoreString = [scoreNumber stringValue];
    }
>>>>>>> workingbranch
    
    NSLog(@"User Name = %@", scoreUserName);
    
//    customCell = [tableView dequeueReusableCellWithIdentifier:nil];
    NSString *cellName = @"cell";
    customCell = [tableView dequeueReusableCellWithIdentifier:cellName];
    tableView.rowHeight = 44;
    
    if (customCell == nil) {
        //Load nib for custom view cell
        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"CustomTableViewCell" owner:nil options:nil];
        for (UIView *view in views) {
            if ([view isKindOfClass:[CustomTableViewCell class]]) {
                customCell = (CustomTableViewCell *)view;
                customCell.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.75f];
                //Set labels
                customCell.usernameLabel.text = scoreUserName;
                customCell.usernameLabel.textColor = [UIColor whiteColor];
                customCell.scoreLabel.text = scoreString;
                customCell.scoreLabel.textColor = [UIColor whiteColor];
                customCell.deviceLabel.textColor = [UIColor whiteColor];
            }
        }
    }
    return customCell;
}

<<<<<<< HEAD
=======
//Querry Game Center for leaderboard
>>>>>>> workingbranch
-(void)querryGameCenterForLeaderboard {
    NSString *leaderboardID = [userDefaults objectForKey:@"leaderboardIdentifier"];
    GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] init];
    
<<<<<<< HEAD
=======
    //Make sure leaderboard exists before requesting scores and loading
>>>>>>> workingbranch
    if (leaderboardRequest != nil) {
        leaderboardRequest.identifier = leaderboardID;
        leaderboardRequest.playerScope = GKLeaderboardPlayerScopeGlobal;
        leaderboardRequest.timeScope = GKLeaderboardTimeScopeAllTime;
        leaderboardRequest.range = NSMakeRange(1,10);
        [leaderboardRequest loadScoresWithCompletionHandler: ^(NSArray *scores, NSError *error) {
            if (!error) {
                //NSLog(@"Scores = %@", scores);
<<<<<<< HEAD
                
=======
>>>>>>> workingbranch
                allScoresArray = (NSMutableArray*) scores;
                [_leaderboardTableView reloadData];
            } else {
                NSLog(@"Querry GC Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
}

//Create and show alert view if there is no internet connectivity
-(void)noConnectionAlert {
    NSString *alertMessage = @"No network connection is available. Only the local leaderboard will be shown if one is available";
    UIAlertView *connectionAlert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                              message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //Show alert
    [connectionAlert show];
} //noConnectionAlert close

@end
