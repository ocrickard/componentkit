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

#import <ComponentKit/CKComponentBoundsAnimation.h>
#import <ComponentKit/CKComponentScopeRoot.h>

class CKComponentLayout;

@interface CKTransactionalComponentDataSourceItem : NSObject

- (const CKComponentLayout &)layout;

/** The scope root for this item, which holds references to component controllers and state */
- (std::shared_ptr<CKComponentScopeRoot>)scopeRoot;

/** The model used to compute the layout */
@property (nonatomic, strong, readonly) id model;

/** The bounds animation with which to apply the layout */
@property (nonatomic, readonly) CKComponentBoundsAnimation boundsAnimation;

@end
