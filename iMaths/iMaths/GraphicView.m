//
//  GraphicView.m
//  iMaths
//
//  Created by Luis Blazquez Miñambres on 20/10/18.
//  Copyright © 2018 Luis Blazquez Miñambres. All rights reserved.
//

#import "GraphicView.h"
#import "GraphicsClass.h"

@implementation GraphicView

extern NSString *PanelExportAndDrawGraphicsNotification;

-(instancetype)initWithFrame:(NSRect)frameRect
{
    NSLog(@"En init with frame");
    self = [super initWithFrame:frameRect];
    if (self) {
        
    }
    
    return self;
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    NSLog(@"En drawRect");
    NSRect bounds = [self bounds];          // Dimensiones de la vista
    [[NSColor whiteColor] set];             // Fondo de la vista de color blanco
    [NSBezierPath fillRect:bounds];         // Rellena el bezierPath con los limites de la vista
    NSGraphicsContext *ctx = [NSGraphicsContext currentContext]; // Contexto grafico actual
    
    // Dimensiones de la ventana
    // Puntos x e y de la esquina inferior izquierda
    // Y altura y anchura
    NSInteger origX = bounds.origin.x;
    NSInteger origY = bounds.origin.y;
    float height = bounds.size.height;
    float width = bounds.size.width;
    
    NSNumber *oX = [[NSNumber alloc]initWithInteger:origX];
    NSNumber *oY = [[NSNumber alloc]initWithInteger:origY];
    NSNumber *h = [[NSNumber alloc]initWithFloat:height];
    NSNumber *w = [[NSNumber alloc]initWithFloat:width];
    
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:ctx,@"GraphicContext",
                                                                     oX,@"OriginX",
                                                                     oY,@"OriginY",
                                                                     h,@"Height",
                                                                     w,@"Width",
                                                                     nil];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:PanelExportAndDrawGraphicsNotification
                      object:self
                    userInfo:info];
    
    NSLog(@"Enviada la información al Contolador");
    
}

@end
