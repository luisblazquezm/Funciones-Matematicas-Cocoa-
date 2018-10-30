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
    NSLog(@"En init de GraphicClass");
    self = [super init];
    if(!self){
        return nil;
    }

    //colorAxis  = [NSColor blackColor];

    
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
      withMovement:(BOOL)move 
             w:(float)width
             h:(float)height
{
    NSPoint aPoint;
    float lineWidth = 0.1;   // Anchura de los ejes al dibujar
    float distance = funcRect.size.width/HOPS;
    
    funcBezier = [[NSBezierPath alloc] init];
    colorGraphic = [self colour];
    
    NSLog(@"Bounds: X: %f Y: %f WIDTH: %f HEIGHT: %f",b.origin.x
          ,b.origin.y, b.size.width, b.size.height);
    
    [funcBezier removeAllPoints];
    [ctx saveGraphicsState];
    
        if (!zoom){
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
            if (!move)
                zoomQuant += 0.1;
            
            NSAffineTransform *tfZoom = [NSAffineTransform transform];
            NSLog(@"Punto x: %f Punto y: %f ZoomQuant: %f", width, height, zoomQuant);
            [tfZoom translateXBy:width
                             yBy:height];
            [tfZoom scaleXBy:width*zoomQuant
                         yBy:height*zoomQuant];
            [tfZoom concat];
            
        }
    
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
            
            // Se cambia el funcRect si se introducen los limites en el panel 'Preferencias'
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
            NSLog(@"aPointY: %f aPointX: %f\n",aPoint.y, aPoint.x);
            
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
