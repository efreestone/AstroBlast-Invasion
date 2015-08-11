//
//  GameScene.m
//  AstroBlastInvasion
//
//  Created by Elijah Freestone on 7/9/15.
//  Copyright (c) 2015 Elijah Freestone. All rights reserved.
//

#import "GameScene.h"
#import "GameOverScene.h"
#import "MainMenuScene.h"
#import "ConnectionManagement.h"

//Set up category constants for laser balls and enemy spaceships
//SpriteKit uses 32 bit ints that act as bitmasks
static const uint32_t laserBallCategory =  0x1 << 0;
static const uint32_t enemyShipCategory =  0x1 << 1;
static const uint32_t shipShieldCategory =  0x1 << 2;
static const uint32_t asteroidCategory = 0x1 << 3;
static const uint32_t extraLifeCategory = 0x1 << 4;

//Create private interface and variables
@interface GameScene () <SKPhysicsContactDelegate>

@property (nonatomic) NSTimeInterval asteroidLastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval asteroidLastUpdateTimeInterval;

@property (nonatomic) NSTimeInterval extraLifeLastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval extraLifeLastUpdateTimeInterval;

@property (strong, nonatomic) SKSpriteNode *playerFighterJet;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (strong, nonatomic) SKLabelNode *scoreLabel;
@property (strong, nonatomic) SKLabelNode *livesLabel;
@property (strong, nonatomic) SKLabelNode *pauseLabel;
@property (strong, nonatomic) SKLabelNode *menuLabel;
@property (strong, nonatomic) NSMutableArray *explosionTextures;
@property (strong, nonatomic) GameOverScene *gameOverScene;

@end

