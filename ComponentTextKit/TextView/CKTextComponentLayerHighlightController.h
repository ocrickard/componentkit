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

const NSRange CKTextComponentLayerInvalidHighlightRange = { NSNotFound, 0 };

@class CKTextComponentLayer;

/**
 An object responsible for the display of "highlights" on the text layer. Highlights are the dark-gray overlay that is
 temporarily present when the user taps on a link inside a text component view.
 */
@interface CKTextComponentLayerHighlightController : NSObject

- (instancetype)initWithTextComponentLayer:(CKTextComponentLayer *)textComponentLayer;

/**
 
 */
@property (nonatomic, assign) NSRange highlightedRange;

/**
 Re-lays out the highlight layer(s) in response to a layer layout pass.
 */
- (void)layoutHighlight;

/**
 Removes all layers. The highlight controller may not be reused after calling this method. This method *must* be called
 before dealloc.
 */
- (void)invalidate;

@end
