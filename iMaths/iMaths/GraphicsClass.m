//
//  GraphicsClass.m
//  iMaths
//
//  Created by Luis Blazquez Miñambres on 13/10/18.
//  Copyright © 2018 Luis Blazquez Miñambres. All rights reserved.
//

#import "GraphicsClass.h"

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

@end