//Add standard implementations of vector math routines for projectile trajectory.
//These are from a raywenderlich.com SpriteKite tutorial
static inline CGPoint rwAdd(CGPoint a, CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint rwSub(CGPoint a, CGPoint b) {
    return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGPoint rwMult(CGPoint a, float b) {
    return CGPointMake(a.x * b, a.y * b);
}

static inline float rwLength(CGPoint a) {
    return sqrtf(a.x * a.x + a.y * a.y);
}

// Makes a vector have a length of 1
static inline CGPoint rwNormalize(CGPoint a) {
    float length = rwLength(a);
    return CGPointMake(a.x / length, a.y / length);
}


@implementation GameScene {
    ConnectionManagement *connectionMGMT;
    //Declare sound actions to be loaded ahead of time
    SKAction *laserSoundAction;
    SKAction *hitEnemySoundAction;
    SKAction *missShipSoundAction;
    SKAction *shieldHitSoundAction;
    SKAction *asteroidHitSoundAction;
    SKAction *extraLifeSoundAction;
    
    SKSpriteNode *laserBallNode;
    SKSpriteNode *enemyShipNode;
    SKSpriteNode *shipShieldNode;
    SKSpriteNode *asteroidNode;
    SKSpriteNode *extraLifeNode;
    SKSpriteNode *flashBackground;
    
    int enemyShipsDestroyed;
    int runningTotal;
    int currentScore;
    int currentMultiplier;
    int pointsForShip;
    int shipsSpawned;
    int playerLives;
    float totalScore;
    CGFloat angle;
    float fontSize;
    float explosionScale;
    BOOL isPaused;
    BOOL isFlashing;
    NSString *pauseString;
    NSString *resumeString;
    
    CFTimeInterval startTime;
    CFTimeInterval endTime;
    CFTimeInterval pauseStartTime;
    CFTimeInterval pauseEndTime;
    CFTimeInterval totalPauseTime;
    
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
    
    BOOL flawlessBOOL;
    BOOL quickDrawBOOL;
    BOOL halfDozenBOOL;
    BOOL aDozenBool;
    BOOL dozenAndAHalfBOOL;
    BOOL lateBloomerBOOL;
    BOOL didGetFlawless;
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        //Load explosion atlas with images in order after sort via compare
        SKTextureAtlas *explosionTextureAtlas = [SKTextureAtlas atlasNamed:@"explosion"];
        NSArray *textureNamesArray = [[explosionTextureAtlas textureNames] sortedArrayUsingSelector: @selector(compare:)];
        self.explosionTextures = [NSMutableArray new];
        
        for (NSString *name in textureNamesArray) {
            SKTexture *texture = [explosionTextureAtlas textureNamed:name];
            [self.explosionTextures addObject:texture];
        }
        
        didGetFlawless = YES;
        
        connectionMGMT = [[ConnectionManagement alloc] init];
        
        if ([GKLocalPlayer localPlayer].isAuthenticated && [connectionMGMT checkConnection]) {
            [self queryGameCenterForAchievements];
        
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
        }
        
        startTime = 0;
        pauseStartTime = 0;
        totalPauseTime = 0;
        
        //Set starting value for destroying a spaceship
        pointsForShip = 100;
        shipsSpawned = 0;
        
        //Log out screen size
        NSLog(@"Size = %@", NSStringFromCGSize(size));
        //Grab screen size
        CGFloat screenWidth = self.size.width;
        CGFloat screenHeight = self.size.height;
        
        //Set background image. It looks like SpriteKit automatically uses the correct asset for the device type.
        SKSpriteNode *backgroundImage = [SKSpriteNode spriteNodeWithImageNamed:@"space"];
        backgroundImage.position = CGPointMake(screenWidth / 2, screenHeight / 2);
        [self addChild:backgroundImage];
        
        //Set font size and adjust for ipad
        fontSize = 15;
        explosionScale = 0.5;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            fontSize = 30;
            explosionScale = 1;
        }
        
        //Add the fighter sprite to the scene w/ postion based on width of fighter and height of frame
        self.playerFighterJet = [SKSpriteNode spriteNodeWithImageNamed:@"fighter"];
        self.playerFighterJet.position = CGPointMake(self.playerFighterJet.size.width * 0.75, screenHeight / 2);
        [self addChild:self.playerFighterJet];
        
        //Set up physics world with zero gravity
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
        
        //Set lives and ship count
        playerLives = 3;
        enemyShipsDestroyed = 0;
        currentScore = 0;
        currentMultiplier = 1;
        
        float labelGapFromFont = fontSize * 1.5;
        
        //Create and display score label
        self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
        //Fixed issue with ships not showing by setting their zPosition higher than the labels (0.0 default)
        self.scoreLabel.text = [NSString stringWithFormat:@"Score: %04d X%d", currentScore, currentMultiplier];
        self.scoreLabel.fontColor = [SKColor whiteColor];
        self.scoreLabel.fontSize = fontSize;
        self.scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        float scoreLabelWidthPlus = self.scoreLabel.frame.size.width + fontSize;
        self.scoreLabel.position = CGPointMake(screenWidth - scoreLabelWidthPlus, screenHeight - labelGapFromFont);
        [self addChild:self.scoreLabel];
        
        //Create and display lives label
        self.livesLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
        self.livesLabel.text = [NSString stringWithFormat:@"Lives: %d", playerLives];
        self.livesLabel.fontColor = [SKColor whiteColor];
        self.livesLabel.fontSize = fontSize;
        self.livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        float livesLabelWidthHalf = self.livesLabel.frame.size.width / 2;
        self.livesLabel.position = CGPointMake((screenWidth / 2) - livesLabelWidthHalf, screenHeight - labelGapFromFont);
        [self addChild:self.livesLabel];
        
        //Create pause button
        pauseString = @"Pause Game";
        resumeString = @"Resume Game";
        self.pauseLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
        self.pauseLabel.text = pauseString;
        self.pauseLabel.name = @"pauseLabel";
        self.pauseLabel.fontColor = [SKColor whiteColor];
        self.pauseLabel.zPosition = 3;
        self.pauseLabel.fontSize = fontSize;
        self.pauseLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        self.pauseLabel.position = CGPointMake(fontSize, screenHeight - labelGapFromFont);
        [self addChild:self.pauseLabel];
        
        //Create menu button
        self.menuLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
        self.menuLabel.text = @"Menu";
        self.menuLabel.name = @"menuLabel";
        self.menuLabel.fontColor = [SKColor whiteColor];
        self.menuLabel.zPosition = 3;
        self.menuLabel.fontSize = fontSize;
        self.menuLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        self.menuLabel.position = CGPointMake(fontSize, fontSize);
        [self addChild:self.menuLabel];
        
        //Instantiate flash background triggered when a spaceship is missed
        //This seems to work fine on devices but still causes occasional delays in the sim
        flashBackground = [SKSpriteNode spriteNodeWithColor:[SKColor redColor] size:CGSizeMake(screenWidth, screenHeight)];
        flashBackground.zPosition = 2;
        flashBackground.alpha = 0.5f;
        flashBackground.position = CGPointMake(self.size.width / 2, self.size.height / 2);
        flashBackground.hidden = YES;
        [self addChild:flashBackground];
        
        //Initiate sounds for laser fire, hitting and missing an enemy spaceship
        //Sounds for winning/losing a game are created and played on GameOverScene
        laserSoundAction = [SKAction playSoundFileNamed:@"laser.caf" waitForCompletion:NO];
        hitEnemySoundAction = [SKAction playSoundFileNamed:@"explosion.caf" waitForCompletion:NO];
        missShipSoundAction = [SKAction playSoundFileNamed:@"miss.caf" waitForCompletion:NO];
        shieldHitSoundAction = [SKAction playSoundFileNamed:@"shield.caf" waitForCompletion:NO];
        asteroidHitSoundAction = [SKAction playSoundFileNamed:@"asteroid.caf" waitForCompletion:NO];
        extraLifeSoundAction = [SKAction playSoundFileNamed:@"life.caf" waitForCompletion:NO];
    }
    return self;
}

