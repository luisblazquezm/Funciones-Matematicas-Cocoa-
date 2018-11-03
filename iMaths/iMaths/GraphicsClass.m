//
//  GraphicsClass.m
//  iMaths
//
//  Created by Luis Blazquez Miñambres on 13/10/18.
//  Copyright © 2018 Luis Blazquez Miñambres. All rights reserved.
//

#import "GraphicsClass.h"
#import <math.h>

#define RANDFLOAT() (random()%128/128.0)
#define HOPS (500) // Numero de puntos
static NSRect funcRect = {-10, -10, 20 ,20};


@implementation GraphicsClass
@synthesize funcName, function, paramA, paramB, paramC, paramN, colour;

/*!
 * @brief  Constructor de la clase
 */
-(id) initWithGraphicName: (NSString *) graphic_Name
                 function: (NSString *) graphic_Function
                   paramA: (float) graphic_ParamA
                   paramB: (float) graphic_ParamB
                   paramC: (float) graphic_ParamC
                   paramN: (float) graphic_ParamN
                   colour: (NSColor *) graphic_Colour
{

    self = [super init];
    NSLog(@"En init de GraphicClass");
    if(!self)
        return nil;
    [self setFuncName: graphic_Name];
    [self setFunction: graphic_Function];
    [self setParamA: graphic_ParamA];
    [self setParamB: graphic_ParamB];
    [self setParamC: graphic_ParamC];
    [self setParamN: graphic_ParamN];
    [self setColour: graphic_Colour];
    
    return self;
}

-(NSString *) description
{
    NSString *descriptionString;
    
    descriptionString = [[NSString alloc] initWithFormat:@"%@:\n\t-Funcion: %@\n\t-paramA: %f\n\t-paramB: %f\n\t-paramC: %f\n\t-paramN: %f\n\t-Colour : %@\n\t",
                         funcName, function, paramA, paramB, paramC, paramN , colour];
    
    return descriptionString;
}

-(id) init{
    NSLog(@"En init de GraphicClass");
    self = [super init];
    if(!self){
        return nil;
    }
    
    return self;
}

/*!
 * @brief  Devuelve el valor de y según la función que se quiere representar y al valor de
 *         x pasado
 * @param  x Valor de la coordenada x
 * @return float Valor de y con respecto al valor de x pasado
 */
-(float)valueAt:(float)x{
    float resultY = 0;
    
    if ([[self function] isEqualToString:@"a*sen(b*x)"]) {
        resultY = [self paramA] * sinf( ([self paramB] * x) );
    } else if ([[self function] isEqualToString:@"a*x+b"]) {
        resultY = [self paramA] * x + [self paramB];
    } else if ([[self function] isEqualToString:@"a*cos(b*x)"]) {
        resultY = [self paramA] * cosf( ([self paramB] * x) );
    } else if ([[self function] isEqualToString:@"a*x^2+b*x+c"]) {
        resultY = [self paramA] * powf(x, 2) + [self paramB] * x + [self paramC];
    } else if ([[self function] isEqualToString:@"a*x^n"]) {
        resultY = [self paramA] * pow(x, [self paramN]);
    } else { // @"a/(b*x)"
        resultY = [self paramA] / ([self paramB] * x);
    }
    return resultY;
}


/*!
 * @brief  Devuelve el valor de y según la función que se quiere representar y al valor de
 *         x pasado
 * @param  b Limites o bounds de la vista
 *         ctx Contexto grafica actual de representacion
 *         limit Limites de representación de la gráfica
 *         zoom Flag que indica si se va a hacer zoom sobre la vista
 *         move Flag que indica si se va a mover la vista
 *         width Coordenada 'x' del punto medio entre el punto en el que el usario ha hecho click
 *               izquierdo y el punto en el que, al arrastrar,  ha soltado para hacer zoom
 *         height Coordenada 'y' del punto medio entre el punto en el que el usario ha hecho click
 *               izquierdo y el punto en el que, al arrastrar,  ha soltado para hacer zoom
 */
