//
//  PAImageScrollView.h
//  PicasaWebAlbum
//
//  Created by Keisuke Karijuku on 2014/05/08.
//  Copyright (c) 2014年 Keisuke Karijuku. All rights reserved.
//

@import UIKit;

@interface PAImageScrollView : UIScrollView

@property (copy, nonatomic) void (^didSingleTapBlock)(PAImageScrollView *scrollView);
@property (copy, nonatomic) void (^didDoubleTapBlock)(PAImageScrollView *scrollView, CGFloat toZoomScale);
@property (copy, nonatomic) void (^didZoomBlock)(PAImageScrollView *scrollView, CGFloat zoomScale);
@property (copy, nonatomic) void (^firstTimeZoomBlock)(PAImageScrollView *scrollView);

@property (nonatomic) Class imageViewClass;
@property (nonatomic, readonly) UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;
@property (nonatomic) BOOL isDisableZoom;

@end
