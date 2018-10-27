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
    
    NSArray *arrayOfGraphicsToRepresent;
    
    NSInteger rowSelectedToModify;

}

/* Getters y setters */

@property (nonatomic) NSMutableArray *arrayListFunctions;
@property (nonatomic) NSMutableArray *arrayListGraphics;
@property (nonatomic) NSArray *parametersB;
@property (nonatomic) NSArray *parametersC;
@property (nonatomic) NSArray *parametersN;
@property (nonatomic) NSArray *arrayOfGraphicsToRepresent;
@property (nonatomic) NSInteger rowSelectedToModify;


    /* Metodo de inicialización del array de funciones del ComboBox */

-(void)initializeArrayListFunctions;

    /* Metodos relacionados con la representacion de graficas */

-(void) createGraphic:(NSString*)functionName
             withName:(NSString*)graphicName
               paramA:(float)AGraphic
               paramB:(float)BGraphic
               paramC:(float)CGraphic
               paramN:(float)NGraphic
                color:(NSColor*)graphicColour;
-(void) addGraphic:(id)sender;
-(void) arrayOfGraphicToDrawInIndexes:(NSIndexSet*)indexArray;
-(void) deleteGraphic:(NSInteger)graphicDeletedIndex;
-(NSMutableArray*) importListOfGraphics;
-(void) exportListOfGraphicsTo:(NSString*)typeFile;
-(void) exportGraphicView:(NSView*)view To:(NSString*)extension;
-(NSInteger) countOfArrayListGraphics;


@end
