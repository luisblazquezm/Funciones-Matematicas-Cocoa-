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
    
    /* Variables globales a la clase */

    // Flags
    BOOL graphicIsZoomed; // Indica si se va a hacer zoom o no sobre la vista
    BOOL mouseDraggedFlag; // Indica si se ha hecho una selección sobre la vista (acción de zoom sobre la vista)
    BOOL graphicIsMoved;
    
    // Variables que indican los puntos de la vista para hacer zoom
    NSPoint a, c, clickInView;
    float width, height;
    
    NSColor *colorAxis;
    NSBezierPath *funcBezier;
    NSBezierPath *axisXBezier, *axisYBezier;
    NSBezierPath *pointsAxisXBezier, *pointsAxisYBezier;
    float zoomQuant;
}

-(void) drawAxisAndPoints;
-(void) restoreView:(BOOL)flag;

@end
