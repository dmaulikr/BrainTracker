//
//  BTScoreKeeperVC.m
//  BrainTracker
//
//  Created by Richard Sprague on 3/5/14.
//  Copyright (c) 2014 Richard Sprague. All rights reserved.
//

#import "BTScoreKeeperVC.h"

// import all classes for the BrainTracker model
#import "BTStimulus.h"
#import "BTResponse.h"
#import "BTTimer.h"
#import "BTResultsTracker.h"

@interface BTScoreKeeperVC ()

@property (strong,nonatomic) BTStimulus *randomNumberStimulus;
@property  uint stimulus;
@property (strong,nonatomic) BTResponse *responseFromUser;
@property (strong, nonatomic) BTResultsTracker *results;

@property (strong, nonatomic) NSDate *lastTime;

@property BOOL alreadyResponded; // makes sure you don't respond to the same stimulus more than once.

@property (strong, nonatomic) BTTimer *roundTimer;  // a timer for this particular round of the test.
@property (weak, nonatomic) IBOutlet UILabel *stimulusNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *occludeLabel;



@property (weak, nonatomic) IBOutlet UIView *stimulusPresenter; // view were we show the stimulus.


@end

@implementation BTScoreKeeperVC
@synthesize randomNumberStimulus;

- (BTResultsTracker *) results {
    
    if(!_results) {
        _results = [[BTResultsTracker alloc] init];
        self.results = _results;
    }
    return _results;
    
}

- (BTTimer *) roundTimer {
    
    if (!_roundTimer) {_roundTimer = [[BTTimer alloc] init];}
    return _roundTimer;
    
}

- (void) setRandomNumberStimulus {
    if (!self.randomNumberStimulus) self.randomNumberStimulus = [[BTStimulus alloc] init ];
    
    
}

- (BTStimulus *) getRandomNumberStimulus {
    if (!self.randomNumberStimulus) {self.randomNumberStimulus = [[BTStimulus alloc] init];}
    return self.randomNumberStimulus;
}

- (IBAction)responseButtonPressed:(UIButton*)sender {
    // check if the response matches the stimulus, and if so, save to ResultsTracker
    
    if ([sender isKindOfClass:[ UIButton class]]){
        
        
        NSTimeInterval duration = [self.roundTimer elapsedTime]-0.5;
        
        BTResponse *thisResponse = [[BTResponse alloc] initWithString:sender.titleLabel.text];
        
        if ([self.randomNumberStimulus matchesStimulus:thisResponse] & !self.alreadyResponded) {
            NSLog(@"success: response matches stimulus");
          //  [thisResponse setResponseTime:duration];  // means the same thing as below:
            thisResponse.responseTime = duration;

   
            [self.results saveResult:thisResponse];
            
            double g=[self.results percentileOfResponse:thisResponse];
        
            self.timeLabel.text = [[NSString alloc] initWithFormat:@"%f\nPress to try again\nPercentile=%2.3f",duration,g];
            self.stimulusPresenter.backgroundColor = [UIColor blackColor];
            
            self.alreadyResponded = YES;
        }
        
            else NSLog(@"failure: response doesn't match stimulus");
    }
    
}

- (IBAction)startButtonPressed:(id)sender {
    self.occludeLabel.alpha = 0.0;
    self.timeLabel.text=@"";
    self.stimulusPresenter.alpha = 0.0;  // view is invisible
    self.stimulusPresenter.backgroundColor = [UIColor whiteColor];
   
    self.alreadyResponded=NO;
    
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(occludeStimulusView) userInfo:nil repeats:NO];
    
    
/// test code below
    
/*
    
    [NSThread sleepForTimeInterval:2.0];
    
 
 uint stim = [self.randomNumberStimulus newStimulus];
 
 self.stimulusNumberLabel.text = [[NSString alloc] initWithFormat:@"%d",stim];
 
 [self.roundTimer startTimer];
 
 self.stimulusPresenter.alpha = 1.0;
 
*/ //^^^^^^
    
    self.stimulusNumberLabel.text = @"";

}


- (void) prepareUserResponse {
    
    
}


- (void) occludeStimulusView { // puts something on top of the StimulusView so you can't see the numberst
    

//    [UIView animateWithDuration:0.5
//                          delay:0.0
//                        options:UIViewAnimationOptionBeginFromCurrentState
//                     animations:^{self.stimulusPresenter.alpha = 1.0;}
//                     completion:NULL
//     ];
//    
    
    
    
    
    uint stim = [self.randomNumberStimulus newStimulus];
    
    self.stimulusNumberLabel.text = [[NSString alloc] initWithFormat:@"%d",stim];
    
    [self.roundTimer startTimer];
  
    self.stimulusPresenter.alpha = 1.0;
    
    
    
}
- (IBAction)timerButtonPressed:(id)sender {
    
    self.timeLabel.text = [[NSString alloc] initWithFormat:@"%f",[[NSDate date] timeIntervalSinceDate:self.lastTime]];
    self.lastTime=[NSDate date];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
  [self occludeStimulusView];  // hide the stimulus in a fancy way
    
    self.stimulusPresenter.backgroundColor = [UIColor blackColor];
    self.stimulusPresenter.alpha = 1.0;
    self.stimulusNumberLabel.text = @"";
    self.randomNumberStimulus = [[BTStimulus alloc] init];
    self.alreadyResponded = YES;
    self.timeLabel.text = @"Press to Start";
    
    self.lastTime = [NSDate date];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
