//
//  PAImageScrollView.m
//  PicasaWebAlbum
//
//  Created by Keisuke Karijuku on 2014/05/08.
//  Copyright (c) 2014年 Keisuke Karijuku. All rights reserved.
//

#import "PAImageScrollView.h"


const CGFloat defaultDoubleTapZoomScale = 3.0;
const PAImageScrollViewZoomOption defaultPAImageScrollViewZoomOption = PAImageScrollViewZoomOptionLinear;


@interface PAImageScrollView () <UIScrollViewDelegate>

@property (nonatomic) CGSize imageSize;
@property (nonatomic) CGPoint pointToCenterAfterResize;
@property (nonatomic) CGFloat scaleToRestoreAfterResize;
@property (nonatomic) CGFloat middleZoomScale;

@end


@implementation PAImageScrollView

- (id)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.bouncesZoom = YES;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.delegate = self;
    self.exclusiveTouch = YES;
    self.zoomScale = 1.0f;
    self.doubleTapZoomScale = defaultDoubleTapZoomScale;
    
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTapGesture.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleTapGesture];
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTapGesture];
    
    _zoomOption = defaultPAImageScrollViewZoomOption;
}

- (void)centerScrollViewContentsWithView:(UIView *)view {
    // center the zoom view as it becomes smaller than the size of the screen
    CGSize size = self.bounds.size;
    CGRect frame = view.frame;
    // center horizontally
    frame.origin.x = (frame.size.width < size.width) ? (size.width - frame.size.width) / 2 : 0;
    // center vertically
    frame.origin.y = (frame.size.height < size.height) ? (size.height - frame.size.height) / 2 : 0;
    
    view.frame = frame;
}

- (void)setFrame:(CGRect)frame {
    BOOL sizeChanging = !CGSizeEqualToSize(frame.size, self.bounds.size);
    BOOL notSizeZero = !CGSizeEqualToSize(_imageSize, CGSizeZero);
    
    if (sizeChanging && notSizeZero) {
        [self prepareToResize];
    }
    
    [super setFrame:frame];
    
    if (sizeChanging && notSizeZero) {
        [self recoverFromResizing];
    }
}

#pragma mark Methods
- (UIImage *)image {
    return _imageView.image;
}

- (void)setImage:(UIImage *)image {
    [self setImage:image resetImageView:false];
}

- (void)setImage:(UIImage * _Nullable)image resetImageView:(BOOL)isReset {
    [self setImage:image resetImageView:isReset imageViewClass:UIImageView.class];
}

- (void)setImage:(UIImage * _Nullable)image resetImageView:(BOOL)isReset imageViewClass:(Class _Nonnull)imageViewClass {
    if (!image) {
        return;
    }
    
    if (!isReset && _imageView) {
        _imageView.image = image;
        return;
    }
    
    if (_imageView) {
        [_imageView removeFromSuperview];
        _imageView = nil;
    }
    
    CGSize imageSize = AVMakeRectWithAspectRatioInsideRect(image.size, self.bounds).size;
    _imageView = [[imageViewClass alloc] initWithFrame:(CGRect){CGPointZero, imageSize}];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.image = image;
    [self addSubview:_imageView];
    
    _imageSize = imageSize;
    self.contentSize = imageSize;
    [self setMaxMinZoomScalesForCurrentBounds];
    self.zoomScale = self.minimumZoomScale;
    [self centerScrollViewContentsWithView:_imageView];
}

- (void)setIsDisableZoom:(BOOL)isDisableZoom {
    if (_isDisableZoom == isDisableZoom) {
        return;
    }
    _isDisableZoom = isDisableZoom;
    
    if (isDisableZoom) {
        self.maximumZoomScale = self.minimumZoomScale;
    }
}

- (void)setZoomOption:(PAImageScrollViewZoomOption)zoomOption {
    if (_zoomOption == zoomOption) {
        return;
    }
    _zoomOption = zoomOption;
    
    if (_imageView) {
        [self setMaxMinZoomScalesForCurrentBounds];
    }
}

- (void)setDoubleTapZoomScale:(CGFloat)doubleTapZoomScale {
    if (fabs(_doubleTapZoomScale - doubleTapZoomScale) < FLT_EPSILON) {
        return;
    }
    _doubleTapZoomScale = doubleTapZoomScale;
    
    if (_imageView) {
        [self setMaxMinZoomScalesForCurrentBounds];
    }
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (_firstTimeZoomBlock && (self.zoomScale > self.minimumZoomScale)) {
        _firstTimeZoomBlock(self);
        _firstTimeZoomBlock = nil;
    }
    
    [self centerScrollViewContentsWithView:_imageView];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if (_didZoomBlock) {
        _didZoomBlock(self, scrollView.zoomScale);
    }
}

