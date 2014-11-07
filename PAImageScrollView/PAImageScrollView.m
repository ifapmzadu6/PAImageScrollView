//
//  PAImageScrollView.m
//  PicasaWebAlbum
//
//  Created by Keisuke Karijuku on 2014/05/08.
//  Copyright (c) 2014年 Keisuke Karijuku. All rights reserved.
//

#import "PAImageScrollView.h"

const CGFloat defaultZoomScale = 3.0;
const PAImageScrollViewZoomOption defaultPAImageScrollViewZoomOption = PAImageScrollViewZoomOptionLinear;

@interface PAImageScrollView () <UIScrollViewDelegate>

@property (nonatomic) CGPoint pointToCenterAfterResize;
@property (nonatomic) CGFloat scaleToRestoreAfterResize;
@property (nonatomic) CGSize imageSize;

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
    self.doubleTapZoomScale = defaultZoomScale;
    
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTapGesture.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleTapGesture];
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTapGesture];
    
    _zoomOption = defaultPAImageScrollViewZoomOption;
    _imageViewClass = UIImageView.class;
}

- (void)centerScrollViewContentsWithView:(UIView *)view {
    // center the zoom view as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = view.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2.0;
    else
        frameToCenter.origin.x = 0.0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2.0;
    else
        frameToCenter.origin.y = 0.0;
    
    view.frame = frameToCenter;
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
- (void)setImage:(UIImage *)image {
    [self setImage:image resetImageView:false];
}

- (void)setImage:(UIImage *)image resetImageView:(BOOL)isReset
{
    if (!image) {
        return;
    }
    
    if (!isReset) {
        if (_imageView) {
            _imageView.image = image;
            return;
        }
    }
    
    if (_imageView) {
        [_imageView removeFromSuperview];
        _imageView = nil;
    }
    
    double imageWidth = image.size.width;
    double imageHeight = image.size.height;
    double width = CGRectGetWidth(self.bounds);
    double height = CGRectGetHeight(self.bounds);
    if (width > height) {
        imageHeight = imageHeight * width / imageWidth;
        imageWidth = width;
    }
    else {
        imageWidth = imageWidth * height / imageHeight;
        imageHeight = height;
    }
    _imageSize = CGSizeMake(imageWidth, imageHeight);
    
    _imageView = [[_imageViewClass alloc] initWithFrame:(CGRect){CGPointZero, _imageSize}];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.image = image;
    [self addSubview:_imageView];
    
    self.contentSize = _imageSize;
    [self setMaxMinZoomScalesForCurrentBounds];
    self.zoomScale = self.minimumZoomScale;
    
    [self centerScrollViewContentsWithView:_imageView];
}

- (UIImage *)image {
    return _imageView.image;
}

- (void)setIsDisableZoom:(BOOL)isDisableZoom {
    _isDisableZoom = isDisableZoom;
    
    if (isDisableZoom) {
        self.maximumZoomScale = self.minimumZoomScale;
    }
}

- (void)setZoomOption:(PAImageScrollViewZoomOption)zoomOption
{
    if (_zoomOption == zoomOption) {
        return;
    }
    
    _zoomOption = zoomOption;
    if (_imageView) {
        [self setMaxMinZoomScalesForCurrentBounds];
    }
}

- (void)setDoubleTapZoomScale:(CGFloat)doubleTapZoomScale
{
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

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    if (_didZoomBlock) {
        _didZoomBlock(self, scrollView.zoomScale);
    }
}

- (void)setMaxMinZoomScalesForCurrentBounds {
    CGSize boundsSize = self.bounds.size;
    
    // calculate min/max zoomscale
    CGFloat xScale = boundsSize.width  / _imageSize.width;
    CGFloat yScale = boundsSize.height / _imageSize.height;
    CGFloat minScale = MIN(xScale, yScale);
    CGFloat fillScale = MAX(xScale, yScale);
    
    self.minimumZoomScale = minScale;
    self.middleZoomScale  = self.zoomOption == PAImageScrollViewZoomOptionLinear ? (self.minimumZoomScale*_doubleTapZoomScale) : fillScale;
    self.maximumZoomScale = _middleZoomScale*_doubleTapZoomScale;

    if (_isDisableZoom) {
        self.maximumZoomScale = _middleZoomScale = self.minimumZoomScale;
    }
}

#pragma mark - Rotation support

- (void)prepareToResize {
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _pointToCenterAfterResize = [self convertPoint:boundsCenter toView:_imageView];
    
    _scaleToRestoreAfterResize = self.zoomScale;
    
    // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
    // allowable scale when the scale is restored.
    if (_scaleToRestoreAfterResize <= self.minimumZoomScale + FLT_EPSILON)
        _scaleToRestoreAfterResize = 0;
}

- (void)recoverFromResizing {
    [self setMaxMinZoomScalesForCurrentBounds];
    
    // Step 1: restore zoom scale, first making sure it is within the allowable range.
    CGFloat maxZoomScale = MAX(self.minimumZoomScale, _scaleToRestoreAfterResize);
    self.zoomScale = MIN(self.maximumZoomScale, maxZoomScale);
    
    // Step 2: restore center point, first making sure it is within the allowable range.
    
    // 2a: convert our desired center point back to our own coordinate space
    CGPoint boundsCenter = [self convertPoint:_pointToCenterAfterResize fromView:_imageView];
    
    // 2b: calculate the content offset that would yield that center point
    CGPoint offset = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0,
                                 boundsCenter.y - self.bounds.size.height / 2.0);
    
    // 2c: restore offset, adjusted to be within the allowable range
    CGPoint maxOffset = [self maximumContentOffset];
    CGPoint minOffset = [self minimumContentOffset];
    
    CGFloat realMaxOffset = MIN(maxOffset.x, offset.x);
    offset.x = MAX(minOffset.x, realMaxOffset);
    
    realMaxOffset = MIN(maxOffset.y, offset.y);
    offset.y = MAX(minOffset.y, realMaxOffset);
    
    self.contentOffset = offset;
}

- (CGPoint)maximumContentOffset {
    CGSize contentSize = self.contentSize;
    CGSize boundsSize = self.bounds.size;
    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset {
    return CGPointZero;
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
        
        if (fabs(self.zoomScale - self.middleZoomScale) < FLT_EPSILON) {
            CGPoint center = [sender locationInView:_imageView];
            CGFloat scale = self.maximumZoomScale;
            CGRect zoomRect = [self zoomRectForScrollView:self
                                                withScale:scale
                                               withCenter:center];
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
        } else {
            bool justFillImage = fabs(self.minimumZoomScale-self.middleZoomScale) < 0.01;
            CGPoint center = [sender locationInView:_imageView];
            CGFloat scale = justFillImage ? self.maximumZoomScale : self.middleZoomScale;
            CGRect zoomRect = [self zoomRectForScrollView:self
                                                withScale:scale
                                               withCenter:center];
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
    zoomRect.size.width  = scrollView.frame.size.width  / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

@end