#pragma mark - spawn nodes

//Add enemy objects to the scene with random speed and spawn points (Y axis)
-(void)addEnemyShip {
    if (startTime == 0) {
        startTime = CFAbsoluteTimeGetCurrent();
        NSLog(@"Start: %f", startTime);
    }
    
    //Keep track of ships spawned. This is used to determine when to add shield ships
    shipsSpawned++;
    
    //Create enemy sprite
    enemyShipNode = [SKSpriteNode spriteNodeWithImageNamed:@"spaceship"];
    enemyShipNode.zPosition = 4;
    //Set physics body to radius around enemy spaceship
    enemyShipNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:enemyShipNode.size.width / 2];
    enemyShipNode.physicsBody.dynamic = YES;
    //Set category, contact and collision
    enemyShipNode.physicsBody.categoryBitMask = enemyShipCategory;
    enemyShipNode.physicsBody.contactTestBitMask = laserBallCategory;
    enemyShipNode.physicsBody.collisionBitMask = 0;
    
    //Create a random Y axis to spawn enemy
    int minimumY = enemyShipNode.size.height / 2;
    int maximumY = self.frame.size.height - enemyShipNode.size.height / 2;
    int rangeOfY = maximumY - minimumY;
    int actualYAxis = (arc4random_uniform(rangeOfY)) + minimumY;
    
    //Spawn enemy just passed right edge of screen w/ a random Y postion
    enemyShipNode.position = CGPointMake(self.frame.size.width + enemyShipNode.size.width/2, actualYAxis);
    [self addChild:enemyShipNode];
    
    //Determine varied speed of enemies from right to left
    float minDuration = 1.75;
    float maxDuration = 3.25;
    float actualDuration = [self randomFloatBetweenLow:minDuration andHigh:maxDuration];
    
    if (shipsSpawned == 5) {
        shipShieldNode = [SKSpriteNode spriteNodeWithImageNamed:@"shield"];
        shipShieldNode.zPosition = 3;
        //Set physics body to radius around shield
        shipShieldNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:shipShieldNode.size.width /2];
        shipShieldNode.physicsBody.dynamic = YES;
        //Set category, contact and collision
        shipShieldNode.physicsBody.categoryBitMask = shipShieldCategory;
        shipShieldNode.physicsBody.contactTestBitMask = laserBallCategory;
        shipShieldNode.physicsBody.collisionBitMask = 0;
        
        shipShieldNode.position = enemyShipNode.position;
        [self addChild:shipShieldNode];
    }
    
    //Create move action from right to left and remove enemy once off screen
    SKAction *actionMove = [SKAction moveTo:CGPointMake(-enemyShipNode.size.width/2, actualYAxis) duration:actualDuration];
    SKAction *actionMoveDone = [SKAction runBlock:^{
        [SKAction removeFromParent];
        didGetFlawless = NO;
    }];
    SKAction *actionMoveDoneShield = [SKAction removeFromParent];
    
    //Create actions for flashing screen
    SKAction *flashDelay = [SKAction waitForDuration:0.025];
    SKAction *removeFlashBackground = [SKAction runBlock:^{
        flashBackground.hidden = YES;
        isFlashing = NO;
        enemyShipsDestroyed = 0;
        runningTotal = 0;
        _gameViewController.totalOfEnemiesDestroyed = 0;
    }];
    
    //Create loseAction with block to show Game Over Scene if an enemy get by
    SKAction * loseAction = [SKAction runBlock:^{
        SKTransition *revealGameLost = [SKTransition doorsOpenVerticalWithDuration:0.5];
        _gameOverScene = [[GameOverScene alloc] initWithSize:self.size didPlayerWin:NO withScore:0.0];
        _gameOverScene.gameViewController = self.gameViewController;
        //Play missed ship sound
        [self runAction:missShipSoundAction];
        //Show and hide flashing background
        if (!isFlashing) {
            flashBackground.hidden = NO;
            isFlashing = YES;
            [self runAction:[SKAction sequence:@[flashDelay, removeFlashBackground]]];
        }
        
        //Remove lives as spaceships are missed
        playerLives--;
        //Reset multiplier
        currentMultiplier = 1;
        self.scoreLabel.text = [NSString stringWithFormat:@"Score: %04d X%d", currentScore, currentMultiplier];
        
        self.livesLabel.text = [NSString stringWithFormat:@"Lives: %d", playerLives];
        //3 ships missed, player lost
        if (playerLives == 0) {
            [self.view presentScene:_gameOverScene transition: revealGameLost];
        }
    }];
    //Make sure spaceship exists and run actions
    if (enemyShipNode != nil) {
        [enemyShipNode runAction:[SKAction sequence:@[actionMove, loseAction, actionMoveDone]]];
        if (shipsSpawned == 5) {
            //Run shield actions with ship node
            [shipShieldNode runAction:[SKAction sequence:@[actionMove, actionMoveDoneShield]]];
        }
    } else {
        NSLog(@"enemyShipNode NIL!");
    }
}

