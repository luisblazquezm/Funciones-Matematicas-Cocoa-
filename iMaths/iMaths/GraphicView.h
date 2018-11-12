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
    // Comunicación de la vista y el controlador a través de notificaciones
    //IBOutlet __weak Controller *controller;
    
    /* Variables de instancia */

    NSPoint startPoint, endPoint, clickInView;
    float zoomCoordenateX, zoomCoordenateY;
    BOOL graphicIsZoomed, mouseDraggedFlag, graphicIsMoved;// * Flags *
}

-(void) restoreView:(BOOL)flag;

@end
