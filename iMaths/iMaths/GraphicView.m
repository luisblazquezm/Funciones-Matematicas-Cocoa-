//
//  GraphicView.m
//  iMaths
//
//  Created by Luis Blazquez Miñambres on 20/10/18.
//  Copyright © 2018 Luis Blazquez Miñambres. All rights reserved.
//

#import "GraphicView.h"
#define RANDFLOAT() (random()%128/128.0)
#define HOPS (500) // Numero de puntos
#define WIDTH (20)
static const int zoom = 20;
static NSRect funcRect = {-10, -10, 20 ,20}; 

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
        
        funcBezier = [[NSBezierPath alloc] init];
        axisXBezier = [[NSBezierPath alloc] init];
        axisYBezier = [[NSBezierPath alloc] init];
        pointsAxisXBezier = [[NSBezierPath alloc] init];
        pointsAxisYBezier = [[NSBezierPath alloc] init];
        colorAxis  = [NSColor blackColor];
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
    NSNumber *z = [[NSNumber alloc]initWithFloat:graphicIsZoomed];
    NSNumber *move = [[NSNumber alloc]initWithFloat:graphicIsMoved];
    NSNumber *w = [[NSNumber alloc]initWithFloat:width];
    NSNumber *h = [[NSNumber alloc]initWithFloat:height];

    NSDictionary *info=[NSDictionary dictionaryWithObjectsAndKeys: ctx,@"ContextoGrafico",
                                                                    oX,@"OrigenX",
                                                                    oY,@"OrigenY",
                                                                    alt,@"Altura",
                                                                    anch,@"Ancho",
                                                                    z,@"graphicIsZoomed",
                                                                    move,@"graphicIsMoved",
                                                                    w,@"width",
                                                                    h,@"height",
                                                                    nil];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:DrawRectCalledNotification
                      object:self
                    userInfo:info];
}

- (BOOL)isFlipped {
    return YES;
}

-(void) restoreView:(BOOL)flag
{
    NSRect newBounds = [self bounds];
    if (flag) {
        NSLog(@"Zoom y Bounds restaurados");
        graphicIsZoomed = NO;
        newBounds.origin.x = 0;
        newBounds.origin.y = 0;
        [self setBoundsOrigin:newBounds.origin];
    } else {
        graphicIsZoomed = YES;
    }
}