//Add asteroid to scene using refactored code from addEnemy
-(void)addAsteroid {
    //Create asteroid sprite
    asteroidNode = [SKSpriteNode spriteNodeWithImageNamed:@"asteroid-X2"];
    asteroidNode.zPosition = 4;
    //Set physics body to radius around asteroid
    asteroidNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:asteroidNode.size.width / 2];
    asteroidNode.physicsBody.dynamic = YES;
    //Set category, contact and collision
    asteroidNode.physicsBody.categoryBitMask = asteroidCategory;
    asteroidNode.physicsBody.contactTestBitMask = laserBallCategory;
    asteroidNode.physicsBody.collisionBitMask = 0;
    
    //Create a random Y axis to spawn enemy
    int minimumY = asteroidNode.size.height / 2;
    int maximumY = self.frame.size.height - asteroidNode.size.height / 2;
    int rangeOfY = maximumY - minimumY;
    int actualYAxis = (arc4random_uniform(rangeOfY)) + minimumY;
    
    //Spawn enemy just passed right edge of screen w/ a random Y postion
    asteroidNode.position = CGPointMake(self.frame.size.width + asteroidNode.size.width/2, actualYAxis);
    [self addChild:asteroidNode];
    
    //Determine varied speed of enemies from right to left
    float actualDuration = [self randomFloatBetweenLow:2.0 andHigh:4.0];
    
    //Create move action from right to left and remove enemy once off screen
    SKAction *actionMove = [SKAction moveTo:CGPointMake(-asteroidNode.size.width/2, actualYAxis) duration:actualDuration];
    //SKAction *actionMoveDone = [SKAction removeFromParent];
    SKAction *actionMoveDone = [SKAction runBlock:^{
        [SKAction removeFromParent];
        didGetFlawless = NO;
    }];
    
    //Make sure spaceship exists
    if (asteroidNode != nil) {
        [asteroidNode runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    } else {
        NSLog(@"asteroidNode NIL!");
    }
    
}

//Add extra life asteroid to scene using refactored code from addEnemy
-(void)addExtraLife {
    //Create asteroid sprite
    extraLifeNode = [SKSpriteNode spriteNodeWithImageNamed:@"asteroid-life"];
    extraLifeNode.zPosition = 4;
    //Set physics body to radius around asteroid
    extraLifeNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:extraLifeNode.size.width / 2];
    extraLifeNode.physicsBody.dynamic = YES;
    //Set category, contact and collision
    extraLifeNode.physicsBody.categoryBitMask = extraLifeCategory;
    extraLifeNode.physicsBody.contactTestBitMask = laserBallCategory;
    extraLifeNode.physicsBody.collisionBitMask = 0;
    
    //Create a random Y axis to spawn enemy
    int minimumY = extraLifeNode.size.height / 2;
    int maximumY = self.frame.size.height - extraLifeNode.size.height / 2;
    int rangeOfY = maximumY - minimumY;
    int actualYAxis = (arc4random_uniform(rangeOfY)) + minimumY;
    
    //Spawn enemy just passed right edge of screen w/ a random Y postion
    extraLifeNode.position = CGPointMake(self.frame.size.width + extraLifeNode.size.width/2, actualYAxis);
    [self addChild:extraLifeNode];
    
    //Determine varied speed of extra life from right to left
    float actualDuration = [self randomFloatBetweenLow:1.75 andHigh:3.0];
    
    //Create move action from right to left and remove enemy once off screen
    SKAction *actionMove = [SKAction moveTo:CGPointMake(-extraLifeNode.size.width/2, actualYAxis) duration:actualDuration];
    SKAction *actionMoveDone = [SKAction runBlock:^{
        [SKAction removeFromParent];
        didGetFlawless = NO;
    }];
    
    //Make sure spaceship exists
    if (extraLifeNode != nil) {
        [extraLifeNode runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    } else {
        NSLog(@"extraLifeNode NIL!");
    }
}

