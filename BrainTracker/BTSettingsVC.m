//
//  BTSettingsVC.m
//  BrainTracker
//
//  Created by Richard Sprague on 3/5/14.
//  Copyright (c) 2014 Richard Sprague. All rights reserved.
//

// #import "BTGlobals.h"  // see BrainTracker-Prefix.pch
#import "BTSettingsVC.h"
#import "BTDataTrial.h"
#import "BTResponse.h"
#import "BTDataSession.h"
#import "BTFileReader.h"
#import "ZBConnection.h"

NSString * const kZenobaseHardCodedURL = @"https://zenobase.com/#/oauth/authorize?response_type=token&client_id=317cg8pqd1&redirect_uri=x-braintracker:///";
// signed up with username=braintracker password = braintracker
// hardcoded because Zenobase needs to know *which* account posted the information.
// Zenobase will interpret any client app that posts as having been originated from this account.



@interface BTSettingsVC ()<ZBConnectionProtocol>

@property (weak, nonatomic) IBOutlet UITextField *latencyCutOffTextField;
@property (weak, nonatomic) IBOutlet UILabel *ZBAccessTokenLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *interfaceSelectorSegmentedControl;

@property (weak, nonatomic) IBOutlet UISwitch *precisionControlSwitch;
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (weak, nonatomic) IBOutlet UIStepper *trialsPerSessionStepper;
@property (weak, nonatomic) IBOutlet UILabel *trialsPerSessionLabel;
@end

uint const kBTNumberOfStimuli = 6;
NSString * const kBTMaxTrialsPerSessionKey = @"trialsPerSession";
NSString * const kBTPrecisionControlKey = @"precisionControl"; // if you want to review every result before saving it
NSString * const kBTLatencyCutOffValueKey = @"latencyCutOffValue";
NSString * const kBTZBAccessTokenKey = @"ZBAuthTokenKey";
NSString * const kBTZBClientIDKey = @"ZBClientIDKey";
NSString * const kBTZBScopeTokenKey = @"ZBScopeTokenKey";

NSTimeInterval kBTLatencyCutOffValue = 3.0;
NSString *ZBAccessToken = nil;
NSString *ZBScopeToken = nil;

bool kBTPrecisionControl;


//extern enum {BTInterfaceArc,BTInterfaceLines} BTInterfaceSelection;
//enum {BTInterfaceArc,BTInterfaceLines} BTInterfaceSelection;
//enum  BTInterfaceSelection ;

BTInterfaceSelectionType BTInterfaceSelection = BTInterfaceLines;  // initialize so default = Lines interface

bool  BTuseZB = true;  // placeholder for some global setting that allows turning it on or off

@implementation BTSettingsVC
{
    NSNumber *trialsPerSession;
    


}

#pragma mark IBAction methods

- (IBAction)pressedTrialsPerSessionStepper:(id)sender {
    
    if ([sender isKindOfClass:[UIStepper class]]){
        if (trialsPerSession){
            
            trialsPerSession = [NSNumber numberWithInt:(int)self.trialsPerSessionStepper.value];
            [[NSUserDefaults standardUserDefaults] setObject:trialsPerSession forKey:kBTMaxTrialsPerSessionKey];
            self.trialsPerSessionLabel.text = [[NSString alloc] initWithFormat:@"%d",[trialsPerSession intValue] ];
            
        } else NSLog(@"error: unknown settings for trials per session");
        
    }
    
   
}
- (IBAction)flippedPrecisionControl:(id)sender {
    
    kBTPrecisionControl = !kBTPrecisionControl; //self.precisionControlSwitch.state;
}

- (void) selectInterface {
    
    
  //  extern enum {BTInterfaceArc,BTInterfaceLines} BTInterfaceSelection;
   // BTInterfaceSelection = BTInterfaceArc;

  
  

    
    if (self.interfaceSelectorSegmentedControl.selectedSegmentIndex==0)
        
        BTInterfaceSelection = BTInterfaceArc;
    
        else
            BTInterfaceSelection = BTInterfaceLines;

  NSLog(@"Setting BTInterfaceSelection to %u",BTInterfaceSelection);
        
}

