/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <ComponentKit/CKComponentScopeRoot.h>

#import <ComponentKit/CKMacros.h>
#import <ComponentKit/CKAssert.h>

template<typename ComponentType, typename ComponentControllerType>
CKComponentScopeFramePair CKComponentScopeFrameChildPairForPair(const CKComponentScopeFramePair &pair,
                                                                CKComponentScopeRoot *newRoot,
                                                                Class componentClass,
                                                                id identifier,
                                                                id (^initialStateCreator)(),
                                                                const CKComponentStateUpdateMap &stateUpdates)
{
  CKCAssert([componentClass isSubclassOfClass:[ComponentType class]], @"%@ is not a component", NSStringFromClass(componentClass));
  CKCAssertNotNil(pair.frame, @"Must have frame");
  
  std::shared_ptr<CKTypedComponentScopeFrame<ComponentType, ComponentControllerType>> existingChildFrameOfEquivalentPreviousFrame;
  if (pair.equivalentPreviousFrame) {
    const auto &equivalentPreviousFrameChildren = pair.equivalentPreviousFrame->children();
    const auto it = equivalentPreviousFrameChildren.find({componentClass, identifier});
    existingChildFrameOfEquivalentPreviousFrame = (it == equivalentPreviousFrameChildren.end()) ? nullptr : it->second;
  }
  
  const auto existingChild = pair.frame->children().find({componentClass, identifier});
  if (!pair.frame->children().empty() && (existingChild != pair.frame->children().end())) {
    /*
     The component was involved in a scope collision and the scope handle needs to be reacquired.
     
     In the event of a component scope collision the component scope frame reuses the existing scope handle; any
     existing state will be made available to the component that introduced the scope collision. This leads to some
     interesting side effects:
     
     1. Any component state associated with the scope handle will be shared between components with colliding scopes
     2. Any component controller associated with the scope handle will be responsible for each component with
     colliding scopes; resulting in strange behavior while components are mounted, unmounted, etc.
     
     Reusing the existing scope handle allows ComponentKit to detect component scope collisions during layout. Moving
     component scope collision detection to component layout makes it possible to create multiple components that may
     normally result in a scope collision even if only one component actually makes it to layout.
     */
    std::shared_ptr<CKTypedComponentScopeHandle<ComponentType, ComponentControllerType>> newHandle =
    existingChild->second->scopeHandle()->newHandleToBeReacquiredDueToScopeCollision();
    
    std::shared_ptr<CKTypedComponentScopeFrame<ComponentType, ComponentControllerType>> newChild = std::make_shared<CKTypedComponentScopeFrame<ComponentType, ComponentControllerType>>(newHandle);
    /*
     Share the initial component scope tree across all colliding component scopes.
     
     This behavior ensures the initial component scope tree "wins" in the event of a component scope collision:
     
     +-------+         +-------+         +-------+
     |       |         |       |         |       |
     |   A   |         |   A   |         |   A   |
     |      1|         |      2|         |      3|
     +-------+         +-------+         +-------+
     |                 | collision       | collision
     +-----------------+-----------------+
     /|\
     / | \
     /  |  \
     +---+ +---+ +---+
     | 1 | | 2 | | 3 |
     +---+ +---+ +---+
     / \
     +---+ +---+
     | 4 | | 5 |
     +---+ +---+
     
     In the example above the component scope frames labeled as "A" are involved in scope collisions. Notice that only
     one component scope tree exists for all three component scope frames involved in the collision. Any component state
     or component controllers present in the intial component scope tree are now present across all colliding component
     scope frames.
     
     Now assume each component scope frame above is paired with a matching component. Component scope frame A1 belongs
     to component A1, colliding component scope frame A2 belongs to component A2, component scope frame 4 belongs to
     component 4, and so on. If only component A2 finds its way to layout (i.e. both A1 and A3 were simply created and
     not added to the component hierarchy) this behavior guarantees that component 4 always acquires the same component
     scope.
     
     Compare this behavior to the behavior that would exist if the initial component scope tree were not shared:
     
     +-------+         +-------+         +-------+
     |       |         |       |         |       |
     |   A   |         |   A   |         |   A   |
     |      1|         |      2|         |      3|
     +-------+         +-------+         +-------+
     |                 | collision       | collision
     +-----------------+-----------------+
     /|\                .                /|\
     / | \               .               / | \
     /  |  \              .              /  |  \
     +---+ +---+ +---+                   +---+ +---+ +---+
     | 1 | | 2 | | 3 |                   | 1'| | 2'| | 3'|
     +---+ +---+ +---+                   +---+ +---+ +---+
     / \                                 / \
     +---+ +---+                         +---+ +---+
     | 4 | | 5 |                         | 4'| | 5'|
     +---+ +---+                         +---+ +---+
     
     Each component scope frame participating in the collision now has its own unique component scope tree. For
     component scope frame A1 the outcome is largely the same. Things get a bit more interesting for A2 and A3. Notice
     that A3 now has its own, nearly identical, component scope tree. The structure is the same but the component state
     and component controllers are different.
     
     Problems arise when the component that owns component scope frame A3 is added to the component hierarchy. Suppose
     A3 is building its component scope tree for the first time. The component that owns component scope frame 4' will
     acquire a new component controller as there is no equivalent previous frame, as expected.
     
     The next time the component hierarchy is created (e.g. after a component state update) component scope frame 4'
     actually finds component scope frame 4 in the equivalent previous frame. This means component 4' will acquire a
     DIFFERENT component controller instance than it had originally. Why? Because the component scope frame above
     component scope frame A will only ever have A1 as a child because A1 was inserted before A2 and A3.
     */
    newChild->_children = existingChild->second->children();
    return {.frame = newChild, .equivalentPreviousFrame = existingChildFrameOfEquivalentPreviousFrame};
  }
  
  std::shared_ptr<CKTypedComponentScopeHandle<ComponentType, ComponentControllerType>> newHandle =
  existingChildFrameOfEquivalentPreviousFrame
  ? existingChildFrameOfEquivalentPreviousFrame->handle->newHandle(stateUpdates)
  : std::make_shared<CKTypedComponentScopeHandle<ComponentType, ComponentControllerType>>(newRoot->listener(),
                                                                                          newRoot->globalIdentifier(),
                                                                                          componentClass,
                                                                                          initialStateCreator);
  
  std::shared_ptr<CKTypedComponentScopeFrame<ComponentType, ComponentControllerType>> newChild = std::make_shared<CKTypedComponentScopeFrame<ComponentType, ComponentControllerType>>(newHandle);
  pair.frame->children().insert({{componentClass, identifier}, newChild});
  return {.frame = newChild, .equivalentPreviousFrame = existingChildFrameOfEquivalentPreviousFrame};
}
