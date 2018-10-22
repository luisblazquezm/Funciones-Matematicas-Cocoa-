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
static NSRect funcRect = {-10, -10, 20 ,20}; //MAXIMO Y MINIMO DE EJES X E Y Y DONDE ESTA LA ESQUINA INFERIOR IZQUIERDA

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
    self=[super init];
    if(!self){
        return nil;
    }
    
    termCount = (random() % 3) + 2;
    terms = malloc(termCount * sizeof(float));
    
    for (int i = 0; i < termCount; i++) {
        terms[i] = 5.0 - (random() % 100)/10.0;
    }
    
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
{
    NSPoint aPoint;
    int counter = 0;
    
    // IMPORTANTE: esto está aqui porque no se llama al init cuando nuestra grafica llama a este metodo
    funcBezier = [[NSBezierPath alloc] init];
    axisXBezier = [[NSBezierPath alloc] init];
    axisYBezier = [[NSBezierPath alloc] init];
    pointsAxisXBezier = [[NSBezierPath alloc] init];
    pointsAxisYBezier = [[NSBezierPath alloc] init];
    
    colorGraphic = [self colour];
    colorAxis  = [NSColor blackColor];
    
    float distance = funcRect.size.width/HOPS;
    
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
    
        [axisXBezier setLineWidth:0.1];
        [colorAxis setStroke];
    
        aPoint.x = funcRect.origin.x;
        aPoint.y = 0;
        //NSLog(@"aPointY: %f aPointX: %f\n",aPoint.y, aPoint.x);
    
        [axisXBezier moveToPoint:aPoint];
        while (aPoint.x <= funcRect.origin.x + funcRect.size.width) {
            //NSLog(@"Point: %f %f", aPoint.x, aPoint.y);
            aPoint.y = 0;
            [axisXBezier lineToPoint:aPoint];
            aPoint.x += distance;
        }
    
        [axisXBezier stroke];
    
                            // * EJE Y *
    
        [axisYBezier setLineWidth:0.1];
        [colorAxis setStroke];
    
        // Comienza en el punto minimo de Y (abajo) y dibuja la raya hasta el punto maximo (la altura)
        aPoint.x = 0;
        aPoint.y = funcRect.origin.y;
        //NSLog(@"aPointY: %f aPointX: %f\n",aPoint.y, aPoint.x);
    
        [axisYBezier moveToPoint:aPoint];
        while (aPoint.y <= funcRect.origin.y + funcRect.size.height) {
            //NSLog(@"Point: %f %f", aPoint.x, aPoint.y);
            aPoint.x = 0;
            [axisYBezier lineToPoint:aPoint];
            aPoint.y += distance;
        }
    
        [axisYBezier stroke];
    
        /* -------------- Dibujo de los puntos de los ejes --------------- */
    
                            // * EJE X (POSITIVO) *
    
        [pointsAxisXBezier setLineWidth:0.1];
        [colorAxis setStroke];
    
        aPoint.x = 0;
        aPoint.y = 0.3;
        // Si lo hago desde el punto x minimo hasta el punto x maximo (anchura) se mueven los ejes al redimensionar la ventana
        // Por eso hago la primera mitad positiva y luego la negativa de x e y
        [pointsAxisXBezier moveToPoint:aPoint];
    
        while (aPoint.x <= (funcRect.size.width/2))  { // aPoint.y = 0.3 => -0.3
            counter++;
            NSLog(@"PointPositivo: %f %f ", aPoint.x, aPoint.y);
            aPoint.x += 0.5;
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
    
        [pointsAxisXBezier setLineWidth:0.1];
        [colorAxis setStroke];
    
        aPoint.x = 0;
        aPoint.y = 0.3;
        [pointsAxisXBezier moveToPoint:aPoint];
    
        counter = 0;
        while (aPoint.x >= (funcRect.size.width/2))  {
            counter++;
            NSLog(@"PointNegativo: %f %f ", aPoint.x, aPoint.y);
            aPoint.x -= 0.5;
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
    
        [pointsAxisYBezier setLineWidth:0.1];
        [colorAxis setStroke];
    
        // Comienza en el punto minimo de Y (abajo) y dibuja la raya hasta el punto maximo (la altura)
        aPoint.x = 0;
        aPoint.y = funcRect.origin.y;
        //NSLog(@"aPointY: %f aPointX: %f\n",aPoint.y, aPoint.x);
    
        [pointsAxisYBezier moveToPoint:aPoint];
        while (aPoint.y <= funcRect.origin.y + funcRect.size.height) {
            //NSLog(@"Point: %f %f", aPoint.x, aPoint.y);
            aPoint.x = 0;
            [axisYBezier lineToPoint:aPoint];
            aPoint.y += distance;
        }
    
        [pointsAxisYBezier stroke];
    
                            // * EJE Y (NEGATIVO) *
    
        /* -------------- Dibujo de las graficas --------------- */
    
        [funcBezier setLineWidth:0.1];
        [colorGraphic setStroke];
    
        aPoint.x = funcRect.origin.x;
        aPoint.y = [self valueAt:aPoint.x];
        //NSLog(@"aPointY: %f aPointX: %f\n",aPoint.y, aPoint.x);
    
        [funcBezier moveToPoint:aPoint];
        while (aPoint.x <= funcRect.origin.x + funcRect.size.width) {
            //NSLog(@"Point: %f %f", aPoint.x, aPoint.y);
            aPoint.y = [self valueAt:aPoint.x];
            [funcBezier lineToPoint:aPoint];
            aPoint.x += distance;
        }
    
        [funcBezier stroke];
    
    [ctx restoreGraphicsState];
}


@end
