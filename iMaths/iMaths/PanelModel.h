//
//  PanelModel.h
//  iMaths
//
//  Created by Luis Blazquez Miñambres on 12/10/18.
//  Copyright © 2018 Luis Blazquez Miñambres. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NUM_DEFAULT_FUNCTIONS 6

@interface PanelModel : NSObject
{
    NSMutableArray *arrayListGraphics; // Array que contendra una serie de objetos de tipo Funcion
    NSMutableArray *arrayListFunctions; // Array que contendra las funciones a escoger para añadir una gráfica
}

/* Getters y setters */

@property (nonatomic) NSMutableArray *arrayListFunctions;
@property (nonatomic) NSMutableArray *arrayListGraphics;

-(void)initializeArrayListFunctions;

@end