-(void) drawInRect:(NSRect)b
withGraphicsContext:(NSGraphicsContext*)ctx
          andLimits:(NSRect)limit
           isZoomed:(BOOL)zoom
      withMovement:(BOOL)move 
             w:(float)width
             h:(float)height
{
    NSPoint aPoint;
    NSRect limitOfDrawing;
    float lineWidth = 0.1;   // Anchura de la grafica
    float distance = funcRect.size.width/HOPS;
    
    funcBezier = [[NSBezierPath alloc] init];
    colorGraphic = [self colour];
    
    NSLog(@"Bounds: X: %f Y: %f WIDTH: %f HEIGHT: %f",b.origin.x
          ,b.origin.y, b.size.width, b.size.height);
    
    [funcBezier removeAllPoints];
    [ctx saveGraphicsState];
    
        if (!zoom){
            zoomQuant = 0;
            
            NSLog(@"Matriz de tranformación afin creada (GraphicClass)");
            NSAffineTransform *tf = [NSAffineTransform transform];
            tf = [NSAffineTransform transform];
            // 2º Mult* por la matriz de Transformación Afín (Coloca la x e y en el (0,0) con respecto a la grafica
            [tf translateXBy:b.size.width/2
                         yBy:b.size.height/2];
            // 1º Ancho y Alto / Escala (funcRect)
            [tf scaleXBy:b.size.width/funcRect.size.width
                     yBy:b.size.height/funcRect.size.height];
            [tf concat];
            
        } else { // Si se realiza ZOOM sobre la vista
            
            if (!move)
                zoomQuant += 0.1;
            
            NSLog(@"Matriz de tranformación afin de ZOOM creada (GraphicClass)");
            NSAffineTransform *tfZoom = [NSAffineTransform transform];
            NSLog(@"Punto x: %f Punto y: %f ZoomQuant: %f", width, height, zoomQuant);
            [tfZoom translateXBy:width
                             yBy:height];
            [tfZoom scaleXBy:width*zoomQuant
                         yBy:height*zoomQuant];
            [tfZoom concat];
            
        }
    
        /* -------------- Dibujo de las graficas --------------- */

        // Debe de haber una función para la gráfica a representar
        if ([[self function] length] > 0){
            
            limitOfDrawing.origin.x = funcRect.origin.x;
            limitOfDrawing.origin.y = funcRect.origin.y;
            limitOfDrawing.size.width = funcRect.size.width;
            limitOfDrawing.size.height = funcRect.size.height;
            
            NSLog(@"Limits: oX: %f oY: %f width: %f height: %f", limit.origin.x,
                  limit.origin.y,
                  limit.size.width,
                  limit.size.height);
            NSLog(@"Anterior FunRect: oX: %f oY: %f width: %f height: %f", funcRect.origin.x,
                  funcRect.origin.y,
                  funcRect.size.width,
                  funcRect.size.height);
            
            // Se cambia el funcRect si se introducen los limites en el panel 'Preferencias'
            if (limit.origin.x != 0)
                limitOfDrawing.origin.x = limit.origin.x;
            
            if (limit.origin.y != 0)
                limitOfDrawing.origin.y = limit.origin.y;
            
            if (limit.size.width != 0)
                limitOfDrawing.size.width = limit.size.width;
            
            if (limit.size.height != 0)
                limitOfDrawing.size.height = limit.size.height;
            
            NSLog(@"Nuevo FunRect: oX: %f oY: %f width: %f height: %f", limitOfDrawing.origin.x,
                  limitOfDrawing.origin.y,
                  limitOfDrawing.size.width,
                  limitOfDrawing.size.height);
            
            [funcBezier setLineWidth:lineWidth];
            [colorGraphic setStroke];

            aPoint.x = limitOfDrawing.origin.x;
            aPoint.y = [self valueAt:aPoint.x];
            NSLog(@"aPointY: %f aPointX: %f\n",aPoint.y, aPoint.x);
            
            [funcBezier moveToPoint:aPoint];
            while (aPoint.x <= limitOfDrawing.size.width) {
                NSLog(@"Point: %f %f", aPoint.x, aPoint.y);
                aPoint.y = [self valueAt:aPoint.x];
                [funcBezier lineToPoint:aPoint];
                aPoint.x += distance;
            }
        
            [funcBezier stroke];
        }
    
    [ctx restoreGraphicsState];
}


@end
