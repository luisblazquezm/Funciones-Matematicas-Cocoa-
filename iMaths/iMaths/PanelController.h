//
//  PanelController.h
//  iMaths
//
//  Created by Luis Blazquez Miñambres on 12/10/18.
//  Copyright © 2018 Luis Blazquez Miñambres. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PanelModel;

/* --------- Delegados ---------
 *   - Ventana (NSWindowDelegate)
 *   - TextField (NSTextFieldDelegate, NSControlTextEditingDelegate)
 *   - TableView (NSTableViewDelegate, NSTableViewDataSource)
 */


@interface PanelController : NSWindowController <NSWindowDelegate,
                                                 NSTextFieldDelegate,
                                                 NSTableViewDelegate,
                                                 NSTableViewDataSource,
                                                 NSControlTextEditingDelegate>
{
    /* Variable Modelo */
    
    PanelModel *modelInPanel;
    
    /* Outlets Definicion de la Grafica */
    
    IBOutlet NSComboBox *selectListFuncComboBox;
    IBOutlet NSTextField *selectFuncNameField;
    IBOutlet NSTextField *selectParamAField; // Cambiar a formateador para solo introducir numeros y convertirlos a float con formato 0.00
    IBOutlet NSTextField *selectParamBField;
    IBOutlet NSTextField *selectParamNField;
    IBOutlet NSColorWell *selectColorFuncButton;
    IBOutlet NSButton *addFuncButton;
    
    /* Outlets Parámetros Generales */
    
    // Editables
    IBOutlet NSTableView *listOfCreatedFunctionsTableView;
    IBOutlet NSButton *drawFunctionButton;
    IBOutlet NSButton *modifyFunctionButton;
    IBOutlet NSButton *deleteFunctionButton;
    IBOutlet NSTextField *minRangeXField;
    IBOutlet NSTextField *minRangeYField;
    IBOutlet NSTextField *maxRangeXField;
    IBOutlet NSTextField *maxRangeYField;
    // No editables
    IBOutlet NSTextField *showFuncField;
    IBOutlet NSTextField *showNameFuncField;
    IBOutlet NSTextField *showParamAField;
    IBOutlet NSTextField *showParamBField;
    IBOutlet NSTextField *showParamNField;
    IBOutlet NSColorWell *showColorFuncField;
    

}

    /* Métodos Definicion de la Grafica */

-(IBAction)selectForNewFunction:(id)sender;
-(IBAction)addNewFunction:(id)sender;

    /* Métodos Parámetros Generales */

-(IBAction)drawFunction:(id)sender;
-(IBAction)modifyFunction:(id)sender;
-(IBAction)deleteFunction:(id)sender;
-(IBAction)showFunctionInfo:(id)sender;
-(IBAction)selectDrawingRange:(id)sender;


@end
