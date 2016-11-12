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

#import <ComponentKit/CKComponentLayout.h>
#import <ComponentKit/CKLabelComponent.h>
#import <ComponentKit/CKStackLayoutComponent.h>
#import <ComponentKit/CKComponentSubclass.h>
#import <ComponentKit/CKComponentInternal.h>
#import <ComponentKit/CKComponentScope.h>

/**
 A typed props component allows formalization of the props of a component in a value-type object. It is similar in
 concept to CKCompositeComponent, in that it renders to a child component.
 
 @discussion
 Covariant components have a stricter API internally that allows for framework-level memoization of the components and
 component layouts. This makes them a good choice for "pure" components that are only dependent on the input state, and
 should provide a substantial performance improvement.
 
 The PropType must properly implement -hash and -isEqual: in order for memoization to work.
 
 Example usage:
 
       @interface MyComponent : CKTypedPropsComponent<NSString *, id>
       @end
       
       @implementation MyComponent
       + (CKComponent *)renderWithProps:(NSString *)props
                                  state:(id)state
                                   view:(const CKComponentViewConfiguration &)view
                                   size:(const CKComponentSize &)size
       {
         return [CKLabelComponent
                 newWithLabelAttributes:{
                  .string = props
                 }
                 viewAttributes:{}
                 size:{}];
       }
       @end

 Then to create a MyComponent:
 
       MyComponent *c = [MyComponent
                         newWithProps:@"hello" 
                         view:{} 
                         size{}];

 All CKTypedPropsComponent subclasses share this constructor, +newWithProps:view:size:.
 
 The framework may return a memoized version of the CKTypedPropsComponent if the input state matches a previous
 computation.
 
 @warning Overriding -newWithProps:view:size:, -newWithView:size:
          is **not allowed** for any subclass.
 */
@interface CKTypedPropsComponent<__covariant PropType:id<NSObject, NSCopying>, __covariant StateType:id> : CKComponent

+ (instancetype)newWithProps:(PropType)props
                        view:(const CKComponentViewConfiguration &)view
                        size:(const CKComponentSize &)size;

@end