//Add laser ball to scene and set up everything physics related
-(void)addLaserBall {
    //Set initial location of projectile to the fighter
    laserBallNode = [SKSpriteNode spriteNodeWithImageNamed:@"laser-ball"];
    laserBallNode.zPosition = 4;
    laserBallNode.position = self.playerFighterJet.position;
    laserBallNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:laserBallNode.size.width/2];
    laserBallNode.physicsBody.dynamic = YES;
    //Set category, contact and collision
    laserBallNode.physicsBody.categoryBitMask = laserBallCategory;
    laserBallNode.physicsBody.contactTestBitMask = enemyShipCategory | asteroidCategory;
    laserBallNode.physicsBody.collisionBitMask = 0;
    laserBallNode.physicsBody.usesPreciseCollisionDetection = YES;
}

//Calculate random float. Used to calculate spawn times and durations
- (float)randomFloatBetweenLow:(float)lowValue andHigh:(float)highVaue {
    float range = highVaue - lowValue;
    return (((float)arc4random() / RAND_MAX) * range) + lowValue;
}

//Track time since last spawn and add new enemy every 1 second
- (void)timeSinceLastSpawn:(CFTimeInterval)timeSinceUpdate {
    self.lastSpawnTimeInterval += timeSinceUpdate;
    if (self.lastSpawnTimeInterval > 1) {
        self.lastSpawnTimeInterval = 0;
        [self addEnemyShip];
    }
    
    //Determine varied spawn time for asteroids
    float actualTime = [self randomFloatBetweenLow:4.0 andHigh:6.5];
    
    self.asteroidLastSpawnTimeInterval += timeSinceUpdate;
    if (self.asteroidLastSpawnTimeInterval > actualTime) {
        self.asteroidLastSpawnTimeInterval = 0;
        [self addAsteroid];
    }
    
    //Determine varied spawn time for exra life
    float lifeActualTime = [self randomFloatBetweenLow:6.0 andHigh:8.5];
    
    self.extraLifeLastSpawnTimeInterval += timeSinceUpdate;
    if (self.extraLifeLastSpawnTimeInterval > lifeActualTime) {
        self.extraLifeLastSpawnTimeInterval = 0;
        [self addExtraLife];
    }
}

//Called by SpriteKit every frame. Checks last update time which in turn spawns enemies.
//This is from Apple's Adventure sample and includes logic to avoid odd behaviour if a large amount of time has passed.
- (void)update:(NSTimeInterval)currentTime {
    if (!isPaused) {
        // Handle time delta.
        // If we drop below 60fps, we still want everything to move the same distance.
        CFTimeInterval timeSinceUpdate = currentTime - self.lastUpdateTimeInterval;
        CFTimeInterval asteroidTimeSinceUpdate = currentTime - self.asteroidLastUpdateTimeInterval;
        CFTimeInterval extraLifeTimeSinceUpdate = currentTime - self.extraLifeLastUpdateTimeInterval;
        self.lastUpdateTimeInterval = currentTime;
        self.asteroidLastUpdateTimeInterval = currentTime;
        self.extraLifeLastUpdateTimeInterval = currentTime;
        if (timeSinceUpdate > 1) { // more than a second since last update
            timeSinceUpdate = 1.0 / 60.0;
            self.lastUpdateTimeInterval = currentTime;
        }
        
        //Spawn multiplier asteroid every 5 seconds
        if (asteroidTimeSinceUpdate > 5) {
            asteroidTimeSinceUpdate = 5.0 / 60.0;
            self.asteroidLastSpawnTimeInterval = currentTime;
        }
        
        //Spawn extra life asteroid every 7 seconds
        if (extraLifeTimeSinceUpdate > 7) {
            extraLifeTimeSinceUpdate = 7.0 / 60.0;
            self.extraLifeLastSpawnTimeInterval = currentTime;
        }
        
        //Check time since last update and spawn accordingly
        [self timeSinceLastSpawn:timeSinceUpdate];
    }
}

