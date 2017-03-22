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
#import <ComponentKit/CKComponentScopeFrame.h>
#import <ComponentKit/CKComponentScopeTypes.h>
#import <ComponentKit/CKUpdateMode.h>

#import <unordered_map>
#import <vector>

@class CKComponent;

/** Component state announcements will always be made on the main thread. */
@protocol CKComponentStateListener <NSObject>

- (void)componentScopeHandleWithIdentifier:(CKComponentScopeHandleIdentifier)globalIdentifier
                            rootIdentifier:(CKComponentScopeRootIdentifier)rootIdentifier
                     didReceiveStateUpdate:(id (^)(id))stateUpdate
                                      mode:(CKUpdateMode)mode;

@end

template<typename ComponentType, typename ComponentControllerType>
class CKTypedComponentScopeRoot {
  __weak id<CKComponentStateListener> _listener;
  CKComponentScopeRootIdentifier _globalIdentifier;
  std::shared_ptr<CKTypedComponentScopeFrame<ComponentType, ComponentControllerType>> _rootFrame;
  
  std::vector<SEL> _announceableComponentEvents;
  std::unordered_multimap<SEL, ComponentType *__weak> _registeredComponents;
  
  std::vector<SEL> _announceableComponentControllerEvents;
  std::unordered_multimap<SEL, ComponentControllerType *__weak> _registeredComponentControllers;
  
public:
  CKTypedComponentScopeRoot() : _listener(nil) {};
  CKTypedComponentScopeRoot(id<CKComponentStateListener> listener) : _listener(listener) {};
  
  id<CKComponentStateListener> listener() const { return _listener; };
  CKComponentScopeRootIdentifier globalIdentifier() const { return _globalIdentifier; };
  std::shared_ptr<CKTypedComponentScopeFrame<ComponentType, ComponentControllerType>> rootFrame() const { return _rootFrame; };
  
  void enumerateRegisteredComponentsForEvent(SEL selector, void (^block)(ComponentType *component)) const
  {
    for (const auto &c : _registeredComponents.find(selector)) {
      block(c);
    }
  }
  
  void enumerateRegisteredComponentControllersForEvent(SEL selector, void (^block)(ComponentControllerType *componentController)) const
  {
    for (const auto &c : _registeredComponentControllers.find(selector)) {
      block(c);
    }
  }
  
  void registerComponent(ComponentType *component)
  {
    for (const auto &selector : _announceableComponentEvents) {
      if ([component respondsToSelector:selector]) {
        _registeredComponents.insert({selector, component});
      }
    }
  }
  
  void registerComponentController(ComponentControllerType *componentController)
  {
    for (const auto &selector : _announceableComponentControllerEvents) {
      if ([componentController respondsToSelector:selector]) {
        _registeredComponentControllers.insert({selector, componentController});
      }
    }
  }
};

typedef CKTypedComponentScopeRoot<CKComponent, CKComponentController> CKComponentScopeRoot;

template<typename ComponentType, typename ComponentControllerType>
struct CKTypedBuildComponentResult {
  ComponentType *component;
  std::shared_ptr<CKTypedComponentScopeRoot<ComponentType, ComponentControllerType>> scopeRoot;
};

typedef CKTypedBuildComponentResult<CKComponent, CKComponentController> CKBuildComponentResult;

template<typename ComponentType, typename ComponentControllerType>
CKTypedBuildComponentResult<ComponentType, ComponentControllerType>
CKBuildComponent(std::shared_ptr<CKTypedComponentScopeRoot<ComponentType, ComponentControllerType>> previousRoot,
                 const CKComponentStateUpdateMap &stateUpdates,
                 ComponentType *(^function)(void));
