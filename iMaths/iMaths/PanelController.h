//
//  PanelController.h
//  iMaths
//
//  Created by Luis Blazquez Miñambres on 12/10/18.
//  Copyright © 2018 Luis Blazquez Miñambres. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PanelModel;
@class GraphicsClass;
@class PanelModificationController;

#define NUM_PARAMETERS 10
#define NUM_DEFAULT_FUNCTIONS 6

/* --------- Delegados ---------
 *   - Ventana (NSWindowDelegate)
 *   - TextField (NSTextFieldDelegate, NSControlTextEditingDelegate)
 *   - TableView (NSTableViewDelegate, NSTableViewDataSource)
 */


@interface PanelController : NSWindowController <NSWindowDelegate,
                                                 NSTextFieldDelegate,
                                                 NSTableViewDelegate,
                                                 NSTableViewDataSource,
                                                 NSControlTextEditingDelegate,
                                                 NSComboBoxDelegate,
                                                 NSComboBoxDataSource>
{
    /* Variables de otras clases */
    
    PanelModel *modelInPanel;
    GraphicsClass *newGraphic;
    PanelModificationController *panelModController;
    
    /* Outlets Definicion de la Grafica */
    
    IBOutlet NSComboBox *selectListFuncComboBox;
    IBOutlet NSTextField *selectGraphicNameField;
    IBOutlet NSTextField *selectParamAField;      // Cambiar a formateador para solo introducir numeros y convertirlos a float con formato 0.00
    IBOutlet NSTextField *selectParamBField;
    IBOutlet NSTextField *selectParamNField;
    IBOutlet NSColorWell *selectColorGraphicButton;
    IBOutlet NSButton *addGraphicButton;         // Deshabilitado por defecto hasta que no se rellenen todos los campos
    
    /* Outlets Parámetros Generales */
    
            // Editables
    IBOutlet NSTableView *listOfCreatedFunctionsTableView;
    IBOutlet NSButton *drawGraphicButton;
    IBOutlet NSButton *modifyGraphicButton;
    IBOutlet NSButton *deleteGraphicButton;
    IBOutlet NSTextField *minRangeXField;
    IBOutlet NSTextField *minRangeYField;
    IBOutlet NSTextField *maxRangeXField;
    IBOutlet NSTextField *maxRangeYField;
           // No editables
    IBOutlet NSTextField *showFuncField;
    IBOutlet NSTextField *showNameGraphicField;
    IBOutlet NSTextField *showParamAField;
    IBOutlet NSTextField *showParamBField;
    IBOutlet NSTextField *showParamNField;
    IBOutlet NSColorWell *showColorGraphicField;
    
    /* Variables de instancia */
    
    NSString *name;
    NSString *function;
    float paramA;
    float paramB;
    float paramN;
    NSColor *colour;

}

    /* Métodos Definicion de la Grafica */

-(IBAction)selectNewGraphic:(id)sender;
-(IBAction)addNewGraphic:(id)sender;

    /* Métodos Parámetros Generales */

-(IBAction)drawGraphic:(id)sender;
-(IBAction)modifyGraphic:(id)sender;
-(IBAction)deleteGraphic:(id)sender;
-(IBAction)selectDrawingRange:(id)sender;

    /* Métodos otras Clases */

-(IBAction)showPanel:(id)sender;


@end
