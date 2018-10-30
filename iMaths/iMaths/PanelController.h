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
 *   - ComboBox (NSComboBoxDelegate, NSComboBoxDataSource)
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
    IBOutlet NSTextField *selectParamAField;
    IBOutlet NSTextField *selectParamBField;
    IBOutlet NSTextField *selectParamCField;
    IBOutlet NSTextField *selectParamNField;
    IBOutlet NSColorWell *selectColorGraphicButton;
    IBOutlet NSButton *addGraphicButton;
    
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
    IBOutlet NSSearchField *searchField;
    
           // No editables
    IBOutlet NSTextField *showFuncField;
    IBOutlet NSTextField *showNameGraphicField;
    IBOutlet NSTextField *showParamAField;
    IBOutlet NSTextField *showParamBField;
    IBOutlet NSTextField *showParamCField;
    IBOutlet NSTextField *showParamNField;
    IBOutlet NSColorWell *showColorGraphicField;
    
           // Botones de progreso (Rojo - Amarillo - Verde)
    IBOutlet NSButton *functionDefProgressButton;
    IBOutlet NSButton *parametersProgressButton;
    IBOutlet NSButton *appearanceProgressButton;
    IBOutlet NSTextField *functionDefLabel;
    IBOutlet NSTextField *parametersLabel;
    IBOutlet NSTextField *appearanceLabel;
    
    /* Variables de instancia */
    
    // Variables globales de los parametros con los que se creara cada gráfica
    NSString *name;
    NSString *function;
    float paramA;
    float paramB;
    float paramC;
    float paramN;
    NSColor *colour;
    
    NSInteger previousSelectedRow;
    BOOL functionSelectedFlag;
    BOOL BisEnabled ,CisEnabled ,NisEnabled, filterEnabled;
    NSNumberFormatter *formatter;
    
}

    /* Manejadoras llamadas tras recibir las notificaciones */
-(void) handleNewGraphicImported:(NSNotification *)aNotification;
-(void) handleModelReceived:(NSNotification *)aNotification;

    /* Métodos Definicion de la Grafica */
-(void) selectFunction;
-(void) selectName;
-(void) selectParameters;
-(void) selectColour;
-(void) checkAddGraphicIsAvailable;
-(IBAction) addNewGraphic:(id)sender;
-(void) fomatterOnlyRealNumbers;
-(void) applyFilterWithString:(NSString*)filter;
-(void) deactivateFields;

    /* Métodos Parámetros Generales */
-(IBAction) drawGraphic:(id)sender;
-(IBAction) deleteGraphic:(id)sender;

    /* Métodos Panel Modificar */
-(IBAction) showPanel:(id)sender;
-(void) handleGraphicModified:(NSNotification *)aNotification;


@end