-(void) drawAxisAndPoints
{
    NSPoint aPoint;
    int counter = 0;
    NSRect b = [self bounds];
    float lineWidth = 0.1;   // Anchura de los ejes al dibujar
    float spacePoints = 0.3; // Espacio entre las barras de los ejes
    float distance = funcRect.size.width/HOPS;

    NSGraphicsContext *ctx = [NSGraphicsContext currentContext];

    
    [ctx saveGraphicsState]; //------------------- Contexto gráfico

        if (!graphicIsZoomed){
            zoomQuant = 0;
            
            NSLog(@"Matriz de tranformación afin creada");
            NSAffineTransform *tf = [NSAffineTransform transform];
            tf = [NSAffineTransform transform];
            // 2º Mult* por la matriz de Transformación Afín (Coloca la x e y en el (0,0) con respecto a la grafica
            [tf translateXBy:b.size.width/2
                         yBy:b.size.height/2];
            // 1º Ancho y Alto / Escala (funcRect)
            [tf scaleXBy:b.size.width/funcRect.size.width
                     yBy:b.size.height/funcRect.size.height];
            [tf concat];
            
        // Si se realiza ZOOM sobre la vista
        } else {
            if (!graphicIsMoved)
                zoomQuant += 0.1;
            
            NSLog(@"Matriz de tranformación afin de ZOOM creada");
            NSAffineTransform *tfZoom = [NSAffineTransform transform];
            NSLog(@"Punto x: %f Punto y: %f ZoomQuant: %f", width, height, zoomQuant);
            [tfZoom translateXBy:width
                             yBy:height];
            [tfZoom scaleXBy:width*zoomQuant
                         yBy:height*zoomQuant];
            [tfZoom concat];
            
        }
    
    
        NSLog(@"Bounds Depsues: X: %f Y: %f W: %f H: %f", b.origin.x, b.origin.y, b.size.width, b.size.height);
    
        /* -------------- Dibujo de los ejes --------------- */
    
        // * EJE X *
    
        [axisXBezier setLineWidth:lineWidth];
        [colorAxis setStroke];
    
        aPoint.x = funcRect.origin.x;
        aPoint.y = 0;
    
        [axisXBezier moveToPoint:aPoint];
        while (aPoint.x <= funcRect.size.width + b.size.width) {
            //NSLog(@"Point: %f %f", aPoint.x, aPoint.y);
            aPoint.y = 0;
            [axisXBezier lineToPoint:aPoint];
            aPoint.x += distance;
        }
    
        [axisXBezier stroke];
    
        // * EJE Y *
    
        [axisYBezier setLineWidth:lineWidth];
        [colorAxis setStroke];
    
        // Comienza en el punto minimo de Y (abajo) y dibuja la raya hasta el punto maximo (la altura)
        aPoint.x = 0;
        aPoint.y = funcRect.origin.y;
    
        [axisYBezier moveToPoint:aPoint];
        while (aPoint.y <= funcRect.size.height + b.size.height) {
            //NSLog(@"Point: %f %f", aPoint.x, aPoint.y);
            aPoint.x = 0;
            [axisYBezier lineToPoint:aPoint];
            aPoint.y += distance;
        }
    
        [axisYBezier stroke];
    
        /* -------------- Dibujo de los puntos de los ejes --------------- */
    
        // * EJE X (POSITIVO) *
    
        [pointsAxisXBezier setLineWidth:lineWidth];
        [colorAxis setStroke];
    
        aPoint.x = 0;
        aPoint.y = 0.3;
        // Si lo hago desde el punto x minimo hasta el punto x maximo (anchura) se mueven los ejes al redimensionar la ventana
        // Por eso hago la primera mitad positiva y luego la negativa de x e y
        [pointsAxisXBezier moveToPoint:aPoint];
    
        while (aPoint.x <= funcRect.size.width + (b.size.width/2))  { // aPoint.y = 0.3 => -0.3
            counter++;
            //NSLog(@"PointPositivo: %f %f %f", aPoint.x, aPoint.y,(b.size.width/2) );
            aPoint.x += spacePoints;
            aPoint.y = 0;
            [pointsAxisXBezier moveToPoint:aPoint];
            if (counter == 5) {
                aPoint.y = 0.6;
                [pointsAxisXBezier lineToPoint:aPoint];
                aPoint.y = -0.6;
                [pointsAxisXBezier lineToPoint:aPoint];
                counter = 0;
            } else {
                aPoint.y = 0.3;
                [pointsAxisXBezier lineToPoint:aPoint];
                aPoint.y = -0.3;
                [pointsAxisXBezier lineToPoint:aPoint];
            }
        }
    
        [pointsAxisXBezier stroke];
    
        // * EJE X (NEGATIVO) *
    
        [pointsAxisXBezier setLineWidth:lineWidth];
        [colorAxis setStroke];
    
        aPoint.x = 0;
        aPoint.y = 0.3;
        [pointsAxisXBezier moveToPoint:aPoint];
    
        counter = 0;
        while (aPoint.x >= (-(funcRect.size.width)) + (-(b.size.width/2)))  {
            counter++;
            //NSLog(@"PointNegativo: %f %f ", aPoint.x, aPoint.y);
            aPoint.x -= spacePoints;
            aPoint.y = 0;
            [pointsAxisXBezier moveToPoint:aPoint];
            
            if (counter == 5) {
                aPoint.y = 0.6;
                [pointsAxisXBezier lineToPoint:aPoint];
                aPoint.y = -0.6;
                [pointsAxisXBezier lineToPoint:aPoint];
                counter = 0;
            } else {
                aPoint.y = 0.3;
                [pointsAxisXBezier lineToPoint:aPoint];
                aPoint.y = -0.3;
                [pointsAxisXBezier lineToPoint:aPoint];
            }
        }
    
        [pointsAxisXBezier stroke];
    
        // * EJE Y (POSITIVO) *
    
        [pointsAxisYBezier setLineWidth:lineWidth];
        [colorAxis setStroke];
    
        aPoint.x = 0.3;
        aPoint.y = 0;
        [pointsAxisYBezier moveToPoint:aPoint];
    
        counter = 0;
        while (aPoint.y <= (funcRect.size.height) + (b.size.height/2))  { // aPoint.y = 0.3 => -0.3
            counter++;
            //NSLog(@"PointPositivoY: %f %f %f", aPoint.x, aPoint.y,(b.size.height/2) );
            aPoint.y += spacePoints;
            aPoint.x = 0;
            [pointsAxisYBezier moveToPoint:aPoint];
            if (counter == 5) {
                aPoint.x = 0.6;
                [pointsAxisYBezier lineToPoint:aPoint];
                aPoint.x = -0.6;
                [pointsAxisYBezier lineToPoint:aPoint];
                counter = 0;
            } else {
                aPoint.x = 0.3;
                [pointsAxisYBezier lineToPoint:aPoint];
                aPoint.x = -0.3;
                [pointsAxisYBezier lineToPoint:aPoint];
            }
        }
    
        [pointsAxisYBezier stroke];
    
        // * EJE Y (NEGATIVO) *
    
        [pointsAxisYBezier setLineWidth:lineWidth];
        [colorAxis setStroke];
    
        aPoint.x = 0.3;
        aPoint.y = 0;
        [pointsAxisYBezier moveToPoint:aPoint];
    
        counter = 0;
        while (aPoint.y >= (-(funcRect.size.height)) + (-(b.size.height/2)))  {
            counter++;
            //NSLog(@"PointNegativoY: %f %f %f", aPoint.x, aPoint.y,(b.size.height/2) );
            aPoint.y -= spacePoints;
            aPoint.x = 0;
            [pointsAxisYBezier moveToPoint:aPoint];
            
            if (counter == 5) {
                aPoint.x = 0.6;
                [pointsAxisYBezier lineToPoint:aPoint];
                aPoint.x = -0.6;
                [pointsAxisYBezier lineToPoint:aPoint];
                counter = 0;
            } else {
                aPoint.x = 0.3;
                [pointsAxisYBezier lineToPoint:aPoint];
                aPoint.x = -0.3;
                [pointsAxisYBezier lineToPoint:aPoint];
            }
        }
    
        [pointsAxisYBezier stroke];
    
    [ctx restoreGraphicsState]; //------------------- Contexto gráfico
}


