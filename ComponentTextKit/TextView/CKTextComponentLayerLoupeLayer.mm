/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import "CKTextComponentLayerLoupeLayer.h"

#import <UIKit/UIKit.h>

#import <ComponentKit/CKInternalHelpers.h>
#import <ComponentKit/CKAssert.h>

/**
 In order to avoid including any assets as part of ComponentKit, we have created a CoreGraphics approximation of the
 loupe image, and we draw it once the first time it is requested, and cache it in-memory. This code was generated with
 PaintCode 2.
 */
static UIImage *loupeImage(void)
{
  static UIImage *image;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    CGRect frame = CGRectMake(0, 0, 125, 127);

    UIGraphicsBeginImageContextWithOptions(frame.size, NO, [UIScreen mainScreen].scale);
    CGContextRef bitmapContext = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(bitmapContext, [UIColor clearColor].CGColor);
    CGContextFillRect(bitmapContext, frame);

    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Color Declarations
    UIColor* loupeStrokeColor = [UIColor colorWithWhite:0 alpha:0.196];
    UIColor* gradientColor = [UIColor colorWithWhite:0 alpha:0];

    //// Gradient Declarations
    CGFloat gradientLocations[] = {0, 0.34, 0.95};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)@[(id)UIColor.blackColor.CGColor, (id)[UIColor colorWithWhite:0 alpha:0.5].CGColor, (id)gradientColor.CGColor], gradientLocations);

    //// Shadow Declarations
    NSShadow* innerShadow = [[NSShadow alloc] init];
    [innerShadow setShadowColor:[UIColor.blackColor colorWithAlphaComponent:0.14]];
    [innerShadow setShadowOffset:CGSizeMake(0.1, 20.1)];
    [innerShadow setShadowBlurRadius:21];

    //// Subframes
    CGRect group = frame;


    //// Group
    {
      //// Bezier Drawing
      UIBezierPath* bezierPath = [UIBezierPath bezierPath];
      [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(group) + 0.49800 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.04921 * CGRectGetHeight(group))];
      [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.24096 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.12726 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.40265 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.04921 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.31414 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.07801 * CGRectGetHeight(group))];
      [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.04200 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.49803 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.12083 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.20809 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.04200 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.34400 * CGRectGetHeight(group))];
      [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.49800 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.94685 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.04200 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.74591 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.24616 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.94685 * CGRectGetHeight(group))];
      [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.95400 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.49803 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.74984 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.94685 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.95400 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.74591 * CGRectGetHeight(group))];
      [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.49800 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.04921 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.95400 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.25016 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.74984 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.04921 * CGRectGetHeight(group))];
      [bezierPath closePath];
      [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(group) + 1.00000 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.00001 * CGRectGetHeight(group))];
      [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 1.00000 * CGRectGetWidth(group), CGRectGetMinY(group) + 1.00000 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 1.00000 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.00000 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 1.00000 * CGRectGetWidth(group), CGRectGetMinY(group) + 1.00000 * CGRectGetHeight(group))];
      [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 0.00000 * CGRectGetWidth(group), CGRectGetMinY(group) + 1.00000 * CGRectGetHeight(group))];
      [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 0.00000 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.00000 * CGRectGetHeight(group))];
      [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 1.00000 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.00000 * CGRectGetHeight(group))];
      [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 1.00000 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.00001 * CGRectGetHeight(group))];
      [bezierPath closePath];
      CGContextSaveGState(context);
      [bezierPath addClip];
      CGRect bezierBounds = CGPathGetPathBoundingBox(bezierPath.CGPath);
      CGFloat bezierResizeRatio = MIN(CGRectGetWidth(bezierBounds) / 125, CGRectGetHeight(bezierBounds) / 127);

      // CoreGraphics doesn't allow us to use a drop shadow on the exterior of an empty shape. Instead we use a
      CGContextDrawRadialGradient(context, gradient,
                                  CGPointMake(CGRectGetMidX(bezierBounds) + 0.35 * bezierResizeRatio, CGRectGetMidY(bezierBounds) + 25.34 * bezierResizeRatio), 21.8 * bezierResizeRatio,
                                  CGPointMake(CGRectGetMidX(bezierBounds) + 0 * bezierResizeRatio, CGRectGetMidY(bezierBounds) + 0 * bezierResizeRatio), 62.21 * bezierResizeRatio,
                                  kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
      CGContextRestoreGState(context);


      //// Oval Drawing
      UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(group) + floor(CGRectGetWidth(group) * 0.04400) + 0.5, CGRectGetMinY(group) + floor(CGRectGetHeight(group) * 0.05118) + 0.5, floor(CGRectGetWidth(group) * 0.95600) - floor(CGRectGetWidth(group) * 0.04400), floor(CGRectGetHeight(group) * 0.94882) - floor(CGRectGetHeight(group) * 0.05118))];
      [UIColor.clearColor setFill];
      [ovalPath fill];

      ////// Oval Inner Shadow
      CGContextSaveGState(context);
      UIRectClip(ovalPath.bounds);
      CGContextSetShadowWithColor(context, CGSizeZero, 0, NULL);

      CGContextSetAlpha(context, CGColorGetAlpha([innerShadow.shadowColor CGColor]));
      CGContextBeginTransparencyLayer(context, NULL);
      {
        UIColor* opaqueShadow = [innerShadow.shadowColor colorWithAlphaComponent: 1];
        CGContextSetShadowWithColor(context, innerShadow.shadowOffset, innerShadow.shadowBlurRadius, [opaqueShadow CGColor]);
        CGContextSetBlendMode(context, kCGBlendModeSourceOut);
        CGContextBeginTransparencyLayer(context, NULL);

        [opaqueShadow setFill];
        [ovalPath fill];

        CGContextEndTransparencyLayer(context);
      }
      CGContextEndTransparencyLayer(context);
      CGContextRestoreGState(context);
      
      [loupeStrokeColor setStroke];
      ovalPath.lineWidth = 0.5;
      [ovalPath stroke];
    }

    //// Cleanup
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);

    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
  });
  return image;
}

