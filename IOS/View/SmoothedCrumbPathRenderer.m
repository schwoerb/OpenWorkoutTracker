// Created by OpenWorkoutTracker on 2025-08-27.
// Copyright (c) 2025 Michael J. Simms. All rights reserved.

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

#import "SmoothedCrumbPathRenderer.h"
#import "CrumbPath.h"

@interface SmoothedCrumbPathRenderer (FileInternal)
- (CGPathRef)newSmoothedPathForPoints:(MKMapPoint*)points pointCount:(NSUInteger)pointCount clipRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale;
- (CGPoint)calculateControlPoint1:(CGPoint)p0 p1:(CGPoint)p1 p2:(CGPoint)p2 smoothing:(CGFloat)smoothing;
- (CGPoint)calculateControlPoint2:(CGPoint)p0 p1:(CGPoint)p1 p2:(CGPoint)p2 smoothing:(CGFloat)smoothing;
@end

@implementation SmoothedCrumbPathRenderer

- (id)init
{
    self = [super init];
    if (self) {
        self.smoothingFactor = 0.3f; // Default smoothing factor
    }
    return self;
}

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context
{
    CrumbPath* crumbs = (CrumbPath*)(self.overlay);
    if (crumbs)
    {
        CGFloat lineWidth = MKRoadWidthAtZoomScale(zoomScale);

        // outset the map rect by the line width so that points just outside
        // of the currently drawn rect are included in the generated path.
        MKMapRect clipRect = MKMapRectInset(mapRect, -lineWidth, -lineWidth);

        [crumbs lockForReading];
        CGPathRef path = [self newSmoothedPathForPoints:crumbs.points pointCount:crumbs.pointCount clipRect:clipRect zoomScale:zoomScale];
        [crumbs unlockForReading];

        if (path != nil)
        {
            CGFloat red = 0;
            CGFloat green = 0;
            CGFloat blue = 1.0;
            CGFloat alpha = 0;
            
            if (self->color)
            {
                [self->color getRed:&red green:&green blue:&blue alpha:&alpha];
            }

            CGContextAddPath(context, path);
            CGContextSetRGBStrokeColor(context, red, green, blue, 0.5f);
            CGContextSetLineJoin(context, kCGLineJoinRound);
            CGContextSetLineCap(context, kCGLineCapRound);
            CGContextSetLineWidth(context, lineWidth);
            CGContextStrokePath(context);
            CGPathRelease(path);
        }
    }
}

@end

@implementation SmoothedCrumbPathRenderer (FileInternal)

static BOOL lineIntersectsRect(MKMapPoint p0, MKMapPoint p1, MKMapRect r)
{
    double minX = MIN(p0.x, p1.x);
    double minY = MIN(p0.y, p1.y);
    double maxX = MAX(p0.x, p1.x);
    double maxY = MAX(p0.y, p1.y);

    MKMapRect r2 = MKMapRectMake(minX, minY, maxX - minX, maxY - minY);
    return MKMapRectIntersectsRect(r, r2);
}

#define MIN_POINT_DELTA 5.0

