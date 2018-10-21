//
//  PanelModel.h
//  iMaths
//
//  Created by Luis Blazquez Miñambres on 12/10/18.
//  Copyright © 2018 Luis Blazquez Miñambres. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class GraphicsClass;

#define NUM_DEFAULT_FUNCTIONS 6

//static const NSArray *parametersN;
//static const NSArray *parametersB;
//static const NSArray *parametersC;

@interface PanelModel : NSObject
{
    NSMutableArray *arrayListGraphics; // Array que contendra una serie de objetos de tipo Funcion
    NSMutableArray *arrayListFunctions; // Array que contendra las funciones a escoger para añadir una gráfica
    NSArray *parametersB;
    NSArray *parametersC;
    NSArray *parametersN;
    
    GraphicsClass *graphicToRepresent;

}

/* Getters y setters */

@property (nonatomic) NSMutableArray *arrayListFunctions;
@property (nonatomic) NSMutableArray *arrayListGraphics;
@property (nonatomic) NSArray *parametersB;
@property (nonatomic) NSArray *parametersC;
@property (nonatomic) NSArray *parametersN;
@property (nonatomic) GraphicsClass *graphicToRepresent;


    /* Metodo de inicialización del array de funciones del ComboBox */

-(void)initializeArrayListFunctions;

    /* Metodos relacionados con la representacion de graficas */

@end
