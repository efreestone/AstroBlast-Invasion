// Elijah Freestone
// IAD 1412
// Week 4
// December 14th, 2014

//
//  LeaderboardScene.m
//  Project4
//
//  Created by Elijah Freestone on 12/14/14.
//  Copyright (c) 2014 Elijah Freestone. All rights reserved.
//

#import "LeaderboardScene.h"
#include "CustomTableViewCell.h"

@implementation LeaderboardScene {
    SKColor *iOSBlueButtonColor;
    CustomTableViewCell *customCell;
    PFQuery *scoresQuery;
    NSMutableArray *allScoresArray;
    NSMutableArray *iPadArray;
    NSMutableArray *iPhoneArray;
    NSUserDefaults *userDefaults;
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
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
        
//        CGFloat deviceWidth = self.size.width;
        
        //Create and set message label
        self.backLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
        self.backLabel.text = @"Menu";
        self.backLabel.name = @"backLabel";
        self.backLabel.fontColor = iOSBlueButtonColor;
        self.backLabel.fontSize = fontSize;
        float backLabelPlacement = self.backLabel.frame.size.height + fontSize;
        self.backLabel.position = CGPointMake(backLabelPlacement, self.size.height - (fontSize * 1.25));
        [self addChild:self.backLabel];
        
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

//Query Parse for scores and pass array to tableview. Called from touch of Leaderboard label on menu
-(void)queryParseForScores {
    scoresQuery = [PFQuery queryWithClassName:@"userScore"];
    [scoresQuery orderByDescending:@"newScore"];
    [scoresQuery findObjectsInBackgroundWithBlock:^(NSArray *scores, NSError *error) {
        if (!error) {
            //The find succeeded. Pass the array and reload the tableview
            NSLog(@"Successfully retrieved %lu scores.", (unsigned long)scores.count);
            self.scoresArray = scores;
            //Save a copy of the array for filtering
            allScoresArray = (NSMutableArray *)scores;
            //NSLog(@"%@", scoresQuery);
            [_leaderboardTableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
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
    //    _leaderboardTableView.separatorInset = UIEdgeInsetsZero;
    _leaderboardTableView.delegate = self;
    _leaderboardTableView.dataSource = self;
    [self.view addSubview:_leaderboardTableView];
    
    //Grab measurements of table and adjust to align header labels better with custom cell
    CGFloat tableThird = tableWidth / 3;
    CGFloat middleOfThird = tableThird / 2;
    CGFloat firstLabelX = middleOfThird - 25.0f;
//    CGFloat secondLabelX = tableThird + middleOfThird - 20.0f;
    CGFloat thirdLabelX = (tableThird * 2) + middleOfThird - 30.0f;
    //Create header for table view
    UIView *tableHeader = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tableWidth, 25.0f)];
    tableHeader.backgroundColor = [UIColor lightGrayColor];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(firstLabelX, 0.0f, 100.0f, 25.0f)];
    nameLabel.text = @"Username";
//    UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(secondLabelX, 0.0f, 100.0f, 25.0f)];
//    numberLabel.text = @"Score";
    UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(thirdLabelX, 0.0f, 100.0f, 25.0f)];
    numberLabel.text = @"Score";
    [tableHeader addSubview:nameLabel];
//    [tableHeader addSubview:numberLabel];
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
        return;
    }
    
    //All button
    if ([touchedLabel.name isEqual: @"allLabel"]) {
        self.allLabel.fontColor = [SKColor grayColor];
        //Clear mutable array
        [allScoresArray removeAllObjects];
        //Toggle other label colors
        self.iPadLabel.fontColor = iOSBlueButtonColor;
        self.iPhoneLabel.fontColor = iOSBlueButtonColor;
        
        //Reset all array to original score array and reload
        allScoresArray = (NSMutableArray *)self.scoresArray;
        [_leaderboardTableView reloadData];
        return;
    }
    
    //iPhone button
    if ([touchedLabel.name isEqual: @"iPhoneLabel"]) {
        self.iPhoneLabel.fontColor = [SKColor grayColor];
        //Clear mutable array
        [iPhoneArray removeAllObjects];
        for (PFObject *object in self.scoresArray) {
            if ([[object valueForKey:@"deviceType"] isEqualToString:@"iPhone"]) {
                [iPhoneArray addObject:object];
            }
        }
        //Toggle other label colors
        self.allLabel.fontColor = iOSBlueButtonColor;
        self.iPadLabel.fontColor = iOSBlueButtonColor;
        
        //Set all array to iphone only array and reload
        allScoresArray = iPhoneArray;
        [_leaderboardTableView reloadData];
        return;
    }
    
    //iPad button
    if ([touchedLabel.name isEqual: @"iPadLabel"]) {
        self.iPadLabel.fontColor = [SKColor grayColor];
        //Clear mutable array
        [iPadArray removeAllObjects];
        for (PFObject *object in self.scoresArray) {
            if ([[object valueForKey:@"deviceType"] isEqualToString:@"iPad"]) {
                [iPadArray addObject:object];
            }
        }
        //Toggle other label colors
        self.allLabel.fontColor = iOSBlueButtonColor;
        self.iPhoneLabel.fontColor = iOSBlueButtonColor;
        
        //Set all array to iPad only array and reload
        allScoresArray = iPadArray;
        [_leaderboardTableView reloadData];
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
        
        //Toggle other buttons color
        self.allLabel.fontColor = [SKColor grayColor];
        self.iPhoneLabel.fontColor = iOSBlueButtonColor;
        self.iPadLabel.fontColor = iOSBlueButtonColor;
    }
    
    //All button
    if ([touchedLabel.name isEqual: @"allLabel"]) {
        //self.allLabel.fontColor = iOSBlueButtonColor;
        return;
    }
    
    //iPhone button
    if ([touchedLabel.name isEqual: @"iPhoneLabel"]) {
        //self.iPhoneLabel.fontColor = iOSBlueButtonColor;
        return;
    }
    
    //iPad button
    if ([touchedLabel.name isEqual: @"iPadLabel"]) {
        //self.iPadLabel.fontColor = iOSBlueButtonColor;
        return;
    }
}

