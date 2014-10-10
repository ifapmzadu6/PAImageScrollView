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

@property (copy, nonatomic) void (^didSingleTapBlock)(PAImageScrollView *scrollView);
@property (copy, nonatomic) void (^didDoubleTapBlock)(PAImageScrollView *scrollView, CGFloat toZoomScale);
@property (copy, nonatomic) void (^didZoomBlock)(PAImageScrollView *scrollView, CGFloat zoomScale);
@property (copy, nonatomic) void (^firstTimeZoomBlock)(PAImageScrollView *scrollView);

@property (nonatomic) Class imageViewClass;
@property (nonatomic) PAImageScrollViewZoomOption zoomOption;
@property (nonatomic, readonly) UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;
@property (nonatomic) CGFloat doubleTapZoomScale;
@property (nonatomic) BOOL isDisableZoom;

- (void)setImage:(UIImage *)image resetImageView:(BOOL)isReset;
@end
