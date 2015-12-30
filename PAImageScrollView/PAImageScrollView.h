//
//  PAImageScrollView.h
//  PicasaWebAlbum
//
//  Created by Keisuke Karijuku on 2014/05/08.
//  Copyright (c) 2014年 Keisuke Karijuku. All rights reserved.
//

@import UIKit;
@import AVFoundation;


typedef NS_ENUM(NSInteger, PAImageScrollViewZoomOption) {
    PAImageScrollViewZoomOptionLinear, //default
    PAImageScrollViewZoomOptionAdjust
};


@interface PAImageScrollView : UIScrollView

@property (copy, nonatomic) void (^ _Nullable didSingleTapBlock)(PAImageScrollView * _Nonnull scrollView);
@property (copy, nonatomic) void (^ _Nullable didDoubleTapBlock)(PAImageScrollView * _Nonnull scrollView, CGFloat toZoomScale);
@property (copy, nonatomic) void (^ _Nullable didZoomBlock)(PAImageScrollView * _Nonnull scrollView, CGFloat zoomScale);
@property (copy, nonatomic) void (^ _Nullable firstTimeZoomBlock)(PAImageScrollView * _Nonnull scrollView);

@property (nonatomic, readonly) UIImageView * _Nonnull imageView;

@property (nonatomic) PAImageScrollViewZoomOption zoomOption;
@property (nonatomic) CGFloat doubleTapZoomScale;
@property (nonatomic) BOOL isDisableZoom;

- (UIImage * _Nullable)image;
- (void)setImage:(UIImage * _Nullable)image;
- (void)setImage:(UIImage * _Nullable)image resetImageView:(BOOL)isReset;
- (void)setImage:(UIImage * _Nullable)image resetImageView:(BOOL)isReset imageViewClass:(Class _Nonnull)imageViewClass;

@end
