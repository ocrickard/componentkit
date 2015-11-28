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

#import <vector>

@class CKTextComponentView;

/**
 A menu item is a simple wrapper representing one element in the system menu controller that appears when text is
 selected.
 
 Each menu item may have sub menu items that replace all other menu items in the system menu when activated. You can
 see this in the system menus when you select the text style menu item, it then changes the menu to display "Bold,
 Italic, Underline, etc."
 */
struct CKTextComponentViewMenuItem {
  /**
   The string that will be presented to the user in the menu item. Must not be nil.
   */
  NSString *title;
  /**
   A block that determines if this menu item can perform its action. If you return NO, then your menu item will not be
   displayed. Must not be NULL.
   
   For example, if you have a "Synonym" menu item, you could look up the selected range from the 
   `textView.textLayer.selectionController`, and determine if you have any synonyms for the selected text in a local
   dictionary. If you return YES then the Synonym menu item would be added to the list of presented menu items. If you
   return NO, then it would not be presented at all.
   */
  BOOL (^canPerformBlock)(CKTextComponentView *textView);
  /**
   A block that is called when this menu item is activated. May be NULL.
   */
  void (^activationBlock)(CKTextComponentView *textView);
  /**
   Upon activation of your menu item, not only will the above activationBlock be called, but you are given the chance
   to generate sub menu items.
   
   For example, if you had a "Synonym" menu item, upon activation you should return a vector of child menu items
   representing each one of the synonym terms you would like to display in the menu.
   */
  std::vector<CKTextComponentViewMenuItem> (^subMenuItemsGenerator)(CKTextComponentView *textView);
};
