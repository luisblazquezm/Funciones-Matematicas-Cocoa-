//
//  PanelModel.h
//  iMaths
//
//  Created by Luis Blazquez Miñambres on 12/10/18.
//  Copyright © 2018 Luis Blazquez Miñambres. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class GraphicsClass;
#define RANDFLOAT() (random()%128/128.0)
#define HOPS (500) // Numero de puntos
#define NUM_DEFAULT_FUNCTIONS 6

static NSRect funcRect = {-10, -10, 20 ,20}; 

@interface PanelModel : NSObject
{
    // Array que contendra una serie de objetos de tipo Funcion
    NSMutableArray *arrayListGraphics;
    // Array que contendra las funciones a escoger para añadir una gráfica
    NSMutableArray *arrayListFunctions;
    // Array que contendra las graficas filtras por el nombre introducido en la barra de Búsquda
    NSMutableArray *arrayFilteredGraphics;
    // Arrays con las posibles apariciones de los parametros b,c o n en una función y poder habilitar sus corrrespondientes campos
    NSArray *parametersB;
    NSArray *parametersC;
    NSArray *parametersN;
    // Array que contendra las gráficas que se quieran representar en la vista
    NSArray *arrayOfGraphicsToRepresent;
    // Indice de la grafica del arrayListGraphics que se va a modificar
    NSInteger rowSelectedToModify;
    float zoomQuant;
    NSColor *colorAxis;
    NSBezierPath *funcBezier, *axisXBezier, *axisYBezier, *pointsAxisXBezier, *pointsAxisYBezier;

}

    /* Getters y setters */

@property (nonatomic) NSMutableArray *arrayListFunctions;
@property (nonatomic) NSMutableArray *arrayListGraphics;
@property (nonatomic) NSArray *parametersB;
@property (nonatomic) NSArray *parametersC;
@property (nonatomic) NSArray *parametersN;
@property (nonatomic) NSArray *arrayOfGraphicsToRepresent;
@property (nonatomic) NSInteger rowSelectedToModify;
@property (nonatomic) NSMutableArray *arrayFilteredGraphics;


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
-(BOOL) containsName:(NSString*)name;
-(GraphicsClass*) getGraphicToModify;
-(void) graphicModified:(GraphicsClass*)graph;
-(void) arrayOfGraphicToDrawInIndexes:(NSIndexSet*)indexArray;
-(void) deleteGraphicAtIndexes:(NSIndexSet*)graphicDeletedIndexes;
-(BOOL) importListOfGraphics;
-(void) exportListOfGraphicsTo:(NSString*)typeFile;
-(void) exportGraphicView:(NSView*)view To:(NSString*)extension;
-(NSInteger) countOfArrayListGraphics;
-(NSString*) graphicLabelInfo:(GraphicsClass*)graph;
-(NSString*) stringRepresentationOf:(NSColor*) colour;
-(NSColor*) colorFromString:(NSString*)string forColorSpace:(NSColorSpace*)colorSpace;
-(void) drawAxisAndPoints:(NSRect)b
      withGraphicsContext:(NSGraphicsContext*)ctx
                 isZoomed:(BOOL)zoom
             withMovement:(BOOL)move
                        w:(float)width
                        h:(float)height;


@end
