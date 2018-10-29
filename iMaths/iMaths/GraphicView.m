//
//  GraphicView.m
//  iMaths
//
//  Created by Luis Blazquez Miñambres on 20/10/18.
//  Copyright © 2018 Luis Blazquez Miñambres. All rights reserved.
//

#import "GraphicView.h"
static const int zoom = 20;

@implementation GraphicView

extern NSString *PanelExportAndDrawGraphicsNotification;
NSString *DrawRectCalledNotification = @"DrawRect";
NSString *ShowLegendNotification = @"ShowLeyend";

-(id) initWithCoder:(NSCoder *)decoder
{
    NSLog(@"En init with coder (GraphicView)");
    self = [super initWithCoder:decoder];
    if (self) {
        graphicIsZoomed = NO;
        mouseDraggedFlag = NO;
        graphicIsMoved = NO;
    }
    return self;
}

/*!
 * @brief  Metodo llamado cada vez que se pretende redibujar la vista, manda toda la información de las
 *         dimensiones de la vista al controlador
 * @param  dirtyRect Rectangulo de la vista a dibujar.
 */
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
    NSNumber *move = [[NSNumber alloc]initWithBool:graphicIsMoved];
    NSNumber *w = [[NSNumber alloc]initWithFloat:width];
    NSNumber *h = [[NSNumber alloc]initWithFloat:height];

    NSDictionary *info=[NSDictionary dictionaryWithObjectsAndKeys: ctx,@"ContextoGrafico",
                                                                    oX,@"OrigenX",
                                                                    oY,@"OrigenY",
                                                                    alt,@"Altura",
                                                                    anch,@"Ancho",
                                                                    zoom,@"graphicIsZoomed",
                                                                    move,@"graphicIsMoved",
                                                                    w,@"width",
                                                                    h,@"height",
                                                                    nil];
    NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
    [nc postNotificationName:DrawRectCalledNotification
                      object:self
                    userInfo:info];
}

/*!
 * @brief  Evento de raton que se llama cada vez que el usuario pulso el botón izquierdo del ratón sobre la
 *         vista.
 */
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

/*!
 * @brief  Evento de raton que se llama cada vez que el usuario arrastra con el botón izquierdo del ratón
 *         sobre la vista.
 */
- (void)mouseDragged:(NSEvent *)theEvent {
    mouseDraggedFlag = YES;
}

/*!
 * @brief  Evento de raton que se llama cada vez que el usuario suelta el botón izquierdo del ratón tras
 *         haber pulsado.
 */
- (void)mouseUp:(NSEvent *)theEvent {
    c = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSRect bounds = [self bounds];
    NSLog(@"C(X: %f Y: %f)   -    BOUNDS(X: %f Y: %f)",c.x, c.y, bounds.origin.x, bounds.origin.y);
    
    // Nos aseguramos de que solo se haga zooom sobre esa zona si se ha arrastrado antes.
    if(mouseDraggedFlag){
        // Width y height representan las coordenadas X e Y del punto medio o central del rectangulo que se ha creado al arrastar el usuario por la vista, y serán el nuevo origen de coordenadas al que se trasladará la matriz de transformación afín para representar la acción de hacer zoom.
        width = (c.x + a.x)/2;
        height = (c.y + a.y)/2;
        graphicIsZoomed = YES;
        graphicIsMoved = NO;
        [self setNeedsDisplay:YES];
    }


}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

-(void)keyDown:(NSEvent *)event
{
    NSRect newBounds = [self bounds];
    switch ([event keyCode]) {
        case 123:    // Left arrow
            newBounds.origin.x -= zoom;
            NSLog(@"Left behind.");
            break;
        case 124:    // Right arrow
            newBounds.origin.x += zoom;
            NSLog(@"Right as always!");
            break;
        case 125:    // Down arrow
            newBounds.origin.y -= zoom;
            NSLog(@"Downward is Heavenward");
            break;
        case 126:    // Up arrow
            newBounds.origin.y += zoom;
            NSLog(@"Up, up, and away!");
            break;
        default:
            break;
    }
    graphicIsMoved = YES;
    [self setBoundsOrigin:newBounds.origin];
}



@end
