/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import "CKTextComponentView.h"
#import "CKTextComponentViewInternal.h"

#import <ComponentKit/CKAssert.h>
#import <ComponentKit/CKAsyncLayer.h>
#import <ComponentKit/CKAsyncLayerSubclass.h>
#import <ComponentKit/CKTextKitRenderer.h>
#import <ComponentKit/CKTextKitRenderer+Positioning.h>
#import <ComponentKit/CKTextKitRenderer+TextChecking.h>
#import <ComponentKit/CKTextKitRendererCache.h>
#import <ComponentKit/CKInternalHelpers.h>

#import "CKTextComponentLayer.h"
#import "CKTextComponentLayerSelectionController.h"
#import "CKTextComponentLayerSelectionLayerController.h"
#import "CKTextComponentLayerHighlightController.h"
#import "CKTextComponentLayerLoupeController.h"
#import "CKTextComponentViewControlTracker.h"
#import "CKTextComponentViewMenuController.h"

static const NSTimeInterval kDefaultSelectionPressDuration = 0.2;
static const NSTimeInterval kHighlightingSelectionPressDuration = 1.0;

@interface CKTextComponentView () <CKTextComponentViewMenuControllerDelegate>

@end

@implementation CKTextComponentView
{
  CKTextComponentViewControlTracker *_controlTracker;
  CKTextComponentViewMenuController *_menuController;
  BOOL _dismissedMenuController;
  NSUInteger _selectionStart;
  UILongPressGestureRecognizer *_panGesture;
  UITapGestureRecognizer *_tapGesture;
  NSTimer *_linkLongPressTimer;
  std::vector<CKTextComponentViewMenuItem> _menuItems;
}

+ (Class)layerClass
{
  return [CKTextComponentLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    // Set some sensible defaults for a text view
    self.contentScaleFactor = CKScreenScale();
    self.backgroundColor = [UIColor whiteColor];

    _selectionStart = NSNotFound;
  }
  return self;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
  if (![self.backgroundColor isEqual:backgroundColor]) {
    BOOL opaque = self.textLayer.opaque;
    [super setBackgroundColor:backgroundColor];

    // for reasons I don't understand, UIView is setting opaque=NO on self.layer when setting the background color.  we
    // don't want to force our rich text layers to draw with blending, so check if we can keep the opacity value after
    // setting the backgroundColor.
    if (opaque) {
      CGFloat alpha = 0.0;
      if ([backgroundColor getRed:NULL green:NULL blue:NULL alpha:&alpha] ||
          [backgroundColor getWhite:NULL alpha:&alpha] ||
          [backgroundColor getHue:NULL saturation:NULL brightness:NULL alpha:&alpha]) {
        if (alpha == 1.0) {
          self.textLayer.opaque = YES;
        }
      }
    }
  }
}

- (CKTextComponentLayer *)textLayer
{
  return (CKTextComponentLayer *)self.layer;
}

- (void)setRenderer:(CKTextKitRenderer *)renderer
{
  [self.textLayer setRenderer:renderer];
}

- (CKTextKitRenderer *)renderer
{
  return [self.textLayer renderer];
}

- (void)setSelectionEnabled:(BOOL)selectionEnabled
{
  if (_selectionEnabled != selectionEnabled) {
    _selectionEnabled = selectionEnabled;

    if (_selectionEnabled) {
      _panGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_didPan:)];
      _panGesture.minimumPressDuration = kDefaultSelectionPressDuration;
      [self addGestureRecognizer:_panGesture];

      _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_didTap:)];
      [self addGestureRecognizer:_tapGesture];
    } else {
      [self removeGestureRecognizer:_panGesture];
      _panGesture = nil;

      [self removeGestureRecognizer:_tapGesture];
      _tapGesture = nil;
    }
  }
}

- (void)setMenuItems:(const std::vector<CKTextComponentViewMenuItem> &)menuItems
{
  _menuItems = menuItems;
  if ([_menuController isMenuControllerVisible]) {
    [_menuController dismissMenuController];
    _menuController = nil;
  }
}

#pragma mark - Control Tracking