static void renderZoomedLayer(CGContextRef context, UIWindow *targetWindow, CGFloat zoomMultiplier, CGSize imageSize, CGPoint pointOfInterest)
{
  CGContextTranslateCTM(context, (imageSize.width / 2.0),(imageSize.height / 2.0));
  CGContextScaleCTM(context, zoomMultiplier, zoomMultiplier);
  CGContextTranslateCTM(context, -pointOfInterest.x, -pointOfInterest.y);
  [targetWindow drawViewHierarchyInRect:targetWindow.bounds afterScreenUpdates:NO];
  CGContextConcatCTM(context, CGAffineTransformInvert(CGContextGetCTM(context)));
}

@interface CKTextComponentLayerLoupeContentsLayerRenderDelegate : NSObject

- (instancetype)initWithTargetLayer:(CALayer *)targetLayer;

@property (nonatomic, strong) CALayer *targetLayer;
@property (nonatomic, strong) UIWindow *targetWindow;
@property (nonatomic, strong) CALayer *renderLayer;
@property (nonatomic, assign) CGPoint pointOfInterest;

@end

@implementation CKTextComponentLayerLoupeContentsLayerRenderDelegate

- (instancetype)initWithTargetLayer:(CALayer *)targetLayer
{
  if (self = [super init]) {
    _targetLayer = targetLayer;

    UIView *targetView = _targetLayer.delegate;

    if ([targetView isKindOfClass:[UIView class]]) {
      // We don't support layers that don't have views at the moment.
      _targetWindow = targetView.window;
      _renderLayer = _targetWindow.layer;
    } else {
      CKAssert(NO, @"We don't support drawing the loupe for a layer whose delegate is not a view");
    }
  }
  return self;
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
  CGRect bounds = CGRectInset(layer.bounds, 5.5, 6.5);
  UIGraphicsPushContext(ctx);
  UIBezierPath *bezierPath = [UIBezierPath bezierPathWithOvalInRect:bounds];
  [bezierPath addClip];
  renderZoomedLayer(ctx,
                    _targetWindow,
                    1.1,
                    bounds.size,
                    [_renderLayer convertPoint:_pointOfInterest
                                     fromLayer:_targetLayer]);
  UIGraphicsPopContext();
}

@end

@implementation CKTextComponentLayerLoupeLayer
{
  CAShapeLayer *_loupeBackgroundLayer;
  UIImage *_zoomedImage;
  CALayer *_loupeContentsLayer;
  CALayer *_loupeImageLayer;
  CKTextComponentLayerLoupeContentsLayerRenderDelegate *_renderDelegate;
}

- (instancetype)initWithTargetLayer:(CALayer *)targetLayer
{
  if (self = [super init]) {
    _loupeBackgroundLayer = [CAShapeLayer layer];
    _loupeBackgroundLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(self.bounds, 5.5, 6.5)].CGPath;
    _loupeBackgroundLayer.fillColor = _targetLayer.backgroundColor;
    [self addSublayer:_loupeBackgroundLayer];

    _loupeContentsLayer = [CALayer layer];
    _loupeContentsLayer.actions = @{@"contents" : [NSNull null]};
    _loupeContentsLayer.frame = self.bounds;
    _loupeContentsLayer.delegate = self;
    _loupeContentsLayer.contentsScale = CKScreenScale();
    _renderDelegate = [[CKTextComponentLayerLoupeContentsLayerRenderDelegate alloc] initWithTargetLayer:targetLayer];
    _loupeContentsLayer.delegate = _renderDelegate;
    [self addSublayer:_loupeContentsLayer];
    [_loupeContentsLayer setNeedsDisplay];

    _loupeImageLayer = [CALayer layer];
    _loupeImageLayer.contents = (__bridge id)[loupeImage() CGImage];
    _loupeImageLayer.frame = self.bounds;
    [self addSublayer:_loupeImageLayer];
  }
  return self;
}

- (void)setPointOfInterest:(CGPoint)pointOfInterest
{
  _pointOfInterest = pointOfInterest;
  _renderDelegate.pointOfInterest = pointOfInterest;
  [_loupeContentsLayer setNeedsDisplay];
}

- (void)layoutSublayers
{
  _loupeBackgroundLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(self.bounds, 5.5, 6.5)].CGPath;
  _loupeContentsLayer.frame = self.bounds;
  _loupeImageLayer.frame = self.bounds;
}

@end