- (CGPathRef)newSmoothedPathForPoints:(MKMapPoint*)points pointCount:(NSUInteger)pointCount clipRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale
{
    if (pointCount < 2)
        return NULL;

    CGMutablePathRef path = NULL;
    BOOL needsMove = YES;

#define POW2(a) ((a) * (a))
    
    // Calculate the minimum distance between any two points by figuring out
    // how many map points correspond to MIN_POINT_DELTA of screen points
    // at the current zoomScale.
    double minPointDelta = MIN_POINT_DELTA / zoomScale;
    double c2 = POW2(minPointDelta);

    // Convert all points to screen coordinates first, filtering out points that are too close
    NSMutableArray* screenPoints = [[NSMutableArray alloc] init];
    MKMapPoint lastPoint = points[0];
    
    // Always add the first point
    CGPoint firstScreenPoint = [self pointForMapPoint:points[0]];
    [screenPoints addObject:[NSValue valueWithBytes:&firstScreenPoint objCType:@encode(CGPoint)]];
    
    for (NSUInteger i = 1; i < pointCount; i++)
    {
        MKMapPoint point = points[i];
        double a2b2 = POW2(point.x - lastPoint.x) + POW2(point.y - lastPoint.y);
        
        if (a2b2 >= c2 && lineIntersectsRect(point, lastPoint, mapRect))
        {
            CGPoint screenPoint = [self pointForMapPoint:point];
            [screenPoints addObject:[NSValue valueWithBytes:&screenPoint objCType:@encode(CGPoint)]];
            lastPoint = point;
        }
    }

    NSUInteger screenPointCount = [screenPoints count];
    if (screenPointCount < 2)
        return NULL;

    path = CGPathCreateMutable();
    
    // Get the first point
    CGPoint p0;
    [[screenPoints objectAtIndex:0] getValue:&p0];
    CGPathMoveToPoint(path, NULL, p0.x, p0.y);
    
    if (screenPointCount == 2)
    {
        // Only two points, draw a straight line
        CGPoint p1;
        [[screenPoints objectAtIndex:1] getValue:&p1];
        CGPathAddLineToPoint(path, NULL, p1.x, p1.y);
    }
    else if (screenPointCount == 3)
    {
        // Three points, draw a quadratic curve
        CGPoint p1, p2;
        [[screenPoints objectAtIndex:1] getValue:&p1];
        [[screenPoints objectAtIndex:2] getValue:&p2];
        CGPathAddQuadCurveToPoint(path, NULL, p1.x, p1.y, p2.x, p2.y);
    }
    else
    {
        // Four or more points, use cubic Bezier curves
        for (NSUInteger i = 1; i < screenPointCount - 1; i++)
        {
            CGPoint currentPoint, nextPoint, prevPoint, nextNextPoint;
            [[screenPoints objectAtIndex:i] getValue:&currentPoint];
            [[screenPoints objectAtIndex:i+1] getValue:&nextPoint];
            
            // Calculate control points for smooth curve
            [[screenPoints objectAtIndex:i-1] getValue:&prevPoint];
            if (i+2 < screenPointCount) {
                [[screenPoints objectAtIndex:i+2] getValue:&nextNextPoint];
            } else {
                nextNextPoint = nextPoint;
            }
            
            CGPoint cp1 = [self calculateControlPoint1:prevPoint p1:currentPoint p2:nextPoint smoothing:self.smoothingFactor];
            CGPoint cp2 = [self calculateControlPoint2:currentPoint p1:nextPoint p2:nextNextPoint smoothing:self.smoothingFactor];
            
            CGPathAddCurveToPoint(path, NULL, cp1.x, cp1.y, cp2.x, cp2.y, nextPoint.x, nextPoint.y);
        }
        
        // Add the final point if we haven't reached it yet
        if (screenPointCount > 3)
        {
            CGPoint lastPoint;
            [[screenPoints objectAtIndex:screenPointCount-1] getValue:&lastPoint];
            CGPathAddLineToPoint(path, NULL, lastPoint.x, lastPoint.y);
        }
    }

#undef POW2
    
    return path;
}

- (CGPoint)calculateControlPoint1:(CGPoint)p0 p1:(CGPoint)p1 p2:(CGPoint)p2 smoothing:(CGFloat)smoothing
{
    // Calculate the direction vector from p0 to p2
    CGFloat dx = p2.x - p0.x;
    CGFloat dy = p2.y - p0.y;
    
    // Calculate the distance from p1 to the line p0-p2
    CGFloat length = sqrt(dx * dx + dy * dy);
    if (length < 1.0) {
        return p1; // Points are too close, no smoothing needed
    }
    
    // Normalize the direction vector
    dx /= length;
    dy /= length;
    
    // Calculate control point offset
    CGFloat offset = length * smoothing * 0.25f;
    
    return CGPointMake(p1.x + dx * offset, p1.y + dy * offset);
}

- (CGPoint)calculateControlPoint2:(CGPoint)p0 p1:(CGPoint)p1 p2:(CGPoint)p2 smoothing:(CGFloat)smoothing
{
    // Calculate the direction vector from p0 to p2
    CGFloat dx = p2.x - p0.x;
    CGFloat dy = p2.y - p0.y;
    
    // Calculate the distance from p1 to the line p0-p2
    CGFloat length = sqrt(dx * dx + dy * dy);
    if (length < 1.0) {
        return p1; // Points are too close, no smoothing needed
    }
    
    // Normalize the direction vector
    dx /= length;
    dy /= length;
    
    // Calculate control point offset (in opposite direction from cp1)
    CGFloat offset = length * smoothing * 0.25f;
    
    return CGPointMake(p1.x - dx * offset, p1.y - dy * offset);
}

@end
