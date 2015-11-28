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

#import "CKTextComponentViewMenuItem.h"

@class CKTextComponentViewMenuController;
@class CKTextComponentView;

@protocol CKTextComponentViewMenuControllerDelegate <NSObject>

/**
 Rect in the coordinate space of the textView that the system menu controller should target.
 
 If CGRectNull is returned, the menu controller will not be displayed.
 */
- (CGRect)targetRectForMenuController:(CKTextComponentViewMenuController *)menuController;

/**
 Informs the delegate that the menu controller successfully displayed.
 */
- (void)menuControllerDidPresent:(CKTextComponentViewMenuController *)menuController;

/**
 Informs the delegate that the menu controller dismissed.
 */
- (void)menuControllerDidDismiss:(CKTextComponentViewMenuController *)menuController;

@end

/**
 The text component view menu controller encapsulates all of the logic and crazy selector handling necessary to work
 with the default system menu controller. It provides a simpler block-based syntax for creating menu items in your
 components.
 
 You should not have to directly interact with this menu controller, but it marshalls all of the menu items that are
 submitted to the text component.
 */
@interface CKTextComponentViewMenuController : UIResponder

/**
 Initializes the menu controller with a given text view and system menu controller. The text view is held weakly so
 as not to form any retain cycles.
 */
- (instancetype)initWithTextView:(CKTextComponentView *)textView
            systemMenuController:(UIMenuController *)menuController
                       menuItems:(const std::vector<CKTextComponentViewMenuItem> &)menuItems;

/**
 The delegate of the menu controller is informed when presentation and dismissal actually occurs. Dismissal of the menu
 may occur for any reason (imagine the user taps on the screen, not on the menu controller, it will dismiss
 automatically, and then you will be notified).
 */
@property (nonatomic, weak) id<CKTextComponentViewMenuControllerDelegate> delegate;

/**
 Configures and displays the system menu controller with the menu items that were configured on initialization.
 
 This method *can* fail to present the menu controller in cases where the current first responder refuses to resign. If
 you absolutely depend on the menu controller being visible, then you should check the value of isMenuControllerVisible.
 */
- (void)presentMenuController;

/**
 Dismisses the menu controller and resigns first responder. This method must be called before dealloc if the menu is
 active.
 */
- (void)dismissMenuController;

/**
 Flag indicating if the system menu controller is currently visible. This flag only applies to *this* menu controller,
 if a different CKTextComponentViewMenuController is actively displaying the menu controller this method will return NO.
 */
- (BOOL)isMenuControllerVisible;

@end
