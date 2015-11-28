/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import "CKTextComponentLayerSelectionController.h"

#import "CKAssert.h"
#import "CKTextComponentLayer.h"
#import "CKTextKitRenderer.h"
#import "CKTextKitRenderer+Positioning.h"
#import "CKTextKitRenderer+TextChecking.h"
#import "CKTextComponentLayerSelectionLayerController.h"
#import "CKTextComponentLayerSelectionExclusivityController.h"

@implementation CKTextComponentLayerSelectionController
{
  BOOL _invalidated;
  CKTextComponentLayerSelectionLayerController *_layerController;
  __weak CKTextComponentLayer *_layer;
}

- (instancetype)initWithTextComponentLayer:(CKTextComponentLayer *)textComponentLayer
{
  if (self = [super init]) {
    _layer = textComponentLayer;
    // The delegate of a layer is usually its view. We do this to grab the tint color for the text component view.
    UIView *owningView = textComponentLayer.delegate;
    UIColor *caretColor = nil;
    UIColor *selectionColor = nil;
    if ([owningView isKindOfClass:[UIView class]]) {
      caretColor = owningView.tintColor;
      selectionColor = [owningView.tintColor colorWithAlphaComponent:0.3];
    } else {
      caretColor = [UIColor blueColor];
      selectionColor = [caretColor colorWithAlphaComponent:0.3];
    }
    _layerController = [[CKTextComponentLayerSelectionLayerController alloc] initWithTargetLayer:textComponentLayer
                                                                                      caretColor:caretColor
                                                                                  selectionColor:selectionColor];
    _selectedRange = CKTextComponentLayerInvalidSelectionRange;
  }
  return self;
}

- (void)setShowCarets:(BOOL)showCarets
{
  CKAssertMainThread();
  [_layerController setShowCarets:showCarets];
}

- (BOOL)showCarets
{
  return [_layerController showCarets];
}

- (void)setSelectedRange:(NSRange)selectedRange
{
  CKAssertMainThread();
  if (!NSEqualRanges(selectedRange, _selectedRange)) {
    NSRange oldSelectedRange = _selectedRange;
    _selectedRange = selectedRange;

    [self layoutSelection];

    if (!NSEqualRanges(selectedRange, CKTextComponentLayerInvalidSelectionRange)
        && NSEqualRanges(oldSelectedRange, CKTextComponentLayerInvalidSelectionRange)) {
      [[CKTextComponentLayerSelectionExclusivityController sharedExclusivityController] selectionControllerDidBeginSelection:self];
    }
  }
}

- (void)layoutSelection
{
  CKAssertMainThread();
  if (NSEqualRanges(_selectedRange, CKTextComponentLayerInvalidSelectionRange)) {
    _layerController.selectionRects = @[];
    _layerController.startCaretRect = CGRectZero;
    _layerController.endCaretRect = CGRectZero;
  } else {
    _layerController.selectionRects = [_layer.renderer rectsForTextRange:_selectedRange
                                                           measureOption:CKTextKitRendererMeasureOptionBlock];
    _layerController.startCaretRect = [_layer.renderer caretRectForTextIndex:_selectedRange.location];
    _layerController.endCaretRect = [_layer.renderer caretRectForTextIndex:NSMaxRange(_selectedRange)];
  }
}

- (void)invalidate
{
  CKAssertMainThread();
  [_layerController invalidate];
  _invalidated = YES;
}

- (void)dealloc
{
  CKAssert(_invalidated, @"You must invalidate the selection controller before dealloc.");
}

@end
