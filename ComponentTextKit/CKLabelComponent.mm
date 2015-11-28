/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import "CKLabelComponent.h"

#import <ComponentKit/CKTextKitRenderer.h>
#import <ComponentKit/CKTextComponent.h>
#import <ComponentKit/CKTextComponentView.h>
#import <ComponentKit/CKTextComponentViewInternal.h>
#import <ComponentKit/CKTextComponentLayer.h>
#import <ComponentKit/CKTextComponentLayerSelectionController.h>

@implementation CKLabelComponent

+ (instancetype)newWithLabelAttributes:(const CKLabelAttributes &)attributes
                        viewAttributes:(const CKViewComponentAttributeValueMap &)viewAttributes
{
  CKTextComponentSelectionAttributes selectionAttributes;
  if (attributes.selectionEnabled) {
    selectionAttributes = {
      .selectionEnabled = YES,
      .menuItems = {
        {
          .title = @"Copy",
          .canPerformBlock = ^BOOL(CKTextComponentView *textView) {
            return textView.textLayer.selectionController.selectedRange.length > 0;
          },
          .activationBlock = ^(CKTextComponentView *textView) {
            NSRange selectedRange = textView.textLayer.selectionController.selectedRange;
            if (selectedRange.length > 0) {
              NSString *string = textView.renderer.attributes.attributedString.string;
              NSRange clampedRange = NSIntersectionRange(selectedRange, NSMakeRange(0, string.length));
              if (clampedRange.location != NSNotFound) {
                NSString *substring = [string substringWithRange:clampedRange];
                [[UIPasteboard generalPasteboard] setString:substring];
              }
            }
          }
        }
      }
    };
  } else {
    selectionAttributes = {};
  }
  CKViewComponentAttributeValueMap copiedMap = viewAttributes;
  return [super newWithComponent:
          [CKTextComponent
           newWithTextAttributes:textKitAttributes(attributes)
           selectionAttributes:selectionAttributes
           viewAttributes:std::move(copiedMap)
           accessibilityContext:{.isAccessibilityElement = @(YES)}]];
}

static const CKTextKitAttributes textKitAttributes(const CKLabelAttributes &labelAttributes)
{
  return {
    .attributedString = formattedAttributedString(labelAttributes.string, labelAttributes),
    .truncationAttributedString = formattedAttributedString(labelAttributes.truncationString, labelAttributes),
    .lineBreakMode = labelAttributes.lineBreakMode,
    .maximumNumberOfLines = labelAttributes.maximumNumberOfLines,
    .shadowOffset = labelAttributes.shadowOffset,
    .shadowColor = labelAttributes.shadowColor,
    .shadowOpacity = labelAttributes.shadowOpacity,
    .shadowRadius = labelAttributes.shadowRadius,
  };
}

static NSAttributedString *formattedAttributedString(NSString *string, const CKLabelAttributes &labelAttributes)
{
  if (!string) {
    return nil;
  }
  return [[NSAttributedString alloc] initWithString:string
                                         attributes:stringAttributes(labelAttributes)];
}

static NSDictionary *stringAttributes(const CKLabelAttributes &labelAttributes)
{
  NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
  if (labelAttributes.font) {
    attributes[NSFontAttributeName] = labelAttributes.font;
  }
  if (labelAttributes.color) {
    attributes[NSForegroundColorAttributeName] = labelAttributes.color;
  }
  attributes[NSParagraphStyleAttributeName] = paragraphStyle(labelAttributes);
  return attributes;
}

static NSParagraphStyle *paragraphStyle(const CKLabelAttributes &labelAttributes)
{
  NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
  ps.alignment = labelAttributes.alignment;
  ps.firstLineHeadIndent = labelAttributes.firstLineHeadIndent;
  ps.headIndent = labelAttributes.headIndent;
  ps.tailIndent = labelAttributes.tailIndent;
  ps.lineHeightMultiple = labelAttributes.lineHeightMultiple;
  ps.maximumLineHeight = labelAttributes.maximumLineHeight;
  ps.minimumLineHeight = labelAttributes.minimumLineHeight;
  ps.lineSpacing = labelAttributes.lineSpacing;
  ps.paragraphSpacing = labelAttributes.paragraphSpacing;
  ps.paragraphSpacingBefore = labelAttributes.paragraphSpacingBefore;
  return ps;
}

@end