- (CKTextComponentViewControlTracker *)controlTracker
{
  if (!_controlTracker) {
    // Lazily generate a control tracker to receive UIControl touch input.
    _controlTracker = [[CKTextComponentViewControlTracker alloc] init];
  }
  return _controlTracker;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
  if (![super beginTrackingWithTouch:touch withEvent:event]) {
    return NO;
  }
  if (_selectionEnabled && !NSEqualRanges(self.textLayer.selectionController.selectedRange, CKTextComponentLayerInvalidSelectionRange)) {
    // We shouldn't begin UIControl tracking when we have an active selection.
    return NO;
  }
  BOOL response = [self.controlTracker beginTrackingForTextComponentView:self withTouch:touch withEvent:event];
  NSTextCheckingResult *currentResult = self.controlTracker.trackingTextCheckingResult;
  if (_selectionEnabled && currentResult) {
    __weak __typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kHighlightingSelectionPressDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      __typeof(weakSelf) strongSelf = weakSelf;
      if (strongSelf.controlTracker.trackingTextCheckingResult == currentResult) {
        strongSelf.textLayer.highlightController.highlightedRange = CKTextComponentLayerInvalidHighlightRange;
        // TODO: This should probably be updated to display the loupe. For now we can just deactivate the control
        // action.
        [strongSelf cancelTrackingWithEvent:event];
        strongSelf.textLayer.selectionController.selectedRange = currentResult.range;
        strongSelf.textLayer.selectionController.showCarets = YES;
        [strongSelf _presentMenuController];
      }
    });
  }
  return response;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
  if (![super continueTrackingWithTouch:touch withEvent:event]) {
    return NO;
  }
  return [self.controlTracker continueTrackingForTextComponentView:self withTouch:touch withEvent:event];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
  [self.controlTracker cancelTrackingForTextComponentView:self withEvent:event];
  [super cancelTrackingWithEvent:event];
  _panGesture.minimumPressDuration = kDefaultSelectionPressDuration;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
  [self.controlTracker endTrackingForTextComponentView:self withTouch:touch withEvent:event];
  [super endTrackingWithTouch:touch withEvent:event];
  _panGesture.minimumPressDuration = kDefaultSelectionPressDuration;
}

#pragma mark - Touch Interaction

static const CGFloat kTouchCloseToCaretThreshold = 30;

static NSUInteger closestIntersectingPosition(CGPoint point, NSUInteger firstCandidate, NSUInteger secondCandidate, CKTextComponentView *textView)
{
  //TODO fix these.
  CGRect firstCaretRect =  [textView.renderer caretRectForTextIndex:firstCandidate];
  CGRect firstExpandedCaretRect = CGRectInset(firstCaretRect, -kTouchCloseToCaretThreshold, -kTouchCloseToCaretThreshold);
  BOOL pointCloseToFirst = CGRectContainsPoint(firstExpandedCaretRect, point);

  CGRect secondCaretRect = [textView.renderer caretRectForTextIndex:secondCandidate];
  CGRect secondExpandedCaretRect = CGRectInset(secondCaretRect, -kTouchCloseToCaretThreshold, -kTouchCloseToCaretThreshold);
  BOOL pointCloseToSecond = CGRectContainsPoint(secondExpandedCaretRect, point);

  if (pointCloseToFirst && !pointCloseToSecond) {
    return firstCandidate;
  } else if (pointCloseToSecond && !pointCloseToFirst) {
    return secondCandidate;
  } else if (pointCloseToFirst && pointCloseToSecond) {
    CGFloat firstDistance = hypot(point.x - CGRectGetMidX(firstCaretRect), point.y - CGRectGetMidY(firstCaretRect));
    CGFloat secondDistance = hypot(point.x - CGRectGetMidX(secondCaretRect), point.y - CGRectGetMidY(secondCaretRect));

    if (firstDistance < secondDistance) {
      return firstCandidate;
    } else {
      return secondCandidate;
    }
  } else {
    return NSNotFound;
  }
}

- (void)_didTap:(UIGestureRecognizer *)gestureRecognizer
{
  CGPoint point = [gestureRecognizer locationInView:self];
  if (!_dismissedMenuController && ![_menuController isMenuControllerVisible]) {
    for (NSValue *rectValue in self.textLayer.selectionController.layerController.selectionRects) {
      if (CGRectContainsPoint(rectValue.CGRectValue, point)) {
        [self _presentMenuControllerAfterDelay];
        return;
      }
    }
  }

  // We have tapped, but not on any existing selections, and not on a control action. We de-select any active selections
  self.textLayer.selectionController.selectedRange = CKTextComponentLayerInvalidSelectionRange;
}

- (void)_updateLoupeForTouchAtPoint:(CGPoint)point
{
  if (![self.textLayer.loupeController isLoupeVisible]) {
    [self.textLayer.loupeController presentLoupe];
  }
  self.textLayer.loupeController.pointOfInterest = point;
}

- (void)_dismissLoupe
{
  [self.textLayer.loupeController dismissLoupe];
}

- (void)_presentMenuControllerAfterDelay
{
  if (!_dismissedMenuController && ![_menuController isMenuControllerVisible] && ![self.textLayer.loupeController isLoupeVisible]) {
    NSRange selectedRange = self.textLayer.selectionController.selectedRange;
    if (selectedRange.length > 0) {
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (NSEqualRanges(self.textLayer.selectionController.selectedRange, selectedRange)) {
          // We delay actual presentation a little bit to confirm the user isn't rapidly changing the selected range.
          [self _presentMenuController];
        }
      });
    }
  }
}

- (void)_presentMenuController
{
  if ([_menuController isMenuControllerVisible]) {
    return;
  }

  if (_menuController) {
    [_menuController dismissMenuController];
    _menuController = nil;
  }

  _menuController = [[CKTextComponentViewMenuController alloc] initWithTextView:self
                                                           systemMenuController:[UIMenuController sharedMenuController]
                                                                      menuItems:_menuItems];
  _menuController.delegate = self;
  [_menuController presentMenuController];
  if (![_menuController isMenuControllerVisible]) {
    // We failed, clean up after ourselves.
    _menuController = nil;
  }
}

