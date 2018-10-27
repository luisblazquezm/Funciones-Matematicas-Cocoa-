//
//  GraphicsClass.h
//  iMaths
//
//  Created by Luis Blazquez Miñambres on 13/10/18.
//  Copyright © 2018 Luis Blazquez Miñambres. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GraphicsClass : NSObject
{
    NSString *funcName;
    NSString *function;
    float paramA;
    float paramB;
    float paramC;
    float paramN;
    NSColor *colour;
    
    NSRect funcRect;
    
    NSColor *colorGraphic;
    NSColor *colorAxis;
    NSBezierPath *funcBezier;
    NSBezierPath *axisXBezier, *axisYBezier;
    NSBezierPath *pointsAxisXBezier, *pointsAxisYBezier;
    float zoomQuant;
}

    /* Getters y setters */

@property (nonatomic) NSString *funcName;
@property (nonatomic) NSString *function;
@property (nonatomic) float paramA;
@property (nonatomic) float paramB;
@property (nonatomic) float paramC;
@property (nonatomic) float paramN;
@property (nonatomic) NSColor *colour;

//@property(retain)NSBezierPath *poly;

    /* Constructor */

-(id) initWithGraphicName: (NSString *) graphic_Name
                 function: (NSString *) graphic_Function
                   paramA: (float) graphic_ParamA
                   paramB: (float) graphic_ParamB
                   paramC: (float) graphic_ParamC
                   paramN: (float) graphic_ParamN
                   colour: (NSColor *) graphic_Colour;

    /* Metodos para representar graficas */

-(float) valueAt:(float)x;

-(void) drawInRect:(NSRect)b
withGraphicsContext:(NSGraphicsContext*)ctx
          andLimits:(NSRect)limit
          isZoomed:(BOOL)zoom
                 w: (float)width
                 h:(float)height;
@end
