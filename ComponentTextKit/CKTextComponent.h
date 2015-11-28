/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <ComponentKit/CKComponent.h>

#import <ComponentKit/CKTextKitAttributes.h>
#import <ComponentKit/CKTextComponentViewMenuItem.h>

#import <vector>

struct CKTextComponentAccessibilityContext
{
  NSNumber *isAccessibilityElement;
  NSString *accessibilityIdentifier;
  NSNumber *providesAccessibleElements;
  /**
   Should rarely be used, the component's text will be used by default.
   */
  CKComponentAccessibilityTextAttribute accessibilityLabel;
};

struct CKTextComponentSelectionAttributes
{
  BOOL selectionEnabled;
  std::vector<CKTextComponentViewMenuItem> menuItems;
};

/**
 CKTextComponent is the fully-featured text component for styled text in ComponentKit. It is able to handle embedded
 links, varying styles (underlines, bold, colors), and text selection.
 */
@interface CKTextComponent : CKComponent

+ (instancetype)newWithTextAttributes:(const CKTextKitAttributes &)attributes
                  selectionAttributes:(const CKTextComponentSelectionAttributes &)selectionAttributes
                       viewAttributes:(const CKViewComponentAttributeValueMap &)viewAttributes
                 accessibilityContext:(const CKTextComponentAccessibilityContext &)accessibilityContext;

@end
