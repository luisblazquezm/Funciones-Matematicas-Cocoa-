//
//  PanelModel.m
//  iMaths
//
//  Created by Luis Blazquez Miñambres on 12/10/18.
//  Copyright © 2018 Luis Blazquez Miñambres. All rights reserved.
//

#import "PanelModel.h"
#import "GraphicsClass.h"

@implementation PanelModel
@synthesize arrayListFunctions, arrayListGraphics, parametersC, parametersN, parametersB , graphicToRepresent;

//NSString *PanelDisableIndexesFunctionNotification = @"PanelDisableIndexesFunction";

/*!
 * @brief  Inicializa todas las variables de instancias declaradass en fichero .h .
 * @return id, puntero genérico.
 */
-(id)init
{
    self = [super init];
    if (self){
        NSLog(@"En init");
        arrayListFunctions = [[NSMutableArray alloc] init];
        arrayListGraphics = [[NSMutableArray alloc] init];
        graphicToRepresent = [[GraphicsClass alloc] init];
        
        parametersC = [[NSArray alloc] initWithObjects:
                       @"^c",
                       @"c^",
                       @"c*",
                       @"*c ",
                       @"c+",
                       @"+c",
                       @"-c",
                       @"c-",
                       @"c/",
                       @"/c",
                       nil];
        
        parametersB = [[NSArray alloc] initWithObjects:
                       @"^b",
                       @"b^",
                       @"b*",
                       @"*b",
                       @"b+",
                       @"+b",
                       @"-b",
                       @"b-",
                       @"b/",
                       @"/b",
                        nil];
        
        parametersN = [[NSArray alloc] initWithObjects:
                       @"^n",
                       @"n^",
                       @"n*",
                       @"*n",
                       @"n+",
                       @"+n",
                       @"-n",
                       @"n-",
                       @"n/",
                       @"/n",
                       nil];
    }
    
    return self;
}

-(void)initializeArrayListFunctions
{

    static NSString *defaultFunctions[] =
    {
        @"a*sen(b*x)",
        @"a*x+b",
        @"a*cos(b*x)",
        @"a*x^2+b*x+c",
        @"a*x^n",
        @"a/(b*x)"
        
    };
    
    // Añado las funciones minimas que tiene que tener el programa en un arrayList
    for (int i = 0; i < NUM_DEFAULT_FUNCTIONS; i++) {
        [arrayListFunctions addObject:defaultFunctions[i]];
    }
    
}

/*
-(void) createGraphic:(NSString*)functionName
              withName:(NSString*)graphicName
               paramA:(float)AGraphic
               paramB:(float)BGraphic
               paramC:(float)CGraphic
               paramN:(float)NGraphic
                color:(NSColor*)graphicColour
{
    GraphicsClass *graphic =[[GraphicsClass alloc] initWithGraphicName:graphicName
                                                              function:functionName
                                                                paramA:AGraphic
                                                                paramB:BGraphic
                                                                paramC:CGraphic
                                                                paramN:NGraphic
                                                                colour:graphicColour];
    
    [arrayListGraphics addObject:graphic];
}


-(void) drawGraphic:(id)sender
{
    
}

-(void) deleteGraphic:(NSNumber*)graphicDeletedIndex
{
    long index = [graphicDeletedIndex integerValue];
    [arrayListGraphics removeObjectAtIndex:index];
}
 */

@end