- (IBAction) enteredTextForLatencyCutoff:(id)sender {
    
    if ([sender isKindOfClass:[UITextField class]]){
        NSString *fieldString = self.latencyCutOffTextField.text;
        NSScanner *myScanner = [NSScanner scannerWithString:fieldString];
        double myDouble;
        if ([myScanner scanDouble:&myDouble] & [myScanner isAtEnd]){
            
            NSLog(@"You entered %f but rest of location is %d",myDouble, (int)[myScanner scanLocation]);
        }
        else {NSLog(@"you entered a non-number %@",fieldString);}
        kBTLatencyCutOffValue = myDouble/1000;
        [[NSUserDefaults standardUserDefaults] setObject:[[NSNumber alloc] initWithDouble:kBTLatencyCutOffValue]forKey:kBTLatencyCutOffValueKey];
        NSLog(@"Latency Cutoff = %0.3f",kBTLatencyCutOffValue);
        [sender resignFirstResponder];
    }
    
    else NSLog(@"not a class");
}



- (IBAction)pressSetUpZenobase:(id)sender {
    
    [self askForZBAccessToken];
}



- (IBAction)pressFillDatabase:(id)sender {
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self dataFilePath]]) {
        // no file exists, so just alert the user and ignore
        
        NSLog(@"No results file exists ");
        
    } else { // assume it's a valid CSV file and parse it
        
        BTFileReader *CSVFile = [[BTFileReader alloc] init] ;
        [CSVFile readFromDisk:[self dataFilePath]];
        
        //[self readFromDisk];
        
    }
    
    
    /* to fill the database with values, uncomment this code
     for (uint i = 0;i<10;i++) {
     [self fillOneItemInDatabase];
     }
     */
}

#pragma mark Test Methods for Filling the Database

- (NSDate *) startDate {
    
    NSString *Jan1ThisYear = @"01-Jan-2014";
    NSDateFormatter *Jan1Formatted = [[NSDateFormatter alloc] init];
    Jan1Formatted.dateFormat = @"dd-MMM-yyyy";
    NSDate *Jan1date = [Jan1Formatted dateFromString:Jan1ThisYear];
    
    
    return Jan1date;
}

- (NSString *) randomString {
    
    
    NSArray *rs = @[@"2",@"3",@"4",@"5",@"6",@"7",@"8"];
    uint num = arc4random() % [rs count];
    return rs[num];
    
}

- (NSTimeInterval) randomDays {  // a random number of days between 0 and 65 (expressed as timeInterval)
    
    int oneDay = 24*60*60;
 //   int oneWeek = oneDay*7;
    
    NSTimeInterval days = ((double) (arc4random() % oneDay)) * 65;
    
    return days;
    
}

- (void) fillOneItemInDatabase {
    BTResponse *response = [[BTResponse alloc] initWithString:[self randomString]];
    
  //  double val = ((double)arc4random() / 0x100000000);
    
    double margin = (500.0 + ((double) (arc4random() % 100)))/1000.0; // between 500 and 600 ms

    
    response.responseLatency = margin;
    
    
    NSDate *randomDateSinceJan1 = [NSDate dateWithTimeInterval:[self randomDays] sinceDate:[self startDate]]; //
    
    BTDataTrial *BTDataResponse = [NSEntityDescription insertNewObjectForEntityForName:@"BTDataTrial" inManagedObjectContext:self.context];
    
    BTDataResponse.trialLatency = response.response[kBTtrialLatencyKey];
    BTDataResponse.trialResponseString = response.response[kBTtrialResponseStringKey];
    BTDataResponse.trialTimeStamp = randomDateSinceJan1;
    
    
}






- (NSManagedObjectContext *) managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]){
        context = [delegate managedObjectContext];
    }
    
    return context;
}

- (void) doInitializationsIfNecessary {
    
    trialsPerSession = [[NSUserDefaults standardUserDefaults] objectForKey:kBTMaxTrialsPerSessionKey];
    
    if (!trialsPerSession){ // first time user
        [[NSUserDefaults standardUserDefaults] setObject:@32 forKey:kBTMaxTrialsPerSessionKey];
    }
    trialsPerSession = [[NSUserDefaults standardUserDefaults] objectForKey:kBTMaxTrialsPerSessionKey];

    self.trialsPerSessionLabel.text=[[NSString alloc] initWithFormat:@"%d",[trialsPerSession intValue]];
    
}

#pragma mark Read/write from disk