//Grab touch event and calculate trajectory of projectile.
//Also extends trajectory so the laser ball continues passed the touch and off screen.
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //Grab touch and location within node
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *touchedLabel = [self nodeAtPoint:location];
    //Pause Button
    if ([touchedLabel.name isEqual: @"pauseLabel"]) {
        NSLog(@"pause");
        [self pauseButtonPressed];
        return;
    }
    
    //Menu button
    if ([touchedLabel.name isEqual: @"menuLabel"]) {
        _mainMenuScene.gameViewController = self.gameViewController;
        SKAction *waitDuration = [SKAction waitForDuration:0.05];
        SKAction *revealMenuScene = [SKAction runBlock:^{
            SKTransition *reveal = [SKTransition doorsCloseVerticalWithDuration:0.5];
            [self.view presentScene:_mainMenuScene transition:reveal];
        }];
        [self runAction:[SKAction sequence:@[waitDuration, revealMenuScene]]];
    }
    
    //Make sure game isnt paused
    if (!isPaused) {
        //Call method to add laser ball
        [self addLaserBall];
        
        //Determine offset of location to fighter
        CGPoint offset = rwSub(location, self.playerFighterJet.position);
        
        //Make sure not shooting backwards or up/down
        if (offset.x <= 0) return;
        
        //Position has been double-checked, add laser ball sprite
        [self addChild:laserBallNode];
        
        //Get the direction of where to shoot laser ball
        //rwNormalize is a unit vector of length 1
        CGPoint directionOfShot = rwNormalize(offset);
        
        //Shoot far enough for the laser ball to leave the screen
        CGPoint shootOffScreen = rwMult(directionOfShot, 1000);
        
        //Add the shoot amount to the current position
        CGPoint finalDestination = rwAdd(shootOffScreen, laserBallNode.position);
        
        //Calculate velocity multiplier based on device type. Increased for iPad to compensate for larger screen
        float velocityMultiplier = 1.0;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            velocityMultiplier = 2.5;
        }
        
        //Get angle of shot and rotate fighter accordingly
        float deltaX = self.playerFighterJet.position.x - location.x;
        float deltaY = self.playerFighterJet.position.y - location.y;
        //Adding pi rotates the fighter 180 to point the correct direction.
        angle = atan2(deltaY, deltaX) + M_PI;
        SKAction *rotateFighter = [SKAction rotateToAngle:angle duration:0.1 shortestUnitArc:YES];
        
        //Set velocity and create actions for the laser ball
        float velocity = 400.0 * velocityMultiplier;
        float realMoveDuration = self.size.width / velocity;
        SKAction *shotDelay = [SKAction waitForDuration:0.1];
        SKAction *actionShoot = [SKAction moveTo:finalDestination duration:realMoveDuration];
        SKAction *actionShootDone = [SKAction removeFromParent];
        
        //Rotate fighter and fire once action is done
        [self.playerFighterJet runAction:rotateFighter completion:^{
            //Make sure laser ball exists
            if (laserBallNode != nil) {
                //Play laser fire sound
                [self runAction:laserSoundAction];
            } else {
                NSLog(@"laserBallNode NIL!");
            }
        }];
        //Moving the run action outside of the completion loop bypasses the stuck node issue.
        //A 0.1 delay is added to match the duration of the rotate action
        [laserBallNode runAction:[SKAction sequence:@[shotDelay, actionShoot, actionShootDone]]];
    }
}

//Handle pausing and resuming the game. Triggered by touching pause label
-(void)pauseButtonPressed {
    if (!isPaused) {
        self.pauseLabel.text = resumeString;
        isPaused = YES;
        self.paused = YES;
        
        //Check if game has been paused before
        if (pauseStartTime == 0) {
            pauseStartTime = CFAbsoluteTimeGetCurrent();
        }
    } else {
        self.pauseLabel.text = pauseString;
        isPaused = NO;
        self.paused = NO;
        
        pauseEndTime = CFAbsoluteTimeGetCurrent();
        totalPauseTime = pauseEndTime - pauseStartTime;
        NSLog(@"Pause: %f", totalPauseTime);
    }
}

