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
    
    /* Variables de instancia */

    NSPoint startPoint, endPoint, clickInView;
    NSColor *colorAxis;
    NSBezierPath *funcBezier, *axisXBezier, *axisYBezier, *pointsAxisXBezier, *pointsAxisYBezier;
    float zoomQuant, zoomCoordenateX, zoomCoordenateY;
    BOOL graphicIsZoomed, mouseDraggedFlag, graphicIsMoved;// * Flags *
}

-(void) drawAxisAndPoints;
-(void) restoreView:(BOOL)flag;

@end
