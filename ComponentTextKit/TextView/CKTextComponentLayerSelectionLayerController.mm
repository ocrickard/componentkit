/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import "CKTextComponentLayerSelectionLayerController.h"

#import <ComponentKit/CKInternalHelpers.h>
#import <ComponentKit/CKAssert.h>

static const CGFloat kHandleRadius = 5;

@implementation CKTextComponentLayerSelectionLayerController
{
  CALayer *_targetLayer;

  CAShapeLayer *_startHandle;
  CAShapeLayer *_endHandle;
  CALayer *_startCursor;
  CALayer *_endCursor;

  CAShapeLayer *_selectionLayer;

  BOOL _invalidated;
}

- (instancetype)initWithTargetLayer:(CALayer *)layer
                         caretColor:(UIColor *)caretColor
                     selectionColor:(UIColor *)selectionColor
{
  if (self = [super init]) {
    _targetLayer = layer;
    _caretColor = caretColor;
    _selectionColor = selectionColor;

    _startCursor = [CALayer layer];
    _startCursor.backgroundColor = _caretColor.CGColor;
    _startCursor.hidden = YES;
    [_targetLayer addSublayer:_startCursor];

    _startHandle = [CAShapeLayer layer];
    _startHandle.fillColor = _caretColor.CGColor;
    _startHandle.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-kHandleRadius, -kHandleRadius, kHandleRadius * 2, kHandleRadius * 2)].CGPath;
    _startHandle.hidden = YES;
    [_targetLayer addSublayer:_startHandle];

    _endCursor = [CALayer layer];
    _endCursor.backgroundColor = _caretColor.CGColor;
    _endCursor.hidden = YES;
    [_targetLayer addSublayer:_endCursor];

    _endHandle = [CAShapeLayer layer];
    _endHandle.fillColor = _caretColor.CGColor;
    _endHandle.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-kHandleRadius, -kHandleRadius, kHandleRadius * 2, kHandleRadius * 2)].CGPath;
    _endHandle.hidden = YES;
    [_targetLayer addSublayer:_endHandle];

    _selectionLayer = [CAShapeLayer layer];
    _selectionLayer.hidden = YES;
    _selectionLayer.fillColor = _selectionColor.CGColor;
    [_targetLayer addSublayer:_selectionLayer];
  }
  return self;
}

- (void)setShowCarets:(BOOL)showCarets
{
  _showCarets = showCarets;
  if (CGRectIsEmpty(_startCaretRect)) {
    _startHandle.hidden = YES;
  } else if (_startHandle.hidden && _showCarets) {
    _startHandle.hidden = NO;
  }
  if (CGRectIsEmpty(_endCaretRect)) {
    _endHandle.hidden = YES;
  } else if (_endHandle.hidden && _showCarets) {
    _endHandle.hidden = NO;
  }
  [self _configureCarets];
}

- (void)_configureCarets
{
  if (!_showCarets) {
    _startCursor.hidden = YES;
    _endCursor.hidden = YES;
    _startHandle.hidden = YES;
    _endHandle.hidden = YES;
  } else {
    BOOL animateHandles = NO;
    if (_startCursor.hidden || _endCursor.hidden) {
      animateHandles = YES;
    }
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _startCursor.hidden = NO;
    _endCursor.hidden = NO;

    if (animateHandles) {
      CABasicAnimation *zoomAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
      zoomAnimation.fromValue = [NSNumber numberWithFloat:0.1];
      zoomAnimation.toValue = [NSNumber numberWithFloat:1.0];
      zoomAnimation.duration = 0.1;
      zoomAnimation.removedOnCompletion = YES;
      zoomAnimation.fillMode = kCAFillModeForwards;
      [_startHandle addAnimation:zoomAnimation forKey:@"zoom"];
      [_endHandle addAnimation:zoomAnimation forKey:@"zoom"];
    }
    [CATransaction commit];
  }
  [self layoutSelectionLayers];
}