//Contact delegate method. Triggers removal method when collision is detected
-(void)didBeginContact:(SKPhysicsContact *)contact {
    //Set physics bodies w/ generic names.
    SKPhysicsBody *firstBody, *secondBody;
    //Order is not gauranteed so sort by category
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    //Call remove method if bodies are laserball and shield
    if ((firstBody.categoryBitMask & laserBallCategory) != 0 && (secondBody.categoryBitMask & shipShieldCategory) != 0) {
        [self laserBall:(SKSpriteNode *)firstBody.node didCollideWithShield:(SKSpriteNode *)secondBody.node];
        //Play shield sound
        [self runAction:shieldHitSoundAction];
    }
    
    //Call remove method if physics bodies are laserBall and enemyShip
    if ((firstBody.categoryBitMask & laserBallCategory) != 0 && (secondBody.categoryBitMask & enemyShipCategory) != 0) {
        [self laserBall:(SKSpriteNode *)firstBody.node didCollideWithEnemyShip:(SKSpriteNode *)secondBody.node];
        //Play explosion sound
        [self runAction:hitEnemySoundAction];
    }
    
    //Change multiplier and call remove if physics bodies are laserBall and asteroid
    if ((firstBody.categoryBitMask & laserBallCategory) != 0 && (secondBody.categoryBitMask & asteroidCategory) != 0) {
        currentMultiplier++;
        self.scoreLabel.text = [NSString stringWithFormat:@"Score: %04d X%d", currentScore, currentMultiplier];
        
        [self laserBall:(SKSpriteNode *)firstBody.node didCollideWithAsteroid:(SKSpriteNode *)secondBody.node];
        [self runAction:asteroidHitSoundAction];
    }
    
    //Call remove if physics bodies are laserBall and extra life
    if ((firstBody.categoryBitMask & laserBallCategory) != 0 && (secondBody.categoryBitMask & extraLifeCategory) != 0) {
        [self laserBall:(SKSpriteNode *)firstBody.node didCollideWithExtraLife:(SKSpriteNode *)secondBody.node];
        [self runAction:extraLifeSoundAction];
    }
    
}

//Remove ship and laser ball when collision detected
-(void)laserBall:(SKSpriteNode *)passedLaserBall didCollideWithEnemyShip:(SKSpriteNode *)passedEnemyShip {
    NSLog(@"Hit");
    
    //Add explosion to scene
    SKSpriteNode *explosionNode = [SKSpriteNode spriteNodeWithTexture:[self.explosionTextures objectAtIndex:0]];
    explosionNode.scale = explosionScale;
    explosionNode.position = passedEnemyShip.position;
    //Set zPosition to put explosion in front of spaceship
    explosionNode.zPosition = 5.0;
    [self addChild:explosionNode];
    //Run animation action for explosion. Plays 4 imgs in texture atlas
    SKAction *explosionAction = [SKAction animateWithTextures:self.explosionTextures timePerFrame:0.05];
    SKAction *removeExplosion = [SKAction removeFromParent];
    [explosionNode runAction:[SKAction sequence:@[explosionAction, removeExplosion]]];
    
    //Add slight delay to removing colliding nodes.
    //This is to smooth out removal coinciding with explosion animation
    SKAction *delayRemove = [SKAction waitForDuration:0.0025];
    SKAction *removeSpriteNodes = [SKAction runBlock:^{
        //Remove nodes that collided
        [passedLaserBall removeFromParent];
        [passedEnemyShip removeFromParent];
    }];
    [self runAction:[SKAction sequence:@[delayRemove, removeSpriteNodes]]];
    
    //Keep track of enemy ships destroyed and update score
    enemyShipsDestroyed++;
    
    int pointsWithMultiplier = pointsForShip * currentMultiplier;
    [self adjustTotalScoreBy:pointsWithMultiplier];
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %04d X%d", currentScore, currentMultiplier];
    
    //Reveal game won scene once 2500 points scored
    if (currentScore >= 2500) {
        endTime = CFAbsoluteTimeGetCurrent();
        //NSLog(@"End: %f", endTime);
        //Calculate total time and factor in paused time
        CFTimeInterval totalTime = CFAbsoluteTimeGetCurrent() - startTime;
        //NSLog(@"Total Time: %f", totalTime);
        CFTimeInterval timeAdjustedForPause = totalTime - totalPauseTime;
        NSLog(@"time with pause: %f", timeAdjustedForPause);
        NSLog(@"Total ships destroyed: %d", enemyShipsDestroyed);
        
        int livesBonus = playerLives * 100;
        float timeBonus = 2500 / timeAdjustedForPause;
        double totalScoreFloat = timeBonus * livesBonus;
        NSLog(@"Total Score: %f", totalScoreFloat);
        NSNumber *passedScore = [NSNumber numberWithDouble:totalScoreFloat];
        
        SKTransition *revealGameWon = [SKTransition doorsOpenVerticalWithDuration:0.5];
        _gameOverScene = [[GameOverScene alloc] initWithSize:self.size didPlayerWin:YES withScore:totalScoreFloat];
        _gameOverScene.gameViewController = self.gameViewController;
        _gameOverScene.mainMenuScene = _mainMenuScene;
        
        //Get running total of enemy ships destroyed
        runningTotal = [_gameViewController incrementTotalDestroyed:enemyShipsDestroyed];
        NSLog(@"Running total: %d", runningTotal);
        
        //Make sure user is logged in. Moves on to achievements if one is.
        if (![GKLocalPlayer localPlayer].authenticated) {
            //[_gameOverScene noUserAlert];
            NSLog(@"Current User");
        } else {
            //Check connection before checking achievements
            if ([connectionMGMT checkConnection]) {
                //Check if achievement were earned and have not already been awarded
                if (didGetFlawless && !flawlessBOOL) {
                    NSLog(@"Flawless");
                    [_gameOverScene achievementReceived:flawlessKey withTitle:flawlessTitle];
                    _gameOverScene.achievementReceived = YES;
                }
                if (timeAdjustedForPause <= 6.0 && !quickDrawBOOL) {
                    NSLog(@"Quick Draw");
                    [_gameOverScene achievementReceived:quickDrawKey withTitle:quickDrawTitle];
                    _gameOverScene.achievementReceived = YES;
                }
                if (runningTotal >= 6 && !halfDozenBOOL) {
                    NSLog(@"Half Dozen");
                    [_gameOverScene achievementReceived:halfDozenKey withTitle:halfDozenTitle];
                    _gameOverScene.achievementReceived = YES;
                }
                if (runningTotal >= 12 && !aDozenBool) {
                    NSLog(@"One Dozen");
                    [_gameOverScene achievementReceived:aDozenKey withTitle:aDozenTitle];
                    _gameOverScene.achievementReceived = YES;
                }
                if (runningTotal >= 18 && !dozenAndAHalfBOOL) {
                    NSLog(@"Dozen and a half");
                    [_gameOverScene achievementReceived:dozenAndAHalfKey withTitle:dozenAndAHalfTitle];
                    _gameOverScene.achievementReceived = YES;
                }
                if (timeAdjustedForPause >= 12.1 && !lateBloomerBOOL) {
                    NSLog(@"Late Bloomer");
                    [_gameOverScene achievementReceived:lateBloomerKey withTitle:lateBloomerTitle];
                    _gameOverScene.achievementReceived = YES;
                }
            }
        }
        
        _gameOverScene.userData = [NSMutableDictionary dictionary];
        [_gameOverScene.userData setObject:passedScore forKey:@"score"];
        
        [self.view presentScene:_gameOverScene transition:revealGameWon];
    }
}

