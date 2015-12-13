//
//  PAImageScrollView.h
//  PicasaWebAlbum
//
//  Created by Keisuke Karijuku on 2014/05/08.
//  Copyright (c) 2014年 Keisuke Karijuku. All rights reserved.
//

@import UIKit;

typedef NS_ENUM(NSInteger, PAImageScrollViewZoomOption) {
    PAImageScrollViewZoomOptionLinear, //default
    PAImageScrollViewZoomOptionAdjust
};

@interface PAImageScrollView : UIScrollView

@property (copy, nonatomic) void (^ _Nullable didSingleTapBlock)(PAImageScrollView * _Nonnull scrollView);
@property (copy, nonatomic) void (^ _Nullable didDoubleTapBlock)(PAImageScrollView * _Nonnull scrollView, CGFloat toZoomScale);
@property (copy, nonatomic) void (^ _Nullable didZoomBlock)(PAImageScrollView * _Nonnull scrollView, CGFloat zoomScale);
@property (copy, nonatomic) void (^ _Nullable firstTimeZoomBlock)(PAImageScrollView * _Nonnull scrollView);

@property (nonatomic) Class _Nonnull imageViewClass;
@property (nonatomic) PAImageScrollViewZoomOption zoomOption;
@property (nonatomic, readonly) UIImageView * _Nonnull imageView;
@property (strong, nonatomic) UIImage * _Nullable image;
@property (nonatomic) CGFloat doubleTapZoomScale;
@property (nonatomic) BOOL isDisableZoom;

- (void)setImage:(UIImage * _Nullable)image resetImageView:(BOOL)isReset;

@end
