/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <stack>

#import <Foundation/Foundation.h>

#import <ComponentKit/CKAssert.h>
#import <ComponentKit/CKComponentScopeFrame.h>
#import <ComponentKit/CKComponentScopeRoot.h>

@class CKComponent;
@class CKComponentController;

template<typename ComponentType, typename ComponentControllerType>
class CKTypedThreadLocalComponentScope {
public:
  CKTypedThreadLocalComponentScope(std::shared_ptr<CKTypedComponentScopeRoot<ComponentType, ComponentControllerType>> previousScopeRoot,
                                   const CKComponentStateUpdateMap &updates);
  ~CKTypedThreadLocalComponentScope();
  
  /** Returns nullptr if there isn't a current scope */
  static CKTypedThreadLocalComponentScope *currentScope() noexcept;

  std::shared_ptr<CKTypedComponentScopeRoot<ComponentType, ComponentControllerType>> newScopeRoot;
  const CKComponentStateUpdateMap stateUpdates;
  std::stack<CKComponentScopeFramePair> stack;
};

typedef CKTypedThreadLocalComponentScope<CKComponent, CKComponentController> CKThreadLocalComponentScope;

/**
 Temporarily overrides the current thread's component scope.
 Use for testing and advanced integration purposes only.
 */
template<typename ComponentType, typename ComponentControllerType>
class CKTypedThreadLocalComponentScopeOverride {
public:
  CKTypedThreadLocalComponentScopeOverride(CKTypedThreadLocalComponentScope<ComponentType, ComponentControllerType> *scope) noexcept;
  ~CKTypedThreadLocalComponentScopeOverride();

private:
  CKTypedThreadLocalComponentScope<ComponentType, ComponentControllerType> *const previousScope;
};

typedef CKTypedThreadLocalComponentScopeOverride<CKComponent, CKComponentController> CKThreadLocalComponentScopeOverride;
