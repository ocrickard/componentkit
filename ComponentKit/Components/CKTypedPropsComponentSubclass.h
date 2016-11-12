/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <ComponentKit/CKTypedPropsComponent.h>

@interface CKTypedPropsComponent<__covariant PropType:id<NSObject, NSCopying>, __covariant StateType:id> ()

/**
 The primary render method for the component.
 */
+ (CKComponent *)renderWithProps:(PropType)props
                           state:(StateType)state
                            view:(const CKComponentViewConfiguration &)view
                            size:(const CKComponentSize &)size;

@property (nonatomic, strong, readonly) PropType props;
@property (nonatomic, strong, readonly) StateType state;

@end
