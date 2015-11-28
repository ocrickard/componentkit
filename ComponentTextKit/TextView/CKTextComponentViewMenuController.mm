/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import "CKTextComponentViewMenuController.h"

#import "CKTextComponentView.h"
#import "CKTextComponentViewMenuItem.h"

@implementation CKTextComponentViewMenuController
{
  __weak CKTextComponentView *_textView;
  __weak UIMenuController *_systemMenuController;
  std::vector<CKTextComponentViewMenuItem> _menuItems;

  BOOL _isDisplayingMenuController;

  NSIndexPath *_menuItemIndexPath;
}

- (instancetype)initWithTextView:(CKTextComponentView *)textView
            systemMenuController:(UIMenuController *)menuController
                       menuItems:(const std::vector<CKTextComponentViewMenuItem> &)menuItems
{
  if (self = [super init]) {
    _textView = textView;
    _systemMenuController = menuController;
    _menuItems = menuItems;
  }
  return self;
}

- (BOOL)canBecomeFirstResponder
{
  return YES;
}

static NSString *const kGeneratedSelectorNamePrefix = @"__CKTextComponentViewMenuItem_";

static BOOL isActionGenerated(SEL action)
{
  NSString *string = NSStringFromSelector(action);
  return [string hasPrefix:kGeneratedSelectorNamePrefix];
}

static NSInteger actionIndex(SEL action)
{
  NSString *selectorName = NSStringFromSelector(action);
  return [[selectorName substringFromIndex:kGeneratedSelectorNamePrefix.length] integerValue];
}

static SEL actionSelectorForIndex(NSUInteger index)
{
  NSString *selectorName = [NSString stringWithFormat:@"%@%lu", kGeneratedSelectorNamePrefix, (unsigned long)index];
  return NSSelectorFromString(selectorName);
}

static CKTextComponentViewMenuItem menuItemFromIndexPath(const std::vector<CKTextComponentViewMenuItem> &root, NSIndexPath *indexPath, CKTextComponentView *textView)
{
  std::vector<CKTextComponentViewMenuItem> current = root;
  CKTextComponentViewMenuItem menuItem = {};
  for (int i = 0; i < indexPath.length; i++) {
    NSUInteger curIndex = [indexPath indexAtPosition:i];
    if (curIndex >= current.size()) {
      NSCAssert(NO, @"Invalid index path encountered:%@", indexPath);
      return {};
    }
    menuItem = current[curIndex];
    current = menuItem.subMenuItemsGenerator ? menuItem.subMenuItemsGenerator(textView) : std::vector<CKTextComponentViewMenuItem>();
  }
  return menuItem;
}

- (void)_performAction:(NSInteger)index
{
  CKTextComponentViewMenuItem menuItem;
  if (_menuItemIndexPath) {
    menuItem = menuItemFromIndexPath(_menuItems, [_menuItemIndexPath indexPathByAddingIndex:index], _textView);
  } else if (index >= 0 && index < _menuItems.size()) {
    menuItem = _menuItems[index];
  } else {
    menuItem = {};
  }
  menuItem.activationBlock(_textView);
  std::vector<CKTextComponentViewMenuItem> subMenuItems = menuItem.subMenuItemsGenerator ? menuItem.subMenuItemsGenerator(_textView) : std::vector<CKTextComponentViewMenuItem>();
  if (subMenuItems.size() > 0) {
    if (!_menuItemIndexPath) {
      _menuItemIndexPath = [NSIndexPath indexPathWithIndex:index];
    } else {
      _menuItemIndexPath = [_menuItemIndexPath indexPathByAddingIndex:index];
    }
    NSMutableArray *menuControllerItems = [NSMutableArray array];
    NSUInteger subIndex = 0;
    for (const auto &subMenuItem : subMenuItems) {
      UIMenuItem *menuControllerItem = [[UIMenuItem alloc] initWithTitle:subMenuItem.title action:actionSelectorForIndex(subIndex)];
      [menuControllerItems addObject:menuControllerItem];
      subIndex++;
    }
    _systemMenuController.menuItems = menuControllerItems;
    [_systemMenuController setMenuVisible:YES];
  } else {
    _menuItemIndexPath = nil;
  }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
  if (isActionGenerated(action)) {
    NSInteger subIndex = actionIndex(action);
    NSIndexPath *path = _menuItemIndexPath ? [_menuItemIndexPath indexPathByAddingIndex:subIndex] : [NSIndexPath indexPathWithIndex:subIndex];

    CKTextComponentViewMenuItem subItem = menuItemFromIndexPath(_menuItems, path, _textView);
    if (subItem.canPerformBlock) {
      return subItem.canPerformBlock(_textView);
    }
  }
  return NO;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
  return [super methodSignatureForSelector:sel] ?: isActionGenerated(sel) ? [super methodSignatureForSelector:@selector(_performAction:)] : nil;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
  if (isActionGenerated([invocation selector])) {
    [self _performAction:actionIndex([invocation selector])];
  } else {
    [super forwardInvocation:invocation];
  }
}

- (void)presentMenuController
{
  if (![self becomeFirstResponder]) {
    // We failed to become first responder, which means something is blocking us. We can't display the menu.
    return;
  }

  if (_isDisplayingMenuController) {
    // We're already displaying the menu controller. Stop us from corrupting state.
    return;
  }

  NSMutableArray *menuControllerItems = [NSMutableArray array];
  NSUInteger index = 0;
  for (const auto &menuItem : _menuItems) {
    UIMenuItem *menuControllerItem = [[UIMenuItem alloc] initWithTitle:menuItem.title action:actionSelectorForIndex(index)];
    [menuControllerItems addObject:menuControllerItem];
    index++;
  }
  _systemMenuController.menuItems = menuControllerItems;
  CGRect targetRect = [_delegate targetRectForMenuController:self];
  if (CGRectIsNull(targetRect)) {
    // Uh oh, we got a null rect, the menu controller will crash if it gets this, so we have to bail.
    [self resignFirstResponder];
    return;
  }

  [_systemMenuController setTargetRect:targetRect
                                inView:_textView];

  [_systemMenuController setMenuVisible:YES
                               animated:YES];
  _isDisplayingMenuController = [_systemMenuController isMenuVisible];
  if (_isDisplayingMenuController) {
    [self.delegate menuControllerDidPresent:self];
  } else {
    [self resignFirstResponder];
    return;
  }

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(_menuControllerDidDismiss:)
                                               name:UIMenuControllerDidHideMenuNotification
                                             object:nil];
}

- (void)dismissMenuController
{
  if (!_isDisplayingMenuController) {
    return;
  }
  _systemMenuController.menuItems = nil;
  [_systemMenuController setMenuVisible:NO
                               animated:YES];
  if (self.isFirstResponder) {
    [self resignFirstResponder];
  }
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIMenuControllerDidHideMenuNotification
                                                object:nil];
}

- (BOOL)isMenuControllerVisible
{
  return _isDisplayingMenuController && _systemMenuController.isMenuVisible;
}

- (void)_menuControllerDidDismiss:(NSNotification *)notification
{
  if (_isDisplayingMenuController) {
    _menuItemIndexPath = nil;
    _isDisplayingMenuController = NO;
    [self.delegate menuControllerDidDismiss:self];
    if ([self isFirstResponder]) {
      [self resignFirstResponder];
    }
  }
}

- (UIResponder *)nextResponder
{
  // In order to be come first responder, we have to be part of a responder chain, so we have to respond with a view
  // that is present in a UIWindow or becomeFirstResponder will refuse to activate.
  return _textView;
}

@end
