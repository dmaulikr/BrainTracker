//
//  BTStimulusResponseView.m
//  BrainTracker
//
//  Created by Richard Sprague on 3/24/14.
//  Copyright (c) 2014 Richard Sprague. All rights reserved.
//

#import "BTStimulusResponseView.h"

#import "BTResponse.h"

@interface BTStimulusResponseView()

@property (strong, nonatomic) UIColor *buttonColor;
@property (strong, nonatomic) UIImageView *myImage;

//@property (strong,nonatomic) NSAttributedString *labelForView;

@end



@implementation BTStimulusResponseView

{
    CGPoint previousLocation;
    bool isOutlined; // set to TRUE when you want the shape to be outlined
    
  //  uint idNum;
}


#pragma mark Setters/Getters

- (UIImageView *) myImage
{
    if (!_myImage)
    {_myImage = [[UIImageView alloc] initWithImage:[self createImage]]; // [UIImage imageNamed:@"MoleImageGreen"]]; //
    }
    
    return _myImage;
}


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
  //  self.alpha=1.0;
    
    
    [self setNeedsDisplay]; //update the new color right away
    
}
- (UIBezierPath *) circleButton {
    
    UIBezierPath *cPath = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    
    
    return cPath;
    
}





- (UIImage *)createImage
{
	UIColor *color = [self buttonColor];
    
	
    
	UIGraphicsBeginImageContext(self.bounds.size);
    
	// Create a filled ellipse
	[color setFill];
//    
//    CAGradientLayer *gradient = [CAGradientLayer layer];
//    gradient.frame = self.bounds;
//    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[[UIColor blackColor] CGColor], nil];
//    [self.layer insertSublayer:gradient atIndex:0];]
    
//    CGRect smallerRect = CGRectMake(self.bounds.origin.x+2, self.bounds.origin.y+2, self.bounds.size.width-2, self.bounds.size.height-2);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    
    
    
    
    [path fill];
    
    if (isOutlined) { // yes, put a dark circle around the shape
        path.lineWidth = 2.0;
        [[UIColor blackColor] setFill];
        [path stroke];
        
    }
    isOutlined = false;
    
    
    
    
//    UIBezierPath *innerCircle = [UIBezierPath bezierPathWithOvalInRect:smallerRect];
//    
//    
//    
//    [[UIColor blackColor] setFill];
//    [path fill];
    
    [self showLabels];
	
	UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return theImage;
}


//#pragma mark Touch Handling
//- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
//{
//	CGPoint translation = [gestureRecognizer translationInView:self.superview];
//	CGPoint newcenter = CGPointMake(previousLocation.x + translation.x, previousLocation.y + translation.y);
//	
//	// Bound movement into parent bounds
//	float halfx = CGRectGetMidX(self.bounds);
//	newcenter.x = MAX(halfx, newcenter.x);
//	newcenter.x = MIN(self.superview.bounds.size.width - halfx, newcenter.x);
//	
//	float halfy = CGRectGetMidY(self.bounds);
//	newcenter.y = MAX(halfy, newcenter.y);
//	newcenter.y = MIN(self.superview.bounds.size.height - halfy, newcenter.y);
//	
//	// Set new location
//	self.center = newcenter;
//}



- (NSAttributedString*) attributedStringOfIdNum {
    
    NSString *numLabelString = [[NSString alloc] initWithFormat:@"%d",[self.idNum intValue]];
    NSMutableAttributedString *numLabel = [[NSMutableAttributedString alloc] initWithString:numLabelString];
    
    
    return numLabel;
}

// show a label on this object, precisely positioned at the center.
- (void) showLabels {
    
    if (self.label) {

    
    float centerX = self.bounds.size.width/2 + self.bounds.origin.x;
    float centerY = self.bounds.size.height/2 + self.bounds.origin.y;
        CGSize stringSize = CGSizeMake(self.label.attributedText.size.width, self.label.attributedText.size.height);

        
          [self.label.attributedText drawInRect:CGRectMake(centerX-stringSize.width/2, centerY-stringSize.height/3*4, centerX+stringSize.width/2, centerY+stringSize.height/2)];
 //   NSLog(@"drawing %@ at %@",numLabel, NSStringFromCGRect(self.frame));
    } // else NSLog(@"no label here");

    
}

#pragma mark External Instance Methods


// the view goes from fully-on (i.e. alpha=1.0) to completely disappeared (alpha=0.0) in somewhere between 1.5 and 2.5 seconds.
- (void) animatePresenceWithBlink {
    
           self.transform = CGAffineTransformMakeScale(0.0, 0.0);
    
    NSTimeInterval randomLag = (NSTimeInterval) (arc4random() / UINT32_MAX) ; // (random number between 0.0 and 1.0), but doesn't work
    
    //NSTimeInterval randomLag = ((NSTimeInterval)arc4random() / 0x100000000);  // this one works
    
    [UIView animateWithDuration:(1.5+randomLag*2) animations:^{
        [self setAlpha:1.0];
        self.transform = CGAffineTransformIdentity;

    } completion:^(BOOL finished) {
        [self setAlpha:0.0];
        self.transform = CGAffineTransformIdentity;
        
        [self.delegate didFinishForeperiod];
        
    }];
    
}

- (void) animatePresenceAndStay {
    
            self.transform = CGAffineTransformMakeScale(0.0, 0.0);
    [UIView animateWithDuration:2.0 animations:^{
        [self setAlpha:1.0];
      self.transform = CGAffineTransformIdentity;

    } completion:^(BOOL finished) {
        [self setAlpha:1.0];
        self.transform = CGAffineTransformIdentity;
        [self drawRed];


    }];
    
}

- (void) drawGreen {
    [self setColor:[UIColor greenColor]];
  //  self.subviews[[self.subviews count]] = [[UIImageView alloc] initWithImage:[self createImage]];
    
 }

- (void) drawRed {
    
     [self setColor:[UIColor redColor]];
    isOutlined = true;
    
}

- (void) drawColor: (UIColor*) newColor {
    [self setColor:newColor];
}




- (void)drawRect:(CGRect)rect
{
    

//    self.backgroundColor = nil;
 //   self.opaque = NO;

    if (!_myImage)
    {
        [self addSubview:self.myImage];
    } else
        
    {
        
        [self.subviews[0] removeFromSuperview]; // get rid of the most recent subview
        
        
        // create a new subview that recomputes the color of the image.
        UIImageView *circleImage = [[UIImageView alloc] initWithImage:[self createImage]];
        
        [self addSubview:circleImage];
        
    }
    
 


    [self showLabels];
    
}

#pragma mark Initializers

// the new button will contain a response. Note that a "response" could also be a stimulus.

- (id) initWithFrame:(CGRect)frame {
    NSLog(@"error: initializing BTStimulusResponseView without a response"); 
    return [self initWithFrame:frame forResponse:NULL];
   
    
}

- (id) initWithFrame:(CGRect)frame forResponse: (BTResponse *) response {
    
    self=[super initWithFrame:frame
          ];
    
    self.response = response;
    isOutlined = true;
    
    self.idNum = [[[NSNumberFormatter alloc] init] numberFromString:[response responseLabel]];
                  
    self.backgroundColor = nil; // makes background transparent
    self.opaque = NO;
    self.alpha = 1.0; 
    //        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    //    self.gestureRecognizers = @[pan];
    return self;
    
}



@end
