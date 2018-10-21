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
    
    // IMPORTANTE: esto está aqui porque no se llama al init cuando nuestra grafica llama a este metodo
    poly = [[NSBezierPath alloc] init];
    color = [self colour];
    
    float distance = funcRect.size.width/HOPS;
    
    [poly removeAllPoints];
    [ctx saveGraphicsState]; //------------------- Contexto gráfico
    

    NSAffineTransform *tf = [NSAffineTransform transform];
    [tf translateXBy:b.size.width/2 yBy:b.size.height/2];   // 2º Mult* por la matriz de Transformación Afín
    [tf scaleXBy:b.size.width/funcRect.size.width           // 1º Ancho y Alto / Escala (funcRect)
             yBy:b.size.height/funcRect.size.height];
    [tf concat];
    
    [poly setLineWidth:0.1];
    [color setStroke];
    
    aPoint.x = funcRect.origin.x;
    aPoint.y = [self valueAt:aPoint.x];
    //NSLog(@"aPointY: %f aPointX: %f\n",aPoint.y, aPoint.x);
    
    [poly moveToPoint:aPoint];
    while (aPoint.x <= funcRect.origin.x + funcRect.size.width) {
        //NSLog(@"Point: %f %f", aPoint.x, aPoint.y);
        aPoint.y = [self valueAt:aPoint.x];
        [poly lineToPoint:aPoint];
        aPoint.x += distance;
    }
    
    [poly stroke];
    [ctx restoreGraphicsState];
}

/*
-(float) valueOfYAt:(float)x //Si no funciona con el self probar con graphics
{
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

// Cada vez que se añade una grafica cambian los bounds b y el contexto grafico (uno para todas las graficas)

-(void) drawInRect:(NSRect)b
withGraphicsContext:(NSGraphicsContext*)ctx
{
    NSLog(@"En drawInRect withGraphicsContext");
    NSPoint aPoint;
    float distance = funcRect.size.width/HOPS;
    
    //[poly removeAllPoints];
    [ctx saveGraphicsState]; //------------------- Contexto gráfico
    
        NSAffineTransform *tf = [NSAffineTransform transform];
        [tf translateXBy:b.size.width/2 yBy:b.size.height/2];
        [tf scaleXBy:b.size.width/funcRect.size.width
                 yBy:b.size.height/funcRect.size.height];
        [tf concat];
    
        [poly setLineWidth:0.1];
        [[self colour] setStroke];
        NSLog(@"Color %@ Funcion %@\n", [self colour], [self function]);
        aPoint.x =  funcRect.origin.x;
        aPoint.y = -448.600006;//[self valueOfYAt:aPoint.x];
        NSLog(@"aPointY: %f aPointX: %f\n",aPoint.y, aPoint.x);
    
        [poly moveToPoint:aPoint];
        while (aPoint.x <= funcRect.origin.x + funcRect.size.width) {
            aPoint.y = [self valueOfYAt:aPoint.x];
            [poly lineToPoint:aPoint];
            aPoint.x += distance;
        }
    
        [poly stroke];
    [ctx restoreGraphicsState]; //------------------- Contexto gráfico
}
 */

@end
