//
//  GraphicView.m
//  iMaths
//
//  Created by Luis Blazquez Miñambres on 20/10/18.
//  Copyright © 2018 Luis Blazquez Miñambres. All rights reserved.
//

#import "GraphicView.h"
#import "GraphicsClass.h"
//static const NSSize unitSize = {1.0, 1.0};
//static const int zoomValueX = 40;
//static const int zoomValueY = 40;

@implementation GraphicView

extern NSString *PanelExportAndDrawGraphicsNotification;
NSString *DrawRectCalledNotification = @"DrawRect";
NSString *ShowLegendNotification = @"ShowLeyend";

-(id) initWithCoder:(NSCoder *)decoder
{
    NSLog(@"En init with coder");
    self = [super initWithCoder:decoder];
    if (self) {
        originalBoundsView = [self bounds];
        graphicIsZoomed = NO;
        mouseDraggedFlag = NO;

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
    
    // Transformo las dimensiones numericas a NSNumber para poder pasarlas y enviarlas a traves de notificaciones
    NSNumber *oX = [[NSNumber alloc]initWithInteger:origenX];
    NSNumber *oY = [[NSNumber alloc]initWithInteger:origenY];
    NSNumber *alt = [[NSNumber alloc]initWithFloat:altura];
    NSNumber *anch = [[NSNumber alloc]initWithFloat:ancho];
    NSNumber *zoom = [[NSNumber alloc]initWithBool:graphicIsZoomed];
    NSNumber *w = [[NSNumber alloc]initWithFloat:width];
    NSNumber *h = [[NSNumber alloc]initWithFloat:height];

    NSDictionary *info=[NSDictionary dictionaryWithObjectsAndKeys: ctx,@"ContextoGrafico",
                                                                    oX,@"OrigenX",
                                                                    oY,@"OrigenY",
                                                                    alt,@"Altura",
                                                                    anch,@"Ancho",
                                                                    zoom,@"graphicIsZoomed",
                                                                    w,@"width",
                                                                    h,@"height",
                                                                    nil];
    NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
    [nc postNotificationName:DrawRectCalledNotification
                      object:self
                    userInfo:info];
}

// mouseDown y luego (if delegateRespondsto.) se lo paso al delegate processMouseDown inBounds
// mouseDragged seleccionas un area con el boton izquierdo y hace zoom
// Matriz de transferencia en estos metodos
// if(trackingMouse){ // el codigo //}

- (void)mouseDown:(NSEvent *)theEvent {
    a = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSRect bounds = [self frame];
    NSLog(@"A(X: %f Y: %f)   -    BOUNDS(X: %f Y: %f)",a.x, a.y, bounds.origin.x, bounds.origin.y);
    mouseDraggedFlag = NO;
    
    // Leyenda
    NSNumber *Xleyend = [[NSNumber alloc]initWithFloat:a.x];
    NSNumber *Yleyend = [[NSNumber alloc]initWithFloat:a.y];
    
    NSDictionary *info=[NSDictionary dictionaryWithObjectsAndKeys: Xleyend,@"LeyendaX",
                                                                   Yleyend,@"LeyendaY",
                                                                   nil];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:ShowLegendNotification
                      object:self
                    userInfo:info];
}

- (void)mouseDragged:(NSEvent *)theEvent {
    mouseDraggedFlag = YES;
}

- (void)mouseUp:(NSEvent *)theEvent {
    c = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSRect bounds = [self frame];
    NSLog(@"C(X: %f Y: %f)   -    BOUNDS(X: %f Y: %f)",c.x, c.y, bounds.origin.x, bounds.origin.y);
    
    if(mouseDraggedFlag){
        width = (c.x + a.x)/2;
        height = (c.y + a.y)/2;
        graphicIsZoomed = YES;
        [self setNeedsDisplay:YES];
    }


}

-(void)keyDown:(NSEvent *)event
{
    NSLog(@"Aqui");
    switch ([event keyCode]) {
        case 123:    // Left arrow
            NSLog(@"Left behind.");
            break;
        case 124:    // Right arrow
            NSLog(@"Right as always!");
            break;
        case 125:    // Down arrow
            NSLog(@"Downward is Heavenward");
            break;
        case 126:    // Up arrow
            NSLog(@"Up, up, and away!");
            break;
        default:
            break;
    }
}



@end
