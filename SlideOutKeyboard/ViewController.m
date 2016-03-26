//
//  ViewController.m
//  SlideOutKeyboard
//
//  Created by Szi Gabor on 9/4/15.
//  Copyright (c) 2015 Szi Gabor. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
#define GUTTER_WIDTH 100

- (void)viewDidLoad {
    [super viewDidLoad];

    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"iOS.png"]];
    //    imageView.frame = self.view.frame --- If you do not want to set your own constraints manually
    imageView.translatesAutoresizingMaskIntoConstraints = NO; //change to Yes if you do not want to set your own contraints manually
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imageView)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imageView)]];
    
    [self setUpTrayView];
    [self setUpGestureRecognizers];
    self.animator = [[UIDynamicAnimator alloc]initWithReferenceView:self.view];
    [self setUpBehaviors];
}


-(void)pan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint currentPoint = [recognizer locationInView:self.view];
    CGPoint xOnlyLocation = CGPointMake(currentPoint.x, self.view.center.y);
    
    
    
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        self.panAttachmentBehavior = [[UIAttachmentBehavior alloc]initWithItem:self.trayView attachedToAnchor:xOnlyLocation];
        [self.animator addBehavior:self.panAttachmentBehavior];
    }
    
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        self.panAttachmentBehavior.anchorPoint = xOnlyLocation;
    }
    else if ((recognizer.state == UIGestureRecognizerStateEnded) ||
             (recognizer.state ==  UIGestureRecognizerStateCancelled))
    {
        [self.animator removeBehavior:self.panAttachmentBehavior];
        CGPoint velocity = [recognizer velocityInView:self.view];
        CGFloat velocityThrowingThreshold = 500;
        
        if(ABS(velocity.x) > velocityThrowingThreshold)
        {
            BOOL isLeft = (velocity.x < 0 );
            [self updateGravityIsLeft:isLeft];
        }
        else
        {
            BOOL isLeft = (self.trayView.frame.origin.x < self.view.center.x);
            [self updateGravityIsLeft:isLeft];
        }
    }
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self.animator removeAllBehaviors];
    if (self.trayView.frame.origin.x < self.view.center.x)
    {
        self.trayleftEdgeConstraints.constant = GUTTER_WIDTH;
        self.gravityIsLeft = YES;
    }
    else
    {
        self.trayleftEdgeConstraints.constant = size.width;
        self.gravityIsLeft = NO;
    }
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self.view layoutIfNeeded];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self setUpBehaviors];
    }];
    
}

-(void)setUpBehaviors
{
    UICollisionBehavior *edgeCollisionBehavior = [[UICollisionBehavior alloc]initWithItems:@[self.trayView]];
    [edgeCollisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(0, GUTTER_WIDTH, 0, -self.view.bounds.size.width)];
    [self.animator addBehavior:edgeCollisionBehavior];
    
    //gravity
    self.gravity = [[UIGravityBehavior alloc]initWithItems:@[self.trayView]];
    [self.animator addBehavior:self.gravity];
    [self updateGravityIsLeft:self.gravityIsLeft];
}

-(void)updateGravityIsLeft:(BOOL)isLeft
{
    CGFloat angle = isLeft ? M_PI : 0;
    [self.gravity setAngle:angle magnitude:1.0];
}


-(void)setUpGestureRecognizers
{
    
    UIScreenEdgePanGestureRecognizer *edgePan = [[UIScreenEdgePanGestureRecognizer alloc]
                                                 initWithTarget:self action:@selector(pan:)];
                                                edgePan.edges = UIRectEdgeRight;
    [self.view addGestureRecognizer:edgePan];
    
    UIPanGestureRecognizer *trayPanRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    
    [self.trayView addGestureRecognizer:trayPanRecognizer];
    
}


-(void)setUpTrayView
{
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    self.trayView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
    self.trayView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.trayView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.trayView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.trayView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.trayView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    
    self.trayleftEdgeConstraints = [NSLayoutConstraint constraintWithItem:self.trayView
                                                        attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view
                                                        attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.view.frame.size.width];
    [self.view addConstraint:self.trayleftEdgeConstraints];
    
    UILabel *trayLabel = [UILabel new];
    trayLabel.text = @"Turn To Tech, \nFor aspiring Developers \nand \nFuture Entrepreneurs!";
    trayLabel.numberOfLines = 0;
    trayLabel.font = [UIFont systemFontOfSize:24];
    trayLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.trayView addSubview:trayLabel];
    
    [self.trayView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(30)-[trayLabel]-(30)-|"
                options:0 metrics:nil views:NSDictionaryOfVariableBindings(trayLabel)]];
    
    [self.trayView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(100)-[trayLabel]-(100)-|"
                options:0 metrics:nil views:NSDictionaryOfVariableBindings(trayLabel)]];
    
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [closeButton setTitle:@"[CLOSE]" forState:UIControlStateNormal];
    [closeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [closeButton addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.trayView addSubview:closeButton];
    
    [self.trayView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(30)-[closeButton(==75)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(closeButton)]];
    
    [self.trayView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(30)-[closeButton(==40)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(closeButton)]];
    
    [self.view layoutIfNeeded];
}

-(void)closeButtonPressed:(id)sender
{
    UIPushBehavior *pushBehavior = [[UIPushBehavior alloc]initWithItems:@[self.trayView] mode:UIPushBehaviorModeInstantaneous];
    pushBehavior.angle = 0;
    pushBehavior.magnitude = 200;
    
    [self updateGravityIsLeft:NO];
    
    [self.animator addBehavior:pushBehavior];
}


-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
