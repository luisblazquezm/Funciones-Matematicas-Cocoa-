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
    
    // Drawing code here
    NSLog(@"En drawRect");
    NSRect bounds=[self bounds];
    if (P == 0){
    [[NSColor whiteColor]set];
    [NSBezierPath fillRect:bounds];
    NSGraphicsContext *ctx=[NSGraphicsContext currentContext];
    NSInteger origenX=bounds.origin.x;
    NSInteger origenY=bounds.origin.y;
    float altura=bounds.size.height;
    float ancho=bounds.size.width;
    NSNumber *oX = [[NSNumber alloc]initWithInteger:origenX];
    NSNumber *oY = [[NSNumber alloc]initWithInteger:origenY];
    NSNumber *alt = [[NSNumber alloc]initWithFloat:altura];
    NSNumber *anch = [[NSNumber alloc]initWithFloat:ancho];
        
        NSLog(@"En drawRect : %@ %@ %@ %@",oX, oY, alt, anch);
        
    
    NSDictionary *info=[NSDictionary dictionaryWithObjectsAndKeys:ctx,@"ContextoGrafico",oX,@"OrigenX",oY,@"OrigenY",alt,@"Altura",anch,@"Ancho",nil];
    NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
    [nc postNotificationName:PanelExportAndDrawGraphicsNotification object:self userInfo:info];
    
    NSLog(@"Enviada la información al Contolador");
    }
}

@end
