//
//  ViewController.h
//  SlideOutKeyboard
//
//  Created by Szi Gabor on 9/4/15.
//  Copyright (c) 2015 Szi Gabor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (strong,nonatomic)UIVisualEffectView *trayView;
@property (strong,nonatomic)NSLayoutConstraint  *trayleftEdgeConstraints;
@property (strong,nonatomic)UIDynamicAnimator  *animator;
@property (strong,nonatomic)UIGravityBehavior  *gravity;
@property (strong,nonatomic)UIAttachmentBehavior  *panAttachmentBehavior;

@property (nonatomic,assign) BOOL gravityIsLeft;

@end

