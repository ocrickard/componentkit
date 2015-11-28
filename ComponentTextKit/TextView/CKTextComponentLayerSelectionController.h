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

const NSRange CKTextComponentLayerInvalidSelectionRange = { NSNotFound, 0 };

@class CKTextComponentLayer;
@class CKTextComponentLayerSelectionLayerController;

/**
 The selection controller manages the high-level selection process. It manages a layer selection controller internally
 in order to actually display the selection in the target layer. This controller doesn't know how to display anything,
 just what range is currently selected, it then maps that range into selection rects, cursor rects, etc. and hands those
 to the selection layer controller.
 */
@interface CKTextComponentLayerSelectionController : NSObject

/**
 Initializes a new selection controller with a weak reference to the given text component layer.
 */
- (instancetype)initWithTextComponentLayer:(CKTextComponentLayer *)textComponentLayer;

/**
 Provides access to the underlying layer controller for grabbing selection frames.
 */
@property (nonatomic, strong, readonly) CKTextComponentLayerSelectionLayerController *layerController;

/**
 The selected range inside the text component layer.
 */
@property (nonatomic, assign) NSRange selectedRange;

/**
 A flag for whether or not to show the "carets" on either side of the selection. The system controller doesn't show
 the carets until a candidate selection is confirmed by the user lifting up their finger on the selection.
 */
@property (nonatomic, assign) BOOL showCarets;

/**
 Lays out the selection layers in response to layer hierarchy re-layouts (think rotation).
 */
- (void)layoutSelection;

/**
 Removes all added layers and cleans up layer states. Must be called before dealloc.
 */
- (void)invalidate;

@end
