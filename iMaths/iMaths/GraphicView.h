//
//  GraphicView.h
//  iMaths
//
//  Created by Luis Blazquez Miñambres on 20/10/18.
//  Copyright © 2018 Luis Blazquez Miñambres. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Controller;

@interface GraphicView : NSView
{
    IBOutlet __weak Controller *controller;
    bool mouseInBounds, trackingBoundsHit;
    NSRect originalBoundsView, newBoundsView;
    NSSize scaleSize;
    BOOL graphicIsZoomed;
    BOOL mouseDraggedFlag;
    NSPoint quadrantDragged;
    BOOL trackingCloseBoxHit, mouseInCloseBox;
    NSPoint a, c;
    float width, height;
}

-(void) resetScaling;


@end
