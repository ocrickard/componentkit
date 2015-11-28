/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import "CKTextComponentLayerSelectionExclusivityController.h"

#import "CKTextComponentLayerSelectionController.h"

@implementation CKTextComponentLayerSelectionExclusivityController
{
  __weak CKTextComponentLayerSelectionController *_selectionController;
}

+ (instancetype)sharedExclusivityController
{
  static CKTextComponentLayerSelectionExclusivityController *sharedController;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedController = [[self alloc] init];
  });
  return sharedController;
}

- (void)selectionControllerDidBeginSelection:(CKTextComponentLayerSelectionController *)selectionController
{
  if (selectionController != _selectionController) {
    _selectionController.selectedRange = CKTextComponentLayerInvalidSelectionRange;
    _selectionController = selectionController;
  }
}

@end
