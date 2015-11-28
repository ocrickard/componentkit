/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <UIKit/UIKit.h>

@interface CKTextComponentLayerLoupeLayer : CALayer

- (instancetype)initWithTargetLayer:(CALayer *)targetLayer;

/**
 The view which should be displayed in the loupe view. This view will be repeatedly snapshotted, zoomed in, and then
 displayed within the loupe.
 */
@property (nonatomic, weak, readonly) CALayer *targetLayer;

/**
 The location in the `targetView` on which the loupe should focus.
 */
@property (nonatomic, assign) CGPoint pointOfInterest;

@end