#pragma mark - TableView Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [allScoresArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKScore *gkScore = [allScoresArray objectAtIndex:indexPath.row];
    
    NSString *scoreUserName = gkScore.player.alias;
    NSString *scoreString = gkScore.formattedValue;
    
    NSLog(@"User Name = %@", scoreUserName);
    
//    NSString *scoreUserName = [[allScoresArray objectAtIndex:indexPath.row] objectForKey:@"alias"];
//    NSNumber *scoreNumber = [[allScoresArray objectAtIndex:indexPath.row] objectForKey:@"formattedValue"];
//    NSString *scoreString = [scoreNumber stringValue];
    //NSString *deviceType = [[allScoresArray objectAtIndex:indexPath.row] objectForKey:@"deviceType"];
    
    //Not reusing cells to maintain sort order
    //static NSString *cellId = @"Cell";
    
    customCell = [tableView dequeueReusableCellWithIdentifier:nil];
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
                //customCell.deviceLabel.text = deviceType;
                customCell.deviceLabel.textColor = [UIColor whiteColor];
            }
        }
    }
    return customCell;
}

-(void)querryGameCenterForLeaderboard {
    NSString *leaderboardID = [userDefaults objectForKey:@"leaderboardIdentifier"];
    GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] init];
    
    if (leaderboardRequest != nil) {
        leaderboardRequest.identifier = leaderboardID;
        leaderboardRequest.playerScope = GKLeaderboardPlayerScopeGlobal;
        leaderboardRequest.timeScope = GKLeaderboardTimeScopeAllTime;
        leaderboardRequest.range = NSMakeRange(1,10);
        [leaderboardRequest loadScoresWithCompletionHandler: ^(NSArray *scores, NSError *error) {
            if (!error) {
                //NSLog(@"Scores = %@", scores);
                
                allScoresArray = (NSMutableArray*) scores;
                [_leaderboardTableView reloadData];
            } else {
                NSLog(@"Querry GC Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
}

@end