- (void)setMaxMinZoomScalesForCurrentBounds {
    // calculate min/max zoomscale
    CGFloat xScale = self.bounds.size.width  / _imageSize.width;
    CGFloat yScale = self.bounds.size.height / _imageSize.height;
    self.minimumZoomScale = MIN(xScale, yScale);
    if (_isDisableZoom) {
        self.maximumZoomScale = _middleZoomScale = self.minimumZoomScale;
    }
    else {
        _middleZoomScale = (_zoomOption == PAImageScrollViewZoomOptionLinear) ? (self.minimumZoomScale * _doubleTapZoomScale) : MAX(xScale, yScale);
        self.maximumZoomScale = _middleZoomScale * _doubleTapZoomScale;
    }
}

#pragma mark - Rotation support
- (void)prepareToResize {
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _pointToCenterAfterResize = [self convertPoint:boundsCenter toView:_imageView];
    _scaleToRestoreAfterResize = self.zoomScale;
    
    // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
    // allowable scale when the scale is restored.
    if (_scaleToRestoreAfterResize <= self.minimumZoomScale + FLT_EPSILON) {
        _scaleToRestoreAfterResize = 0;
    }
}

- (void)recoverFromResizing {
    [self setMaxMinZoomScalesForCurrentBounds];
    
    // Step 1: restore zoom scale, first making sure it is within the allowable range.
    self.zoomScale = MIN(self.maximumZoomScale, MAX(self.minimumZoomScale, _scaleToRestoreAfterResize));
    
    // Step 2: restore center point, first making sure it is within the allowable range.
    
    // 2a: convert our desired center point back to our own coordinate space
    CGPoint boundsCenter = [self convertPoint:_pointToCenterAfterResize fromView:_imageView];
    
    // 2b: calculate the content offset that would yield that center point
    CGPoint offset = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0,
                                 boundsCenter.y - self.bounds.size.height / 2.0);
    
    // 2c: restore offset, adjusted to be within the allowable range
    CGPoint maxOffset = [self maximumContentOffset];
    offset.x = MAX(0, MIN(maxOffset.x, offset.x));
    offset.y = MAX(0, MIN(maxOffset.y, offset.y));
    self.contentOffset = offset;
}

- (CGPoint)maximumContentOffset {
    CGSize contentSize = self.contentSize;
    CGSize size = self.bounds.size;
    return CGPointMake(contentSize.width - size.width, contentSize.height - size.height);
}

#pragma mark Gesture
- (void)handleSingleTap:(UIGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded){
        [self performSelector:@selector(singleTap) withObject:nil afterDelay:0.4f];
    }
}

- (void)singleTap {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    if (_didSingleTapBlock) {
        _didSingleTapBlock(self);
    }
}

- (void)handleDoubleTap:(UIGestureRecognizer *)sender {
    if (_isDisableZoom) {
        return;
    }
    
    if (sender.state == UIGestureRecognizerStateEnded){
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        
        if (fabs(self.zoomScale - _middleZoomScale) < FLT_EPSILON) {
            CGPoint center = [sender locationInView:_imageView];
            CGFloat scale = self.maximumZoomScale;
            CGRect zoomRect = [self zoomRectForScrollView:self withScale:scale withCenter:center];
            [self zoomToRect:zoomRect animated:YES];
            if (_didDoubleTapBlock) {
                _didDoubleTapBlock(self, scale);
            }
        }
        else if (self.zoomScale > self.minimumZoomScale) {
            [self setZoomScale:self.minimumZoomScale animated:YES];
            if (_didDoubleTapBlock) {
                _didDoubleTapBlock(self, self.minimumZoomScale);
            }
        }
        else {
            bool justFillImage = fabs(self.minimumZoomScale - _middleZoomScale) < 0.01;
            CGPoint center = [sender locationInView:_imageView];
            CGFloat scale = justFillImage ? self.maximumZoomScale : _middleZoomScale;
            CGRect zoomRect = [self zoomRectForScrollView:self withScale:scale withCenter:center];
            [self zoomToRect:zoomRect animated:YES];
            if (_didDoubleTapBlock) {
                _didDoubleTapBlock(self, scale);
            }
        }
    }
}

- (CGRect)zoomRectForScrollView:(UIScrollView *)scrollView withScale:(double)scale withCenter:(CGPoint)center {
    CGRect zoomRect;
    zoomRect.size.height = scrollView.frame.size.height / scale;
    zoomRect.size.width  = scrollView.frame.size.width / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

@end
