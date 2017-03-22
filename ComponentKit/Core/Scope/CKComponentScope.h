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

#import <ComponentKit/CKUpdateMode.h>
#import <ComponentKit/CKComponentScopeHandle.h>
#import <ComponentKit/CKThreadLocalComponentScope.h>
#import <ComponentKit/CKComponentScopeRootInternal.h>

typedef void (^CKComponentStateUpdater)(id (^)(id), CKUpdateMode mode);

/**
 Components have local "state" that is independent of the values passed into its +new method. Components can update
 their state independently by calling the [CKComponent -updateState:] method.

 While a component is constructing itself in +new, it needs access to its state; CKComponentScope provides it.
 To use it, create a scope at the top of +new that matches the component's class. For example:

   + (id)initialState
   {
     return [MyState new];
   }

   + (instancetype)newWithModel:(Model *)model
   {
     CKComponentScope scope(self);
     MyState *state = scope.state();
     // ... use the values in state
     return [super newWithComponent:...];
   }
 */
template<typename ComponentType, typename ComponentControllerType>
class CKTypedComponentScope {
public:
  /**
   @param componentClass      Always pass self.
   @param identifier          If there are multiple sibling components of the same class, you must provide an identifier
                              to distinguish them. For example, imagine four photo components that are rendered next to
                              each other; the photo's ID could serve as the identifier to distinguish them.
   @param initialStateCreator By default, the +initialState method will be invoked on the component class to get the
                              initial state. You can optionally pass a block that captures local variables, but see here
                              for why this is usually a bad idea:
                              http://facebook.github.io/react/tips/props-in-getInitialState-as-anti-pattern.html
   */
  CKTypedComponentScope(Class __unsafe_unretained componentClass, id identifier = nil, id (^initialStateCreator)(void) = nil) noexcept
  {
    _threadLocalScope = CKThreadLocalComponentScope::currentScope();
    if (_threadLocalScope != nullptr) {
      const auto childPair = CKComponentScopeFrameChildPairForPair<ComponentType, ComponentControllerType>(_threadLocalScope->stack.top(),
                                                                                                           _threadLocalScope->newScopeRoot,
                                                                                                           componentClass,
                                                                                                           identifier,
                                                                                                           initialStateCreator,
                                                                                                           _threadLocalScope->stateUpdates);
      _threadLocalScope->stack.push({.frame = childPair.frame, .equivalentPreviousFrame = childPair.equivalentPreviousFrame});
      _scopeHandle = childPair.frame.handle;
    }
  }

  ~CKTypedComponentScope()
  {
    if (_threadLocalScope != nullptr) {
      [_scopeHandle resolve];
      _threadLocalScope->stack.pop();
    }
  }

  /** @return The current state for the component being built. */
  id state(void) const noexcept
  {
    return _scopeHandle.state;
  }

  /**
   @return A block that schedules a state update when invoked.
   @discussion Usually, prefer the more idiomatic [CKComponent -updateState:mode:]. Use this in the rare case where you
   need to pass a state updater to a child component during +new. (Usually, the child should communicate back via
   CKComponentAction and the parent should call -updateState:mode: on itself; this hides the implementation details
   of the parent's state from the child.)
  */
  CKComponentStateUpdater stateUpdater(void) const noexcept
  {
    // We must capture _scopeHandle in a local, since this may be destroyed by the time the block executes.
    std::shared_ptr<CKTypedComponentScopeHandle<ComponentType, ComponentControllerType>> scopeHandle = _scopeHandle;
    return ^(id (^update)(id), CKUpdateMode mode){ if (scopeHandle) {
      scopeHandle->updateState(update, mode);
    }};
  }

  /**
   @return The scope handle associated with this scope.
   @discussion This is exposed for use by the framework. You should almost certainly never call this for any reason
               in your components.
   */
  std::shared_ptr<CKTypedComponentScopeHandle<ComponentType, ComponentControllerType>> scopeHandle(void) const noexcept
  {
    return _scopeHandle;
  };

private:
  CKTypedComponentScope(const CKTypedComponentScope&) = delete;
  CKTypedComponentScope &operator=(const CKTypedComponentScope&) = delete;
  CKThreadLocalComponentScope *_threadLocalScope;
  std::shared_ptr<CKTypedComponentScopeHandle<ComponentType, ComponentControllerType>> _scopeHandle;
};

@class CKComponent;
@class CKComponentController;

typedef CKTypedComponentScope<CKComponent, CKComponentController> CKComponentScope;