/*!
 * @brief  Evento de raton que se llama cada vez que el usuario pulso el botón izquierdo del ratón sobre la
 *         vista.
 */
- (void)mouseDown:(NSEvent *)theEvent {
    a = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSPoint new;
    clickInView = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSRect bounds = [self bounds];
    NSLog(@"A(X: %f Y: %f)   -    BOUNDS(X: %f Y: %f)",a.x, a.y, bounds.origin.x, bounds.origin.y);
    mouseDraggedFlag = NO;
    
    NSAffineTransform *tf = [NSAffineTransform transform];
    tf = [NSAffineTransform transform];
    // 2º Mult* por la matriz de Transformación Afín (Coloca la x e y en el (0,0) con respecto a la grafica
    [tf translateXBy:bounds.size.width/2
                 yBy:bounds.size.height/2];
    // 1º Ancho y Alto / Escala (funcRect)
    [tf scaleXBy:bounds.size.width/funcRect.size.width
             yBy:bounds.size.height/funcRect.size.height];

    [tf invert];
    new = [tf transformPoint:clickInView];

    // Leyenda
    NSLog(@"Click in view X: %f Y: %f", new.x, new.y);
    NSNumber *Xleyend = [[NSNumber alloc]initWithFloat:new.x];
    NSNumber *Yleyend = [[NSNumber alloc]initWithFloat:new.y];
    
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
            newBounds.origin.y += zoom;
            NSLog(@"Downward is Heavenward");
            break;
        case 126:    // Up arrow
            newBounds.origin.y -= zoom;
            NSLog(@"Up, up, and away!");
            break;
        default:
            break;
    }
    graphicIsMoved = YES;
    
    NSLog(@"BOUNDS(X: %f Y: %f)", newBounds.origin.x, newBounds.origin.y);
    
    if (graphicIsZoomed)
        [self setBoundsOrigin:newBounds.origin];
}



@end
