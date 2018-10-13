//
//  PanelModel.m
//  iMaths
//
//  Created by Luis Blazquez Miñambres on 12/10/18.
//  Copyright © 2018 Luis Blazquez Miñambres. All rights reserved.
//

#import "PanelModel.h"

@implementation PanelModel
@synthesize arrayListFunctions, arrayListGraphics;

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
    
    
    /*
    NSDictionary *functionsParametersDisabled = [NSDictionary dictionaryWithObjectsAndKeys:setIndexesFunctionsWithoutN,@"formulasSinN",
                                     setIndexesFunctionsWithoutB,@"funcionesSinB",
                                     nil];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:PanelDisableIndexesFunctionNotification
                      object:self
                    userInfo:functionsParametersDisabled];
     */
}

@end