- (void) saveToDisk: (NSString *) inputString  duration: (NSTimeInterval) duration comment: (NSString *) comment{
    
    NSString *textToWrite = [[NSString alloc] initWithFormat:@"%@,%@,%f,%@\n",[NSDate date], inputString,duration,comment];
    NSFileHandle *handle;
    handle = [NSFileHandle fileHandleForWritingAtPath: [self dataFilePath] ];
    //say to handle where's the file fo write
    [handle truncateFileAtOffset:[handle seekToEndOfFile]];
    //position handle cursor to the end of file
    [handle writeData:[textToWrite dataUsingEncoding:NSUTF8StringEncoding]];
    
}
/*
- (void) readFromDisk {
    
    
    
    NSError *error;
    
    NSString *fileContents = [[NSString alloc] initWithContentsOfFile:[self dataFilePath] encoding:NSASCIIStringEncoding error:&error];
    
    if(error) {NSLog(@"couldn't get components of file");
    }else {
        
        
 
    NSArray *allLinesInFile = [fileContents componentsSeparatedByString:@"\r"];
    //    NSString *csvFileHeader = allLinesInFile[0];
        
        NSRange rangeForFile = NSMakeRange(1,[allLinesInFile count]-2);
        
        NSArray *linesInFile = [allLinesInFile subarrayWithRange:rangeForFile];
        
        NSAssert(rangeForFile.length>1,@"CSV file is not greater than one line");
    
    for (NSString *eachLineInFile in linesInFile){
        NSArray *valuesInLine = [eachLineInFile componentsSeparatedByString:@","];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
        
        NSDate *valueDate = [dateFormatter dateFromString:valuesInLine[0]]; //@"2014-09-05 19:28:40 +0000"]; // //];  //[NSDate date]; //[dateFormatter dateFromString:valuesInLine[0]];  //[dateFormatter dateFromString:valuesInLine[0]];
      
        NSString *valueString = valuesInLine[1];
     
        NSNumber *valueLatency = [[[NSNumberFormatter alloc] init] numberFromString:valuesInLine[2]];
        NSNumber *valueLatencyMsec = [NSNumber numberWithDouble:([valueLatency doubleValue] / 1000)] ;
        
        
        

        NSString *valueComment = valuesInLine[3];
 
        
        if ([valueString isEqualToString:@"Session"]) {
            NSLog(@"Session Results = %@",valueLatency);
            NSLog(@"comment=%@",valueComment);
            BTDataSession *newSession =[NSEntityDescription insertNewObjectForEntityForName:@"BTDataSession" inManagedObjectContext:self.context];
            
            newSession.sessionDate = valueDate;
            newSession.sessionRounds = [[NSUserDefaults standardUserDefaults] objectForKey:kBTMaxTrialsPerSessionKey];
            newSession.sessionScore = valueLatency;
            newSession.sessionComment = [[NSString alloc] initWithFormat:@"%@ (new)",valueComment];
            
        } else {
            NSLog(@"date=%@",valueDate);
            NSLog(@"string=%@",valueString);
            NSLog(@"latency=%f",[valueLatencyMsec doubleValue]);
            
            BTDataTrial *BTDataResponse = [NSEntityDescription insertNewObjectForEntityForName:@"BTDataTrial" inManagedObjectContext:self.context];
            
            BTDataResponse.trialLatency = valueLatencyMsec;
            BTDataResponse.trialResponseString = valueString;
            BTDataResponse.trialTimeStamp = valueDate;
            
        }
//        
//        
//        for (NSString *oneCSVValue in valuesInLine) {
//            
//      
//            NSLog(@"(%@)",oneCSVValue);
//            
//    }
        NSLog(@"\n");
        
        
    }}
    
}
*/


-(NSString *)dataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"BrainTrackerResultsFile.csv"];
}

#pragma mark Zenobase methods

- (void) didReceiveJSON:(NSDictionary *)json {
    
    NSLog(@"didReceiveJSON in %s",__func__);
}

- (void) askForZBAccessToken {
    
    NSURL *url = [NSURL URLWithString:[[NSString alloc] initWithString:kZenobaseHardCodedURL]];
    [[UIApplication sharedApplication] openURL:url];
    
    if(ZBAccessToken ) {
        self.ZBAccessTokenLabel.text = ZBAccessToken;
    }
    
}


#pragma mark General

- (void) viewWillAppear:(BOOL)animated {
    
    if(ZBAccessToken ) {
        self.ZBAccessTokenLabel.text = ZBAccessToken;
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.context = [self managedObjectContext];
    [self doInitializationsIfNecessary];
    
    trialsPerSession = [[NSUserDefaults standardUserDefaults] objectForKey:kBTMaxTrialsPerSessionKey];
    self.trialsPerSessionLabel.text = [trialsPerSession description];
    
    [self.interfaceSelectorSegmentedControl addTarget:self action:@selector(selectInterface )forControlEvents:UIControlEventValueChanged
     
     ];
    
    
    ZBAccessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kBTZBAccessTokenKey];
    
    if (!ZBAccessToken){
        
        
        self.ZBAccessTokenLabel.text = @"no token";
    } else {
   
    self.ZBAccessTokenLabel.text = ZBAccessToken;
    }
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