- (void)_didPan:(UIGestureRecognizer *)gestureRecognizer
{
  CGPoint point = [gestureRecognizer locationInView:self];
  NSUInteger position = [self.textLayer.renderer nearestTextIndexAtPosition:point];
  NSRange selectedRange = self.textLayer.selectionController.selectedRange;

  if (gestureRecognizer.state == UIGestureRecognizerStateBegan
      && self.textLayer.selectionController.selectedRange.length > 0) {
    NSUInteger closest = closestIntersectingPosition(point, selectedRange.location, NSMaxRange(selectedRange), self);
    // Begin the selection with the opposite side of the current selection, since they're close to that touch point.
    if (closest == selectedRange.location) {
      _selectionStart = NSMaxRange(selectedRange);
    } else if (closest == NSMaxRange(selectedRange)) {
      _selectionStart = selectedRange.location;
    }
  }

  if (gestureRecognizer.state == UIGestureRecognizerStateBegan
      || gestureRecognizer.state == UIGestureRecognizerStateChanged) {
    if (_selectionStart != NSNotFound && position != NSNotFound) {
      self.textLayer.selectionController.showCarets = YES;
      if (gestureRecognizer.state == UIGestureRecognizerStateBegan
          || gestureRecognizer.state == UIGestureRecognizerStateChanged
          || gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        NSUInteger min = MIN(_selectionStart, position);
        NSUInteger max = MAX(_selectionStart, position);
        self.textLayer.selectionController.selectedRange = NSMakeRange(min, max - min);
      }
    } else {
      self.textLayer.selectionController.showCarets = NO;

      NSAttributedString *attributedString = self.renderer.attributes.attributedString;
      NSString *string = attributedString.string;
      __block NSRange wordRange = CKTextComponentLayerInvalidSelectionRange;
      // First we search for a link that the user is selecting.
      [attributedString enumerateAttribute:CKTextKitEntityAttributeName inRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if (value && NSLocationInRange(position, range)) {
          wordRange = range;
          *stop = YES;
        }
      }];
      if (NSEqualRanges(wordRange, CKTextComponentLayerInvalidSelectionRange)) {
        // If we failed ot highlight a link, we next look for word tokens that match the touch point.
        [string enumerateSubstringsInRange:NSMakeRange(0, string.length) options:NSStringEnumerationByWords|NSStringEnumerationSubstringNotRequired usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
          if (NSLocationInRange(position, substringRange)) {
            wordRange = substringRange;
            *stop = YES;
          }
        }];
      }
      self.textLayer.selectionController.selectedRange = wordRange;
    }

    [self _updateLoupeForTouchAtPoint:point];
  } else if (gestureRecognizer.state == UIGestureRecognizerStateCancelled
             || gestureRecognizer.state == UIGestureRecognizerStateEnded) {
    self.textLayer.selectionController.showCarets = YES;
    _selectionStart = NSNotFound;
    [self _dismissLoupe];

    if (self.textLayer.selectionController.selectedRange.length > 0) {
      [self _presentMenuController];
    }
  }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)recognizer
{
  // We want the same behavior as UIButton: "...a UIButton, by default, does return NO for a single tap
  // UITapGestureRecognizer whose view is not the UIButton itself."
  // http://www.apeth.com/iOSBook/ch18.html#_gesture_recognizers
  if ([recognizer isKindOfClass:[UITapGestureRecognizer class]]) {
    UITapGestureRecognizer *tapRecognizer = (UITapGestureRecognizer *)recognizer;
    if (tapRecognizer.numberOfTapsRequired == 1 && tapRecognizer.view != self) {
      return NO;
    }
  }
  if (recognizer == _panGesture || recognizer == _tapGesture) {
    if (self.controlTracker.trackingTextCheckingResult) {
      // If the control tracker is active, then we need to let it do its UIControl magic.
      return NO;
    }
  }
  return [super gestureRecognizerShouldBegin:recognizer];
}

#pragma mark - CKTextComponentViewMenuControllerDelegate

- (CGRect)targetRectForMenuController:(CKTextComponentViewMenuController *)menuController
{
  if (!NSEqualRanges(self.textLayer.selectionController.selectedRange, CKTextComponentLayerInvalidSelectionRange)) {
    CGRect rect = CGRectNull;
    NSArray *rects = self.textLayer.selectionController.layerController.selectionRects;
    for (NSValue *selectionRect in rects) {
      rect = CGRectUnion(rect, [selectionRect CGRectValue]);
    }
    return rect;
  }
  return CGRectNull;
}

- (void)menuControllerDidDismiss:(CKTextComponentViewMenuController *)menuController {}

- (void)menuControllerDidPresent:(CKTextComponentViewMenuController *)menuController {}

@end