//Remove shield and laserball if collision detected
-(void)laserBall:(SKSpriteNode *)passedLaserBall didCollideWithShield:(SKSpriteNode *)passedShipShield {
    SKAction *removeSpriteNodes = [SKAction runBlock:^{
        //Remove nodes that collided
        [passedLaserBall removeFromParent];
        [passedShipShield removeFromParent];
        shipsSpawned = 0;
    }];
    
    [self runAction:removeSpriteNodes];
}

//Remove asteroid and laser ball if collision detected
-(void)laserBall:(SKSpriteNode *)passedLaserBall didCollideWithAsteroid:(SKSpriteNode *)passedAsteroid {
    int pointsWithMultiplier = pointsForShip * currentMultiplier;
    [self adjustTotalScoreBy:pointsWithMultiplier];
    
    //Add slight delay to removing colliding nodes.
    //This is to smooth out removal coinciding with explosion animation
    SKAction *delayRemove = [SKAction waitForDuration:0.025];
    SKAction *removeSpriteNodes = [SKAction runBlock:^{
        //Remove nodes that collided
        [passedLaserBall removeFromParent];
        [passedAsteroid removeFromParent];
    }];
    [self runAction:[SKAction sequence:@[delayRemove, removeSpriteNodes]]];
}

//Remove extra life and laserball if collision detected
-(void)laserBall:(SKSpriteNode *)passedLaserBall didCollideWithExtraLife:(SKSpriteNode *)passedExtraLife {
    //Make sure lives aren't already gone
    if (playerLives != 0) {
        playerLives++;
        self.livesLabel.text = [NSString stringWithFormat:@"Lives: %d", playerLives];
    }
    
    SKAction *removeSpriteNodes = [SKAction runBlock:^{
        //Remove nodes that collided
        [passedLaserBall removeFromParent];
        [passedExtraLife removeFromParent];
    }];
    [self runAction:removeSpriteNodes];
}

//Adjust score for destroyed ships
-(void)adjustTotalScoreBy:(int)pointsEarned {
    currentScore += pointsEarned;
    [self.scoreLabel setText:[NSString stringWithFormat:@"Score: %04d X%d", currentScore, currentMultiplier]];
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
    }];
}

@end
