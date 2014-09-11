//
//  BTDataSession.h
//  BrainTracker
//
//  Created by Richard Sprague on 4/9/14.
//  Copyright (c) 2014 Richard Sprague. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BTData;

@interface BTDataSession : NSManagedObject

@property (nonatomic, retain) NSDate * sessionDate;
@property (nonatomic, retain) NSString * sessionComment;
@property (nonatomic, retain) NSNumber * sessionScore;  // a percentile, value from 0.0 to 1.0
@property (nonatomic, retain) NSNumber * sessionRounds; // integer number of rounds in this session
@property (nonatomic, retain) BTData *whichResponse;

@end