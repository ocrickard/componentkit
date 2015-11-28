/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <ComponentKit/CKAsyncLayer.h>

@class CKTextComponentLayerHighlightController;
@class CKTextComponentLayerSelectionController;
@class CKTextComponentLayerLoupeController;
@class CKTextKitRenderer;

/**
 An implementation detail of the CKTextComponentView.  You should rarely, if ever have to deal directly with this class.
 */
@interface CKTextComponentLayer : CKAsyncLayer

/**
 The immutable renderer object is set on the layer, and triggers a re-display. This layer is configured for rapid reuse
 in table or collection views, so this method is very fast.
 */
@property (nonatomic, strong) CKTextKitRenderer *renderer;

/**
 Responsible for all highlight actions (the overlay applied when users press on links). You may retrieve the highlighted
 range from this controller.
 */
@property (nonatomic, strong, readonly) CKTextComponentLayerHighlightController *highlightController;

/**
 Responsible for all selection actions (for when the user has long-pressed and actually selected a certain segment of
 text). You may retrieve the selected range from this controller.
 */
@property (nonatomic, strong, readonly) CKTextComponentLayerSelectionController *selectionController;

/**
 Provides access to the loupe controller
 */
@property (nonatomic, strong, readonly) CKTextComponentLayerLoupeController *loupeController;

@end
