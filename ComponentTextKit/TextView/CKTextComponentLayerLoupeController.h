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

#import <UIKit/UIKit.h>

/**
 A loupe controller is responsible for displaying a loupe in a given target view. It displays this loupe in a separate
 window on top of the normal window hierarchy.
 
 In order to maintain a constantly-updated view of the targetView, this controller uses a CADisplayLink to re-render
 the contents on every frame. This is quite expensive and will churn CPU and battery substantially while active. Make
 sure to dismiss the loupe when you are done with it in order to minimize this cost.
 */
@interface CKTextComponentLayerLoupeController : NSObject

/**
 A loupe controller is initialized with a specific target view. This is the view of interest to the loupe.
 
 The loupe will duplicate the contents of not *just* this view. It will render the targetView's window contents.
 
 You must call `presentLoupe` before this controller will display its loupe on screen.
 */
- (instancetype)initWithTargetLayer:(CALayer *)targetLayer;

/**
 The point within the `targetView` to focus on. This parameter is designed for rapid updates, so you can set this
 frequently in response to user interaction.
 
 This *should* be set before calling presentLoupe, the default value is {0,0}.
 */
@property (nonatomic, assign) CGPoint pointOfInterest;

/**
 Displays the loupe on the user's screen given the `targetView` AND `pointOfInterest`. This method will cause the loupe
 to animate into view.
 */
- (void)presentLoupe;

/**
 Dismisses the loupe with an animated zoom-out effect. You should call this before releasing ownership of this object.
 */
- (void)dismissLoupe;

/**
 This method will invalidate the loupe controller, removing all windows, layers etc. This must be called before dealloc.
 */
- (void)invalidate;

/**
 Returns if the loups is currently visible on screen.
 */
- (BOOL)isLoupeVisible;

@end
