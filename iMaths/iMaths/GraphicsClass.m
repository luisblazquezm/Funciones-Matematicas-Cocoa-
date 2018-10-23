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


@implementation GraphicsClass
@synthesize funcName, function, paramA, paramB, paramC, paramN, colour;


-(id) initWithGraphicName: (NSString *) graphic_Name
                 function: (NSString *) graphic_Function
                   paramA: (float) graphic_ParamA
                   paramB: (float) graphic_ParamB
                   paramC: (float) graphic_ParamC
                   paramN: (float) graphic_ParamN
                   colour: (NSColor *) graphic_Colour
{

    self = [super init];
    
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

-(id)init{
    NSLog(@"En init de GC");
    self = [super init];
    if(!self){
        return nil;
    }
    
    //MAXIMO Y MINIMO DE EJES X E Y Y DONDE ESTA LA ESQUINA INFERIOR IZQUIERDA
    funcRect.origin.x = -10;
    funcRect.origin.y = -10;
    funcRect.size.width = 20;
    funcRect.size.height = 20;
    
    // IMPORTANTE: esto está aqui porque no se llama al init cuando nuestra grafica llama a este metodo
    funcBezier = [[NSBezierPath alloc] init];
    axisXBezier = [[NSBezierPath alloc] init];
    axisYBezier = [[NSBezierPath alloc] init];
    pointsAxisXBezier = [[NSBezierPath alloc] init];
    pointsAxisYBezier = [[NSBezierPath alloc] init];
    
    
    colorGraphic = [self colour];
    colorAxis  = [NSColor blackColor];
    
    return self;
}

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

-(void) drawInRect:(NSRect)b
withGraphicsContext:(NSGraphicsContext*)ctx
          andLimits:(NSRect)limit
           isZoomed:(BOOL)zoom
{
    NSPoint aPoint;
    int counter = 0;
    float lineWidth = 0.1;
    float spacePoints = 0.3;
    float width = 0;
    
    [self init];
    
    float distance = funcRect.size.width/HOPS;
    
    NSLog(@"Bounds: X: %f Y: %f WIDTH: %f HEIGHT: %f",b.origin.x
          ,b.origin.y, b.size.width, b.size.height);
    
    // Cuando se añade una nueva grafica se borra la anterior
    [funcBezier removeAllPoints];
    [ctx saveGraphicsState]; //------------------- Contexto gráfico

        NSAffineTransform *tf = [NSAffineTransform transform];
        // 2º Mult* por la matriz de Transformación Afín
        [tf translateXBy:b.size.width/2
                     yBy:b.size.height/2];
        // 1º Ancho y Alto / Escala (funcRect)
        [tf scaleXBy:b.size.width/funcRect.size.width
                 yBy:b.size.height/funcRect.size.height];
        [tf concat];
    
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
    
        /* -------------- Dibujo de las graficas --------------- */
    
        if ([[self function] length] > 0){
            
            NSLog(@"Limits: oX: %f oY: %f width: %f height: %f", limit.origin.x,
                  limit.origin.y,
                  limit.size.width,
                  limit.size.height);
            NSLog(@"Anterior FunRect: oX: %f oY: %f width: %f height: %f", funcRect.origin.x,
                  funcRect.origin.y,
                  funcRect.size.width,
                  funcRect.size.height);
            
            if (limit.origin.x != 0)
                funcRect.origin.x = limit.origin.x;
            
            if (limit.origin.y != 0)
                funcRect.origin.y = limit.origin.y;
            
            if (limit.size.width != 0)
                funcRect.size.width = limit.size.width;
            
            if (limit.size.height != 0)
                funcRect.size.height = limit.size.height;
            
            NSLog(@"Nuevo FunRect: oX: %f oY: %f width: %f height: %f", funcRect.origin.x,
                  funcRect.origin.y,
                  funcRect.size.width,
                  funcRect.size.height);
            
            [funcBezier setLineWidth:lineWidth];
            [colorGraphic setStroke];
        
            aPoint.x = funcRect.origin.x;
            aPoint.y = [self valueAt:aPoint.x];
            //NSLog(@"aPointY: %f aPointX: %f\n",aPoint.y, aPoint.x);
        
            if (zoom) {
                width = b.size.width;
            } else {
                width = funcRect.size.width;
            }
            
            [funcBezier moveToPoint:aPoint];
            while (aPoint.x <= funcRect.size.width) {
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
