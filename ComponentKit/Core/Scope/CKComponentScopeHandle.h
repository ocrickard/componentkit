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

#import <ComponentKit/CKComponentScopeTypes.h>
#import <ComponentKit/CKUpdateMode.h>
#import <ComponentKit/CKThreadLocalComponentScope.h>
#import <ComponentKit/CKComponentSubclass.h>

#import <libkern/OSAtomic.h>

@class CKComponent;
@class CKComponentController;

@protocol CKComponentStateListener;

template<typename ComponentType, typename ComponentControllerType>
class CKTypedComponentScopeHandle {
  id<CKComponentStateListener> __weak _listener;
  id _state;
  ComponentControllerType *_controller;
  CKComponentScopeRootIdentifier _rootIdentifier;
  CKComponentScopeHandleIdentifier _globalIdentifier;
  BOOL _acquired;
  BOOL _resolved;
  ComponentType *__weak _acquiredComponent;
  
public:
  static std::shared_ptr<CKTypedComponentScopeHandle<ComponentType, ComponentControllerType>>
  handleForComponent(ComponentType *component) noexcept
  {
    auto currentScope = CKTypedThreadLocalComponentScope<ComponentType, ComponentControllerType>::currentScope();
    if (currentScope == nullptr) {
      return nil;
    }
    
    auto handle = currentScope->stack.top().frame.handle;
    if ([handle acquireFromComponent:component]) {
      currentScope->newScopeRoot->registerComponent(component);
      return handle;
    }
    CKCAssertNil(CKComponentControllerClassFromComponentClass([component class]), @"%@ has a controller but no scope! "
                 "Use CKComponentScope scope(self) before constructing the component or CKComponentTestRootScope "
                 "at the start of the test.", [component class]);
    return nil;
  }
  
  CKTypedComponentScopeHandle(id<CKComponentStateListener> listener,
                              CKComponentScopeRootIdentifier rootIdentifier,
                              Class componentClass,
                              id (^initialStateCreator)(void)) :
  _listener(listener),
  _state(initialStateCreator ? initialStateCreator() : [componentClass initialState]),
  _controller(nil),
  _rootIdentifier(rootIdentifier),
  _acquired(NO),
  _resolved(NO)
  {
    static int32_t nextGlobalIdentifier = 0;
    _globalIdentifier = OSAtomicIncrement32(&nextGlobalIdentifier);
  }
  
  std::shared_ptr<CKTypedComponentScopeHandle<ComponentType, ComponentControllerType>>
  newHandle(const CKComponentStateUpdateMap &stateUpdates) const noexcept;
  
  std::shared_ptr<CKTypedComponentScopeHandle<ComponentType, ComponentControllerType>>
  newHandleToBeReacquiredDueToScopeCollision() const noexcept;
  
  void updateState(id (^block)(id), CKUpdateMode mode) const noexcept;
  id state() const noexcept;
  
  CKComponentScopeHandleIdentifier globalIdentifier() const noexcept;
  
  void resolve() noexcept;
  
  ComponentControllerType *controller() const noexcept;
  
  Class componentClass() const noexcept;
  
  id responder() const noexcept;
};

typedef CKTypedComponentScopeHandle<CKComponent, CKComponentController> CKComponentScopeHandle;

//@interface CKComponentScopeHandle <__covariant ComponentType : NSObject *, __covariant ComponentControllerType : NSObject *> : NSObject
//
///**
// This method looks to see if the currently defined scope matches that of the given component; if so it returns the
// handle corresponding to the current scope. Otherwise it returns nil.
// This is only meant to be called when constructing a component and as part of the implementation itself.
// */
//+ (instancetype)handleForComponent:(ComponentType)component;
//
///** Creates a conceptually brand new scope handle */
//- (instancetype)initWithListener:(id<CKComponentStateListener>)listener
//                  rootIdentifier:(CKComponentScopeRootIdentifier)rootIdentifier
//                  componentClass:(Class)componentClass
//             initialStateCreator:(id (^)(void))initialStateCreator;
//
///** Creates a new instance of the scope handle that incorporates the given state updates. */
//- (instancetype)newHandleWithStateUpdates:(const CKComponentStateUpdateMap &)stateUpdates
//                       componentScopeRoot:(CKComponentScopeRoot *)componentScopeRoot;
//
///** Creates a new, but identical, instance of the scope handle that will be reacquired due to a scope collision. */
//- (instancetype)newHandleToBeReacquiredDueToScopeCollision;
//
///** Enqueues a state update to be applied to the scope with the given mode. */
//- (void)updateState:(id (^)(id))updateBlock mode:(CKUpdateMode)mode;
//
///** Informs the scope handle that it should complete its configuration. This will generate the controller */
//- (void)resolve;
//
///**
// Should not be called until after handleForComponent:. The controller will assert (if assertions are compiled), and
// return nil until `resolve` is called.
// */
//@property (nonatomic, strong, readonly) ComponentControllerType controller;
//
//@property (nonatomic, assign, readonly) Class componentClass;
//
//@property (nonatomic, strong, readonly) id state;
//@property (nonatomic, readonly) CKComponentScopeHandleIdentifier globalIdentifier;
//
///**
// Provides a responder corresponding with this scope handle. The controller will assert if called before resolution.
// */
//- (id)responder;
//
//@end
