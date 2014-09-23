//
//  BTResultsTracker.h
//  BrainTracker
//
//  Created by Richard Sprague on 3/5/14.
//  Copyright (c) 2014 Richard Sprague. All rights reserved.
//
/*
 
 Typically you'll only have one of these objects per user of the app.
 
 Each instantiation of this class should check whether or not some results already exist.  If so, they become part of the instantiation.
 
 In early drafts of this class, results can be kept in NSUserDefaults, but everything should be designed to easily swap to something else (e.g. CoreData) automatically.
 
 Always, always store results using this class. If you do that, then nobody needs to know if the underlying storage mechanism changes.
 
 
  In an earlier draft, I tried to make:
 
 NSUserDefaults holds the key KEY_FOR_RESPONSES whose value is an array of responses.
 but it's not easy to store an array in NSUserDefaults, so I scratched that.
 
 In this draft, permanent storage is a Core Data document "BTData".
 
 BTResultsTracker should ideally be instantiated only once per session, i.e. once each time the app is loaded and used.
 
 BTResultsTracker should therefore be given a BTData-associated NSManagedObjectContext during initialization, and it should keep the context for later.
 
 All responses are kept in two places:
 * the NSMutableArray *responses , which is just a convenience in early drafts of this app.  I'm more familiar with arrays than with Core Data.
 * the core data database.
 Every time you save a result, the response is stored in both of the above places.
 
 
*/

#define KEY_FOR_RESPONSES @"BTResponses"

// values set in BTResponse.m

extern NSString * const kBTtrialResponseStringKey;
extern NSString * const kBTtrialLatencyKey;
extern NSString * const kBTtrialTimestampKey;



extern NSTimeInterval kBTLatencyCutOffValue;

extern int const kBTlastNTrialsCutoffValue;


#import <Foundation/Foundation.h>

@class BTResponse;
@class BTSession;
@class BTTrial;



@interface BTResultsTracker : NSObject

//- (void) saveResult: (BTResponse *) response;
- (void) saveTrial: (BTTrial *) trial;
- (void) saveSession: (BTSession *) session;
- (double) percentileOfResponse: (BTResponse *) response;
- (BOOL) isUnderCutOff: (NSTimeInterval)  responseLatency;



@end
