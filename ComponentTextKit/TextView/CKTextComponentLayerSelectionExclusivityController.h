/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <Foundation/Foundation.h>

@class CKTextComponentLayerSelectionController;

/**
 The system selection controller only allows a single text view to be actively selected at any given time. This
 singleton serves the same purpose: when one text layer begins selection it informs this object, and it de-selects
 any previously selected text layers.
 */
@interface CKTextComponentLayerSelectionExclusivityController : NSObject

+ (instancetype)sharedExclusivityController;

- (void)selectionControllerDidBeginSelection:(CKTextComponentLayerSelectionController *)selectionController;

@end
