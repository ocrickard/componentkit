/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import "CKTextComponentLayerLoupeController.h"

#import "CKTextComponentLayerLoupeLayer.h"
#import "CKAssert.h"

#include <sys/utsname.h>

@interface CKLoupeRotatingRootViewController : UIViewController

@end

@implementation CKLoupeRotatingRootViewController

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
  return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate
{
  return YES;
}

@end

@implementation CKTextComponentLayerLoupeController
{
  __weak CALayer *_targetLayer;
  UIWindow *_window;
  CKTextComponentLayerLoupeLayer *_loupeLayer;

  CADisplayLink *_displayLink;

  BOOL _visible;
  BOOL _enableLiveUpdating;
  BOOL _invalidated;
}

- (instancetype)initWithTargetLayer:(CALayer *)targetLayer
{
  if (self = [super init]) {
    _targetLayer = targetLayer;
  }
  return self;
}

- (void)_updateDisplay
{
  _loupeLayer.pointOfInterest = _pointOfInterest;
}

- (void)setPointOfInterest:(CGPoint)pointOfInterest
{
  _pointOfInterest = pointOfInterest;
  [_loupeLayer setPointOfInterest:_pointOfInterest];

  CGPoint convertedPosition = [_window.layer convertPoint:_pointOfInterest
                                                fromLayer:_targetLayer];;

  [CATransaction begin];
  [CATransaction setDisableActions:YES];

  CGRect frame = CGRectMake(convertedPosition.x - _loupeLayer.anchorPoint.x * _loupeLayer.bounds.size.width,
                            convertedPosition.y - _loupeLayer.anchorPoint.y * _loupeLayer.bounds.size.height,
                            _loupeLayer.bounds.size.width,
                            _loupeLayer.bounds.size.height);
  if (frame.origin.x < 0) {
    frame.origin.x = 0;
  }
  if (frame.origin.y < 0) {
    frame.origin.y = 0;
  }
  if (CGRectGetMaxX(frame) > _window.bounds.size.width) {
    frame.origin.x = _window.bounds.size.width - frame.size.width;
  }
  if (CGRectGetMaxY(frame) > _window.bounds.size.height) {
    frame.origin.y = _window.bounds.size.height - frame.size.height;
  }

  CGPoint newPosition = CGPointMake(frame.origin.x + _loupeLayer.anchorPoint.x * _loupeLayer.bounds.size.width,
                                    frame.origin.y + _loupeLayer.anchorPoint.y * _loupeLayer.bounds.size.height);
  if (newPosition.x == INFINITY || newPosition.y == INFINITY) {
    NSLog(@"uh oh");
  }
  _loupeLayer.position = newPosition;
  [CATransaction commit];
}

- (void)presentLoupe
{
  CKAssertMainThread();
  if (_visible) {
    return;
  }
  _visible = YES;
  if (!_window) {
    _window = [[UIWindow alloc] init];
    _window.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _window.hidden = YES;
    _window.userInteractionEnabled = NO;
    _window.windowLevel = UIWindowLevelAlert;
    _window.backgroundColor = [UIColor clearColor];
    // Unfortunately we need this for the window to autorotate with the screen :(
    _window.rootViewController = [[CKLoupeRotatingRootViewController alloc] init];
  }

  if (!_loupeLayer) {
    _loupeLayer = [[CKTextComponentLayerLoupeLayer alloc] initWithTargetLayer:_targetLayer];
    _loupeLayer.frame = CGRectMake(0, 0, 125, 127);
    _loupeLayer.anchorPoint = CGPointMake(0.5, 1.0);
    _loupeLayer.hidden = YES;
    [_window.layer addSublayer:_loupeLayer];
  }

  [self setPointOfInterest:_pointOfInterest];

  _window.hidden = NO;
  _loupeLayer.hidden = NO;

  CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
  animation.fromValue = [NSNumber numberWithFloat:0.1];
  animation.toValue = [NSNumber numberWithFloat:1.0];
  animation.duration = 0.1;
  animation.removedOnCompletion = YES;
  animation.fillMode = kCAFillModeForwards;
  animation.removedOnCompletion = YES;
  [_loupeLayer addAnimation:animation forKey:@"zoom"];

  if (!_displayLink) {
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(_updateDisplay)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
  }
}

- (void)dismissLoupe
{
  CKAssertMainThread();
  _visible = NO;
  [CATransaction begin];
  [CATransaction setCompletionBlock:^{
    // Intentionally take a strong ref to self until the animation completes.
    _window.hidden = YES;
    _loupeLayer.hidden = YES;
  }];
  CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
  animation.fromValue = [NSNumber numberWithFloat:1.0];
  animation.toValue = [NSNumber numberWithFloat:0.1];
  animation.duration = 0.1;
  animation.removedOnCompletion = YES;
  animation.fillMode = kCAFillModeForwards;
  animation.removedOnCompletion = NO;
  [_loupeLayer addAnimation:animation forKey:@"zoom"];
  [CATransaction commit];

  [_displayLink invalidate];
  _displayLink = nil;
}

- (void)invalidate
{
  CKAssertMainThread();
  [_loupeLayer removeFromSuperlayer];
  [_displayLink invalidate];
  _visible = NO;
  _invalidated = YES;
}

- (BOOL)isLoupeVisible
{
  return _visible;
}

- (void)dealloc
{
  CKAssert(_invalidated, @"Must have invalidated loupe controller before dealloc.");
}

@end
