/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <QuartzCore/QuartzCore.h>

#import <UIKit/UIKit.h>

/**
 The selection layer controller manages the selection layers and carets that the user interacts with. This object is
 built to be created once for each selection operation, mutated as the user changes selection, then invalidated and
 deallocated after the selection terminates.
 */
@interface CKTextComponentLayerSelectionLayerController : NSObject

/**
 Initialize a selection controller that manages the placement and appearance of selection layers in an efficient
 manner.
 
 @param layer the layer in which the selection should appear.
 @param caretColor the color of the carets on either side of the selection body.
 @param selectionColor the color of the (potentially transparent) text selection overlay.
 */
- (instancetype)initWithTargetLayer:(CALayer *)layer
                         caretColor:(UIColor *)caretColor
                     selectionColor:(UIColor *)selectionColor;

/**
 Re-layout the selection layers in response to a layout event on the target view.
 */
- (void)layoutSelectionLayers;

/**
 Flag to enable carets on the selection. When this value changes, the carets will animate in or out depending on the
 value.
 
 The default system selection system does not show carets until a selection is activated. It will show candidate
 selections on various tokens during the down state of a long press, then confirm the selection by showing the carets
 and menu controller for the selected content.
 */
@property (nonatomic, assign) BOOL showCarets;

/**
 The starting caret rect. May be on the left, or right depending on writing direction for the first line.
 */
@property (nonatomic, assign) CGRect startCaretRect;

/**
 The ending caret rect. May be on left, or right depending on writing direction for the last line.
 */
@property (nonatomic, assign) CGRect endCaretRect;

/**
 An array of rects representing the selected region.
 */
@property (nonatomic, copy) NSArray *selectionRects;

/**
 The color of the (potentially transparent) text selection overlay.
 */
@property (nonatomic, strong, readonly) UIColor *selectionColor;

/**
 The color of the carets on either side of the selection body.
 */
@property (nonatomic, strong, readonly) UIColor *caretColor;

/**
 Should be called before dealloc to hide all selections. Once this is called the controller cannot be reused. A new
 controller should be initialized.
 */
- (void)invalidate;

@end
