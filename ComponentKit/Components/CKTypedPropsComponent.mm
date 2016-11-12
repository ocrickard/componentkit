/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import "CKTypedPropsComponent.h"

#import <ComponentKit/CKComponentMemoizer.h>
#import <ComponentKit/CKTypedPropsComponentSubclass.h>
#import <ComponentKit/CKComponentContextHelper.h>

#import "CKInternalHelpers.h"

@implementation CKTypedPropsComponent
{
  CKComponent *_child;
}

#if DEBUG
+ (void)initialize
{
  if (self != [CKCompositeComponent class]) {
    CKAssert(!CKSubclassOverridesSelector([CKTypedPropsComponent class], self, @selector(newWithView:size:)),
             @"%@ overrides -newWithView:size: which is not allowed. "
             "Consider subclassing CKComponent or CKCompositeComponent directly.",
             self);
    CKAssert(!CKSubclassOverridesSelector([CKTypedPropsComponent class], self, @selector(newWithProps:view:size:)),
             @"%@ overrides -newWithProps:view:size: which is not allowed. "
             "Instead, you should implement renderWithProps:state:view:size:.",
             self);
  }
}
#endif

+ (instancetype)newWithProps:(id<NSObject, NSCopying>)props
                        view:(const CKComponentViewConfiguration &)view
                        size:(const CKComponentSize &)size
{
  CKComponentScope scope(self);

  CKTypedPropsComponent *c = [super newWithView:view
                                          size:size];
  if (c) {
    id state = scope.state();
    c->_props = props;
    c->_state = state;

    // The component context is a thread-local stack that can be used within components to thread contents to child
    // components without explicitly passing through. Every memoization key must include the component context state.
    CKComponentContextContents contents = CKComponentContextHelper::fetchAll();
    c->_child = CKMemoize(CKMakeTupleMemoizationKey(props,
                                                    state,
                                                    view,
                                                    size,
                                                    contents.objects,
                                                    contents.dynamicLookup),
                          ^{
                            return [self renderWithProps:props
                                                   state:state
                                                    view:view
                                                    size:size];
                          });
  }
  return c;
}

+ (CKComponent *)renderWithProps:(id<NSObject, NSCopying>)props
                           state:(id)state
                            view:(const CKComponentViewConfiguration &)view
                            size:(const CKComponentSize &)size
{
  return nil;
}

- (CKComponentLayout)computeLayoutThatFits:(CKSizeRange)constrainedSize
                          restrictedToSize:(const CKComponentSize &)size
                      relativeToParentSize:(CGSize)parentSize
{
  CKComponentLayout l = CKMemoizeLayout(_child, constrainedSize, size, parentSize, ^CKComponentLayout{
    return [_child layoutThatFits:constrainedSize parentSize:parentSize];
  });
  return {self, l.size, {{{0,0}, l}}};
}

- (UIView *)viewForAnimation
{
  // Delegate to the wrapped component's viewForAnimation if we don't have one.
  return [super viewForAnimation] ?: [_child viewForAnimation];
}

@end
