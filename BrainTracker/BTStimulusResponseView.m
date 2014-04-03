//
//  BTStimulusResponseView.m
//  BrainTracker
//
//  Created by Richard Sprague on 3/24/14.
//  Copyright (c) 2014 Richard Sprague. All rights reserved.
//

#import "BTStimulusResponseView.h"


@interface BTStimulusResponseView()

@property (strong, nonatomic) UIColor *buttonColor;

@end



@implementation BTStimulusResponseView

{
    CGPoint previousLocation;
    uint idNum;
}


#pragma mark Setters/Getters


- (UIColor *) buttonColor {
    
    UIColor *color = [UIColor greenColor];
    if (!_buttonColor) {
        [self setColor:color];
        
    } else color = _buttonColor;
    
    return color;
    
}
- (void) setColor: (UIColor *) color {
    
    if (!_buttonColor) {
        _buttonColor = [[UIColor alloc] init];
        _buttonColor  = [UIColor greenColor];
    }
    
    self.buttonColor = color;
    
    [self setNeedsDisplay]; //update the new color right away
    
}
- (UIBezierPath *) circleButton {
    
    UIBezierPath *cPath = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    
    
    return cPath;
    
}


- (id) initWithFrame:(CGRect)frame id: (uint) num {
    
    self=[super initWithFrame:frame
          ];
    
    idNum = num;
    self.backgroundColor = nil; // makes background transparent
    self.opaque = NO;
//        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
 //    self.gestureRecognizers = @[pan];
    return self;
    
}



- (UIImage *)createImage
{
	UIColor *color = [self buttonColor];
    
	
    
	UIGraphicsBeginImageContext(self.bounds.size);
    
	// Create a filled ellipse
	[color setFill];
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    [path fill];
	
	
	UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return theImage;
}


#pragma mark Touch Handling
- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
	CGPoint translation = [gestureRecognizer translationInView:self.superview];
	CGPoint newcenter = CGPointMake(previousLocation.x + translation.x, previousLocation.y + translation.y);
	
	// Bound movement into parent bounds
	float halfx = CGRectGetMidX(self.bounds);
	newcenter.x = MAX(halfx, newcenter.x);
	newcenter.x = MIN(self.superview.bounds.size.width - halfx, newcenter.x);
	
	float halfy = CGRectGetMidY(self.bounds);
	newcenter.y = MAX(halfy, newcenter.y);
	newcenter.y = MIN(self.superview.bounds.size.height - halfy, newcenter.y);
	
	// Set new location
	self.center = newcenter;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.delegate didReceiveTouchAtTime:[[touches anyObject] timestamp] from:idNum];
    previousLocation = self.center;
    
}

- (void) showLabels {
    NSString *numLabelString = [[NSString alloc] initWithFormat:@"%d",idNum];
    NSAttributedString *numLabel = [[NSAttributedString alloc] initWithString:numLabelString];
    
    
    [numLabel drawAtPoint:(CGPoint){floor(self.bounds.size.width/2-5),floor(self.bounds.size.height/2-5)}];
    
}

#pragma mark External Instance Methods

- (void) animatePresence {
    
   
    [UIView animateWithDuration:3.0 animations:^{
        [self setAlpha:1.0];
    } completion:^(BOOL finished) {
        [self setAlpha:0.0];
    }];
    
}



- (void) drawGreen {
    [self setColor:[UIColor greenColor]];
    
}

- (void) drawRed {
    [self setColor:[UIColor redColor]];
}

- (void) drawColor: (UIColor*) newColor {
    [self setColor:newColor];
}


- (void)drawRect:(CGRect)rect
{
    

    self.backgroundColor = nil;
    self.opaque = NO;

    
    UIImageView *circleImage = [[UIImageView alloc] initWithImage:[self createImage]];
    
    [self addSubview:circleImage];
    
   
    
}


@end
