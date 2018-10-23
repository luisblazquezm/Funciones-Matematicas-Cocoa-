//
//  GraphicView.m
//  iMaths
//
//  Created by Luis Blazquez Miñambres on 20/10/18.
//  Copyright © 2018 Luis Blazquez Miñambres. All rights reserved.
//

#import "GraphicView.h"
#import "GraphicsClass.h"
static const NSSize unitSize = {1.0, 1.0};
static const int zoom = 20;

@implementation GraphicView

extern NSString *PanelExportAndDrawGraphicsNotification;

-(id) initWithCoder:(NSCoder *)decoder
{
    NSLog(@"En init with coder");
    self = [super initWithCoder:decoder];
    if (self) {
        mouseInBounds = NO;
        trackingBoundsHit = NO;
        originalBoundsView = [self bounds];
        scaleSize.width = 1.0;
        scaleSize.height = 1.0;
        graphicIsZoomed = NO;

    }
    return self;
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here
    NSLog(@"En drawRect");
    NSRect bounds=[self bounds];
    [[NSColor whiteColor]set];
    [NSBezierPath fillRect:bounds];
    NSGraphicsContext *ctx=[NSGraphicsContext currentContext];
    NSInteger origenX=bounds.origin.x;
    NSInteger origenY=bounds.origin.y;
    float altura=bounds.size.height;
    float ancho=bounds.size.width;
    NSNumber *oX = [[NSNumber alloc]initWithInteger:origenX];
    NSNumber *oY = [[NSNumber alloc]initWithInteger:origenY];
    NSNumber *alt = [[NSNumber alloc]initWithFloat:altura];
    NSNumber *anch = [[NSNumber alloc]initWithFloat:ancho];
    NSNumber *zoom = [[NSNumber alloc]initWithBool:graphicIsZoomed];

    NSDictionary *info=[NSDictionary dictionaryWithObjectsAndKeys:
                        ctx,@"ContextoGrafico",
                        oX,@"OrigenX",
                        oY,@"OrigenY",
                        alt,@"Altura",
                        anch,@"Ancho",
                        zoom,@"graphicIsZoomed",
                        nil];
    NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
    [nc postNotificationName:PanelExportAndDrawGraphicsNotification object:self userInfo:info];
}

// mouseDown y luego (if delegateRespondsto.) se lo paso al delegate processMouseDown inBounds
// mouseDragged seleccionas un area con el boton izquierdo y hace zoom
// Matriz de transferencia en estos metodos
// if(trackingMouse){ // el codigo //}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSLog(@"En mouseDragged");


    mouseDraggedFlag = YES;
    
}

- (void)resetScaling;
{
    [self scaleUnitSquareToSize:[self convertSize:unitSize fromView:nil]];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    if (mouseDraggedFlag){
/* Dibujar los puntos de las graficas*/

        
        NSLog(@"Coordenadas Antes: X: %f Y: %f WIDTH: %f HEIGHT: %f",newBoundsView.origin.x
              ,newBoundsView.origin.y, newBoundsView.size.width, newBoundsView.size.height);
        
        newBoundsView = [self bounds];
        
        newBoundsView.origin.x += zoom;
        newBoundsView.origin.y += zoom;
        
        NSLog(@"Coordenadas Despues: X: %f Y: %f WIDTH: %f HEIGHT: %f",newBoundsView.origin.x
              ,newBoundsView.origin.y, newBoundsView.size.width, newBoundsView.size.height);
        [self setBoundsOrigin:newBoundsView.origin];
        graphicIsZoomed = YES;
    }
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSLog(@"En mouseDown");
    
        mouseDraggedFlag = NO;
}



@end