- (void)layoutSelectionLayers
{
  [CATransaction begin];
  [CATransaction setDisableActions:YES];
  _startCursor.frame = _startCaretRect;
  _endCursor.frame = _endCaretRect;
  _startHandle.position = CGPointMake(CGRectGetMidX(_startCaretRect), CGRectGetMinY(_startCaretRect) - kHandleRadius*0.8);
  _endHandle.position = CGPointMake(CGRectGetMidX(_endCaretRect), CGRectGetMaxY(_endCaretRect) + kHandleRadius*0.8);

  CGRect firstRect = _selectionRects.count > 0 ? CGRectInset([_selectionRects.firstObject CGRectValue], -1, -1) : CGRectNull;
  CGRect bigRect = CGRectNull;
  CGRect lastRect = _selectionRects.count > 1 ? CGRectInset([_selectionRects.lastObject CGRectValue], -1, -1) : CGRectNull;
  if (_selectionRects.count > 2) {
    for (int i = 1; i < _selectionRects.count - 1; i++) {
      NSValue *value = _selectionRects[i];
      bigRect = CGRectUnion(bigRect, CGRectInset(value.CGRectValue, -1, -1));
    }
  }

  UIBezierPath *bezierPath = [UIBezierPath bezierPath];

  BOOL displaySelectionLayer = NO;

  if (!CGRectIsNull(firstRect)) {
    [bezierPath appendPath:[UIBezierPath bezierPathWithRect:firstRect]];
    displaySelectionLayer = YES;
  }

  if (!CGRectIsNull(bigRect)) {
    [bezierPath appendPath:[UIBezierPath bezierPathWithRect:bigRect]];
  }

  if (!CGRectIsNull(lastRect)) {
    [bezierPath appendPath:[UIBezierPath bezierPathWithRect:lastRect]];
  }

  if (displaySelectionLayer) {
    _selectionLayer.hidden = NO;
    _selectionLayer.path = bezierPath.CGPath;
  } else {
    _selectionLayer.hidden = YES;
  }
  [CATransaction commit];
}

- (void)setStartCaretRect:(CGRect)startCaretRect
{
  _startCaretRect = startCaretRect;
  // Handle the case where the rects are zeroed (i.e. not rendered in the visible viewport)
  if (CGRectIsEmpty(_startCaretRect)) {
    _startHandle.hidden = YES;
  } else if (_startHandle.hidden && _showCarets) {
    _startHandle.hidden = NO;
  }
  [self _configureCarets];
}

- (void)setEndCaretRect:(CGRect)endCaretRect
{
  _endCaretRect = endCaretRect;
  if (CGRectIsEmpty(_endCaretRect)) {
    _endHandle.hidden = YES;
  } else if (_endHandle.hidden && _showCarets) {
    _endHandle.hidden = NO;
  }
  [self _configureCarets];
}

- (void)setCaretColor:(UIColor *)caretColor
{
  if (caretColor != _caretColor) {
    _caretColor = caretColor;
    [self _configureCarets];
    _startCursor.backgroundColor = _caretColor.CGColor;
    _endCursor.backgroundColor = _caretColor.CGColor;
    _startHandle.fillColor = _caretColor.CGColor;
    _endHandle.fillColor = _caretColor.CGColor;
  }
}

- (void)setSelectionRects:(NSArray *)selectionRects
{
  if (selectionRects != _selectionRects) {
    _selectionRects = [selectionRects copy];
    [self layoutSelectionLayers];
    [self _configureCarets];
  }
}

- (void)setSelectionColor:(UIColor *)selectionColor
{
  if (selectionColor != _selectionColor) {
    _selectionColor = selectionColor;
    _selectionLayer.fillColor = selectionColor.CGColor;
  }
}

- (void)invalidate
{
  CKAssertMainThread();
  [CATransaction begin];
  [CATransaction setDisableActions:YES];
  [_startCursor removeFromSuperlayer];
  _startCursor = nil;
  [_startHandle removeFromSuperlayer];
  _startHandle = nil;
  [_endCursor removeFromSuperlayer];
  _endCursor = nil;
  [_endHandle removeFromSuperlayer];
  _endHandle = nil;
  [_selectionLayer removeFromSuperlayer];
  _selectionLayer = nil;
  [CATransaction commit];
  _invalidated = YES;
}

- (void)dealloc
{
  CKAssert(_invalidated, @"Must call invalidate on selection controller before deallocation");
}

@end
