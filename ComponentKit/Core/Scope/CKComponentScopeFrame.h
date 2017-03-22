/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <UIKit/UIKit.h>

#import <ComponentKit/CKComponentScopeTypes.h>
#import <ComponentKit/CKComponentScopeHandle.h>
#import <ComponentKit/CKMacros.h>
#import <ComponentKit/CKEqualityHashHelpers.h>
#import <ComponentKit/ComponentUtilities.h>

typedef struct _CKStateScopeKey {
  Class __unsafe_unretained componentClass;
  id identifier;
  
  bool operator==(const _CKStateScopeKey &v) const {
    return (CKObjectIsEqual(this->componentClass, v.componentClass) && CKObjectIsEqual(this->identifier, v.identifier));
  }
} _CKStateScopeKey;

namespace std {
  template <>
  struct hash<_CKStateScopeKey> {
    size_t operator ()(_CKStateScopeKey k) const {
      NSUInteger subhashes[] = { [k.componentClass hash], [k.identifier hash] };
      return CKIntegerArrayHash(subhashes, CK_ARRAY_COUNT(subhashes));
    }
  };
}

template<typename ComponentType, typename ComponentControllerType>
class CKTypedComponentScopeFrame {
  std::shared_ptr<CKTypedComponentScopeHandle<ComponentType, ComponentControllerType>> _scopeHandle;
  std::unordered_map<_CKStateScopeKey, std::shared_ptr<CKTypedComponentScopeFrame<ComponentType, ComponentControllerType>>> _children;
public:
  CKTypedComponentScopeFrame(std::shared_ptr<CKTypedComponentScopeHandle<ComponentType, ComponentControllerType>> scopeHandle) noexcept : _scopeHandle(scopeHandle) {};
  
  std::shared_ptr<CKTypedComponentScopeHandle<ComponentType, ComponentControllerType>> scopeHandle() const noexcept { return _scopeHandle; };
  
  std::unordered_map<_CKStateScopeKey, std::shared_ptr<CKTypedComponentScopeFrame<ComponentType, ComponentControllerType>>> &children() { return _children; };
};

typedef CKTypedComponentScopeFrame<CKComponent, CKComponentController> CKComponentScopeFrame;

template<typename ComponentType, typename ComponentControllerType>
struct CKTypedComponentScopeFramePair {
  std::shared_ptr<CKTypedComponentScopeFrame<ComponentType, ComponentControllerType>> frame;
  std::shared_ptr<CKTypedComponentScopeFrame<ComponentType, ComponentControllerType>>  equivalentPreviousFrame;
};

typedef CKTypedComponentScopeFramePair<CKComponent, CKComponentController> CKComponentScopeFramePair;
//@interface CKComponentScopeFrame<__covariant ComponentType : NSObject *, __covariant ComponentControllerType : NSObject *> : NSObject
//
//+ (CKComponentScopeFramePair)childPairForPair:(const CKComponentScopeFramePair &)pair
//                                      newRoot:(CKComponentScopeRoot *)newRoot
//                               componentClass:(Class)aClass
//                                   identifier:(id)identifier
//                          initialStateCreator:(id (^)(void))initialStateCreator
//                                 stateUpdates:(const CKComponentStateUpdateMap &)stateUpdates;
//
//- (instancetype)initWithHandle:(CKComponentScopeHandle *)handle;
//
//@property (nonatomic, strong, readonly) CKComponentScopeHandle<ComponentType, ComponentControllerType> *handle;
//
//@end
