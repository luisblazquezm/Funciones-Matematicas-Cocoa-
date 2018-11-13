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

                /* (GraphicView -> Controller) */

// Cuando se llama al metodo drawRect y se necesita redibujar el contenido de la vista
NSString *DrawRectCalledNotification = @"DrawRect";
// Cuando se necesita mostrar la información de la leyenda porque el usuario ha pulsado sobre la misma
NSString *ShowLegendNotification = @"ShowLegend";


/*!
 * @brief  Inicializador de la clase
 */
-(id) initWithCoder:(NSCoder *)decoder
{
    NSLog(@"En init with coder (GraphicView)");
    self = [super initWithCoder:decoder];
    if (self) {
        graphicIsZoomed = NO;
        mouseDraggedFlag = NO;
        graphicIsMoved = NO;
        flippedFlag = NO;
        zoomCoordenateX = 0;
        zoomCoordenateY = 0;
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
    NSNumber *w = [[NSNumber alloc]initWithFloat:zoomCoordenateX];
    NSNumber *h = [[NSNumber alloc]initWithFloat:zoomCoordenateY];

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

/*!
 * @brief  Indica si el sistema de coordenadas se ha volteado, en este caso devuelvo YES para indicar
 *         que el sistema de coordenadas está volteado y el origen de coordenadas ya no esta en la
 *         esquina inferior izquierda de la vista(return NO) sino que el origen está ahora en la
 *         esquina superior izquierda de la vista y los valores de y se extienden hacia abajo. Los
 *         valores X siempre se extienden hacia la derecha.
 *
 *         Utilizada para sacar la leyenda de la representación de la gráfica.
 * @return BOOL Devuelve si
 */
- (BOOL) isFlipped {
    if (flippedFlag)
        return YES;
    else
        return NO;
}

/*!
 * @brief  Método que se llama cada vez que , al haber hecho zoom, se desee volver al estado por
 *         defecto de la vista que se muestra al ejecutar por primera vez el programa (esto se hace
 *         recalculando el origen de coordenadas de la vista al original 0,0 en la esquina inferior
 *         izquierda.
 * @param  flag Indica si desde el controlador se pide restaurar el zoom de la vista
 */
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

/*!
 * @brief  Evento de raton que se llama cada vez que el usuario pulso el botón izquierdo del ratón
 *         sobre la vista.
 */
- (void)mouseDown:(NSEvent *)theEvent {
    NSPoint new;
    NSRect bounds = [self bounds];
    
    flippedFlag = YES;
    
    // Punto de la vista donde se pulsa con el botón izquierdo del ratón
    startPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    clickInView = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    mouseDraggedFlag = NO;
    
    NSLog(@"A(X: %f Y: %f)   -    BOUNDS(X: %f Y: %f)",startPoint.x, startPoint.y, bounds.origin.x, bounds.origin.y);
    
    // Se realiza la transformación afín de la vista que creamos para representar los ejes
    // pero la invertimos para conseguir las coordenadas x e y según el sistema de coordenadas
    // de la gráfica, no de la vista ni de la ventana; es decir toma el punto 0,0 en el medio
    // de la vista y no en la esquina inferior izquierda.
    NSAffineTransform *tf = [NSAffineTransform transform];
    tf = [NSAffineTransform transform];
    [tf translateXBy:bounds.size.width/2
                 yBy:bounds.size.height/2];
    [tf scaleXBy:bounds.size.width/funcRect.size.width
             yBy:bounds.size.height/funcRect.size.height];

    [tf invert];
    new = [tf transformPoint:clickInView];

    // Se envia al controlador las coordenadas invertidas
    NSLog(@"Click in view X: %f Y: %f", new.x, new.y);
    NSNumber *Xleyend = [[NSNumber alloc]initWithFloat:new.x];
    NSNumber *Yleyend = [[NSNumber alloc]initWithFloat:new.y];
    
    // Aviso al metodo isFlipped
    flippedFlag = NO;
    
    NSDictionary *info=[NSDictionary dictionaryWithObjectsAndKeys: Xleyend,@"LeyendaX",
                                                                   Yleyend,@"LeyendaY",
                                                                   nil];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:ShowLegendNotification
                      object:self
                    userInfo:info];
}

/*!
 * @brief  Evento de raton que se llama cada vez que el usuario arrastra con el botón izquierdo del
 *         ratón sobre la vista.
 */
- (void)mouseDragged:(NSEvent *)theEvent {
    mouseDraggedFlag = YES;
}

/*!
 * @brief  Evento de raton que se llama cada vez que el usuario suelta el botón izquierdo del ratón
 *         tras haber pulsado.
 */
- (void)mouseUp:(NSEvent *)theEvent {
    NSRect bounds = [self bounds];
    
    // Punto de la vista donde se suelta el botón izquierdo del ratón
    endPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    NSLog(@"C(X: %f Y: %f)   -    BOUNDS(X: %f Y: %f)",endPoint.x, endPoint.y, bounds.origin.x, bounds.origin.y);
    
    // Nos aseguramos de que solo se haga zooom sobre esa zona si se ha arrastrado antes.
    if(mouseDraggedFlag){
        // Width y height representan las coordenadas X e Y del punto medio o central del rectangulo que se ha creado al arrastar el usuario por la vista, y serán el nuevo origen de coordenadas al que se trasladará la matriz de transformación afín para representar la acción de hacer zoom.
        zoomCoordenateX = (endPoint.x + startPoint.x)/2;
        zoomCoordenateY = (endPoint.y + startPoint.y)/2;
        graphicIsZoomed = YES;
        graphicIsMoved = NO;
        [self setNeedsDisplay:YES];
    }


}

/*!
 * @brief  Indica si el receptor acepta el estado del primer respondedor, en nuestro caso,
 *         acepta los eventos de teclado como respuesta a la pulsación de una de las teclas
 *         del teclado (sirve para poder utilizar la propiedad keyDown.
 * @return BOOL si el receptor acepta el estado del respondedor o no
 */
- (BOOL) acceptsFirstResponder
{
    return YES;
}

/*!
 * @brief  Método que es llamado cada vez que se pulsa una tecla del teclado sobre la vista, en este
 *         caso, registraremos unicamente las teclas del teclado para que se pueda mover sobre la vista
 *         cada vez que se hace zoom.
 * @param  event El evento que ha provocado la llamada a este método, que serán las flechas de
 *         dirección del teclado
 */
-(void) keyDown:(NSEvent *)event
{
    NSRect newBounds = [self bounds];
    
    switch ([event keyCode]) {
        case 123:    // Flecha Izquierda
            newBounds.origin.x -= zoom;
            NSLog(@"Left behind.");
            break;
        case 124:    // Flecha Derecha
            newBounds.origin.x += zoom;
            NSLog(@"Right as always!");
            break;
        case 125:    // Flecha Abajo
            newBounds.origin.y += zoom;
            NSLog(@"Downward is Heavenward");
            break;
        case 126:    // Flecha Arriba
            newBounds.origin.y -= zoom;
            NSLog(@"Up, up, and away!");
            break;
        default:
            break;
    }
    
    graphicIsMoved = YES;
    
    NSLog(@"BOUNDS(X: %f Y: %f)", newBounds.origin.x, newBounds.origin.y);
    
    // Si no se hace zoom no se puede mover sobre la vista
    if (graphicIsZoomed)
        [self setBoundsOrigin:newBounds.origin];
}



@end
