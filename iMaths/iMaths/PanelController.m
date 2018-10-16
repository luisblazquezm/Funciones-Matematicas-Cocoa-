//
//  PanelController.m
//  iMaths
//
//  Created by Luis Blazquez Miñambres on 12/10/18.
//  Copyright © 2018 Luis Blazquez Miñambres. All rights reserved.
//

#import "PanelController.h"
#import "PanelModel.h"
#import "GraphicsClass.h"
#import "PanelModificationController.h"

/* --------- Esquema metodos ---------
 *   > Inicializadores
 *       - init
 *       - initWithWindow
 *   > Tratamiento de ventana
 *       - windowShouldClose
 *       - windowDidLoad
 *   > Acciones Definicion Grafica
 *   > Acciones Parámetros Generales
 *      > Acciones tabla
 *      > Otros
 *   >
 *
 */


@interface PanelController ()

@end

@implementation PanelController

NSString *PanelModifyGraphicNotification = @"PanelModifyGraphic"; // PanelController -> PanelModificationController
NSString *PanelExportGraphicsNotification = @"PanelExportGraphics"; // PanelController -> Controller

extern NSString *PanelNewGraphicNotification; // PanelModificationController -> PanelController
                                              // Controller -> PanelController

/* --------------------------- INICIALIZADORES ---------------------- */

/*!
 * @brief  Inicializa todas las variables de instancias declaradass en fichero .h .
 * @return id, puntero genérico.
 */
-(id)init
{
    if (![super initWithWindowNibName:@"PanelController"])
        return nil;
    
    return self;
}


/*!
 * @brief  Inicializa la ventana principal con el panel
 * @param  window .Ventana panelController.
 * @return instancetype.
 */
-(instancetype) initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self){
        NSLog(@"En init Panel");
        modelInPanel = [[PanelModel alloc] init];
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        
        [nc addObserver:self
               selector:@selector(handleNewGraphic:)
                   name:PanelNewGraphicNotification
                 object:nil];
        

    }
    
    return self;
}

/*!
 * @brief  Realiza una operación al cargar el fichero NIB
 */

-(void) awakeFromNib
{
    [modelInPanel initializeArrayListFunctions];       // Inicializa el array del modelo de funciones
    [selectListFuncComboBox addItemsWithObjectValues:[modelInPanel arrayListFunctions]]; // Añade esas funciones al ComboBox
}

/* --------------------------- TRATAMIENTO DE VENTANAS ---------------------- */

/*!
 * @brief  Notifica al usuario del cierre total de la ventana de la aplicacion.
 * @param  sender Objeto ventana.
 * @return BOOL, respuesta del usuario al mensaje de cierre.
 */
-(BOOL) windowShouldClose:(NSWindow *)sender
{
    NSInteger respuesta;
    
    respuesta = NSRunAlertPanel(@"Atencion",
                                @"¿Está seguro de que desea cerrar la ventana?.Esta accion finalizará la ejecución de la aplicación ",
                                @"No",
                                @"Si",
                                nil);
    
    if(respuesta == NSAlertDefaultReturn)
        return NO;
    else
        //[NSApp terminate:self];
    return YES;
    
}

/*!
 * @brief  Manejador de inicialización del panel al ser cargado del fichero NIB .
 */
-(void) windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


/* --------------------------- ACCIONES DEFINICION GRAFICA ---------------------- */


/* SI EL CONTENIDO CAMBIA DINAMICAMENTE (ES DECIR AÑADIMOS NUEVAS FUNCIONES)
 * tambien habria que pasarlo a Editable porque solo se puede seleccionar
 - (void)comboBoxWillPopUp:(NSNotification *)notification
 {
 [[modelInPanel arrayListFunctions] ]
 }
 
 
 - (NSString *)comboBox:(NSComboBox *)comboBox
 completedString:(NSString *)string
 {
 int z = 0;
 
 for (int i = 0; i < NUM_PARAMETERS; i++) {
 if ([[[modelInPanel arrayListFunctions] objectAtIndex:i ] containsString:string] ){
 z = i;
 }
 }
 
 return [[modelInPanel arrayListFunctions] objectAtIndex:z ];
 }
 
 - (id)comboBox:(NSComboBox *)comboBox
 objectValueForItemAtIndex:(NSInteger)index
 {
 return [[modelInPanel arrayListFunctions] objectAtIndex:index];
 }
 
 - (NSInteger)numberOfItemsInComboBox:(NSComboBox *)comboBox
 {
 return [[modelInPanel arrayListFunctions] count];
 }
 */


/*!
 * @brief  Almacena los parametros que va introduciendo el usuario
 *         para activar el boton 'Añadir' y añadir una nueva grafica.
 */
-(IBAction) selectNewGraphic:(id)sender
{
    
    /*
     *--------- Definicion Funcion ------------
     */
    
    function = [selectListFuncComboBox stringValue];
    NSLog(@"Funcion %@ escogida\r", function);
    
    name = [selectGraphicNameField stringValue];
    NSLog(@"Nombre Funcion %@\r", name);
    
    /*
     *--------- Parametros ------------
     */
    
    if([function length] != 0){
        [selectParamAField setEnabled:YES];
        paramA = [selectParamAField floatValue];
        
        /* Hallo los indices del array de funciones cuyas formulas no contienen una 'n'
         * para poder deshabilitar el campo del parámetro 'n' en el controlador PanelController
         * Lo envio a través de un set de indices dentro de un NSDictionary por medio de una Notificación
         */
        for (int j = 0; j < NUM_PARAMETERS; j++) {
            
            NSLog(@"Funcion %@ - Patron %@\r", function, [[modelInPanel parametersN] objectAtIndex:j]);
            if ([function rangeOfString:[[modelInPanel parametersN] objectAtIndex:j]                              options:NSCaseInsensitiveSearch].location != NSNotFound){
                [selectParamNField setEnabled:YES];
                paramN = [selectParamNField floatValue];
                break;
            } else {
                [selectParamNField setEnabled:NO];
            }
            
            NSLog(@"Funcion %@ - Patron %@\r", function, [[modelInPanel parametersB] objectAtIndex:j]);
            if ([function rangeOfString:[[modelInPanel parametersB] objectAtIndex:j] options:NSCaseInsensitiveSearch].location != NSNotFound){
                [selectParamBField setEnabled:YES];
                paramB = [selectParamBField floatValue];
                break;
            } else {
                [selectParamBField setEnabled:NO];
            }
            
            NSLog(@"Funcion %@ - Patron %@\r", function, [[modelInPanel parametersC] objectAtIndex:j]);
            if ([function rangeOfString:[[modelInPanel parametersC] objectAtIndex:j] options:NSCaseInsensitiveSearch].location != NSNotFound){
                [selectParamCField setEnabled:YES];
                paramC = [selectParamCField floatValue];
                break;
            } else {
                [selectParamCField setEnabled:NO];
            }
            
        }
        
        NSLog(@"Parámetros introducidos correctamente A:%f B:%f C:%f N:%f\r", paramA, paramB, paramC, paramN);
    }
    
    /*
     *--------- Apariencia ------------
     */
    
    colour = [selectColorGraphicButton color];
    NSLog(@"Apariencia introducida correctamente color: %@\r", colour);
    
    if([name length] != 0 &&
       [function length] != 0 &&
       (
        ([selectParamAField isEnabled] && [selectParamBField isEnabled] && paramA != 0 && paramB != 0) ||
        ([selectParamAField isEnabled] && [selectParamNField isEnabled] && paramA != 0 && paramN != 0) ||
        ([selectParamAField isEnabled] && [selectParamBField isEnabled] && [selectParamCField isEnabled] && paramA != 0 && paramB != 0 && paramC != 0) ||
        ([selectParamAField isEnabled] && paramA != 0) )
       )
    {
        [addGraphicButton setEnabled:YES];
        
    } else {
        [addGraphicButton setEnabled:NO];
    }
    
    
}


/*!
 * @brief  Añade una nueva grafica a la tabla de Parámetros generales
 */
-(IBAction) addNewGraphic:(id)sender
{
    newGraphic = [[GraphicsClass alloc] init];
    
    [newGraphic setFunction:function];
    [newGraphic setFuncName:name];
    [newGraphic setParamA:paramA];
    [newGraphic setParamB:paramB];
    [newGraphic setParamC:paramC];
    [newGraphic setParamN:paramN];
    [newGraphic setColour:colour];
    
    [[modelInPanel arrayListGraphics] addObject:newGraphic];
    NSLog(@"Grafica nueva guardada en tabla\r");
    [listOfCreatedFunctionsTableView reloadData];
    
    [addGraphicButton setEnabled:NO];
    [selectParamBField setEnabled:NO];
    [selectParamNField setEnabled:NO];
    
    [selectListFuncComboBox deselectItemAtIndex:[selectListFuncComboBox indexOfSelectedItem]];
    [selectGraphicNameField setStringValue:@""];
    [selectParamAField setStringValue:@""];
    [selectParamBField setStringValue:@""];
    [selectParamCField setStringValue:@""];
    [selectParamNField setStringValue:@""];
    
    // Envia una notificación al controlador principal con el contenido del arrayDeGraficas del Modelo
    // En cuanto se añada la primera grafica ya estará disponible la opcion de exportar los datos.
    // Cada vez que se añade una grafica nueva envia la nueva grafica al controlador para guardar el contenido de toda la tabla
    
    NSDictionary *notificationInfo = [NSDictionary dictionaryWithObject:[modelInPanel arrayListGraphics]
                                                                 forKey:@"listOfGraphicsToExport"];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:PanelExportGraphicsNotification
                      object:self
                    userInfo:notificationInfo];
    
}


/* --------------------------- ACCIONES PARAMETROS GENERALES ---------------------- */

/*!
 * @brief  Función que es notificada cada vez que se selecciona
 *         una fila de la tabla.
 */
-(void) tableViewSelectionDidChange:(NSNotification *)notification
{
    NSInteger aRowSelected = [listOfCreatedFunctionsTableView selectedRow];
    NSLog(@"Fila seleccionada %ld\r", aRowSelected);
    
    if (aRowSelected != -1){
        [drawGraphicButton setEnabled:YES];
        [modifyGraphicButton setEnabled:YES];
        [deleteGraphicButton setEnabled:YES];
        
        NSMutableArray *array = [modelInPanel arrayListGraphics];
        
        [showFuncField setStringValue:[[array objectAtIndex:aRowSelected] function] ];
        [showNameGraphicField setStringValue:[[array objectAtIndex:aRowSelected] funcName] ];
        NSLog(@"Parametro B: %f\r", paramB);
        [showParamAField setFloatValue:[[array objectAtIndex:aRowSelected] paramA] ];
        [showParamBField setFloatValue:[[array objectAtIndex:aRowSelected] paramB] ];
        [showParamCField setFloatValue:[[array objectAtIndex:aRowSelected] paramC] ];
        [showParamNField setFloatValue:[[array objectAtIndex:aRowSelected] paramN] ];
        [showColorGraphicField setColor:[[array objectAtIndex:aRowSelected] colour] ];
        
        
    } else {
        [drawGraphicButton setEnabled:NO];
        [modifyGraphicButton setEnabled:NO];
        [deleteGraphicButton setEnabled:NO];
        
        [showFuncField setStringValue:@""];
        [showNameGraphicField setStringValue:@""];
        [showParamAField setStringValue:@""];
        [showParamBField setStringValue:@""];
        [showParamCField setStringValue:@""];
        [showParamNField setStringValue:@""];
        [showColorGraphicField setColor: [NSColor blueColor]];
    }
    
}


/*!
 * @brief  Devuelve el objeto del array que corresponde
 *         con la fila seleccionda en la tabla
 */
-(id) tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(NSInteger)row
{
    NSString *cadena = [[[modelInPanel arrayListGraphics] objectAtIndex:row] funcName];
    NSLog(@"Fila %ld - Texto (%@)\r", row, cadena);
    return cadena;
}


/*!
 * @brief  Permite editar y sobreescribir el nombre del objeto
 *         cuya fila ha sido seleccionada en la tabla.
 */
-(void) tableView:(NSTableView *)tableView
   setObjectValue:(nullable id)object
   forTableColumn:(nullable NSTableColumn *)tableColumn
              row:(NSInteger)row
{
    [[modelInPanel arrayListGraphics] setObject:object atIndexedSubscript:row];
    //NSLog(@"Texto Antiguo (%@) - Texto nuevo(%@)\r", cadena, object);
}


/*!
 * @brief  Devuelve el numero de filas de la tabla
 */
-(NSInteger) numberOfRowsInTableView:(NSTableView *)tableView
{
    return [[modelInPanel arrayListGraphics] count];
}

/*!
 * @brief  Función que es notificada cada vez que se escribe
 *         un caracter dentro del textField
 */
-(IBAction) controlTextDidChange:(NSNotification *)obj;
{
    NSString *cadena = [selectGraphicNameField stringValue];
    if ([cadena length] == 0){
        [addGraphicButton setEnabled:NO];
    }
    
}

/*!
 * @brief  Representa la grafica seleccionada en la venta principal
 */
-(IBAction) drawGraphic:(id)sender
{
    
}

/*!
 * @brief  Elimina la grafica seleccionada en la tabla
 */
-(IBAction) deleteGraphic:(id)sender
{
    NSInteger aRowSelected = [listOfCreatedFunctionsTableView selectedRow];
    [listOfCreatedFunctionsTableView abortEditing]; // Orden que deniega la edición al usuario (Es necesrio en el caso en el que el usuario intente editar un campo y pulse el botón eliminar (produce un bug)
    if (aRowSelected == -1)
        return;
    
    [[modelInPanel arrayListGraphics] removeObjectAtIndex:aRowSelected];
    NSLog(@"Cadena eliminada en array en pos %ld\r", aRowSelected);
    [listOfCreatedFunctionsTableView reloadData];
}

/*!
 * @brief  Muestra el panel de Modificación enviando la información correspondiente
 *         al objeto que se desea modificar.
 */
-(IBAction) selectDrawingRange:(id)sender
{
    //NSInteger minX = [minRangeXField integerValue];
    //NSInteger minY = [minRangeYField integerValue];
    //NSInteger maxX = [maxRangeXField integerValue];
    //NSInteger maxY = [maxRangeYField integerValue];
}

/*!
 * @brief  (Si viene de la tabla de Modificacion) Reescribe el contenido del objeto que ha sido modificado
 *         en el panel de Modificación al confirmar su modificación en dicho panel.
 *
 *         (Si viene del panel principal) Recoge la lista de graficas de un fichero
 *         enviada desde el panel principal Controller
 */
-(void) handleNewGraphic:(NSNotification *)aNotification
{
    NSLog(@"Notificacion %@ recibida en handleNewOrExportedGraphic\r", aNotification);
    NSDictionary *notificationInfo = [aNotification userInfo];
    GraphicsClass *graphic = [notificationInfo objectForKey:@"newGraphic"];
    NSArray *array = [notificationInfo objectForKey:@"graphicsExported"];
    
    if (graphic != nil){
        [[modelInPanel arrayListGraphics] setObject:graphic atIndexedSubscript:aRowSelected];
        [listOfCreatedFunctionsTableView reloadData];
    }
    
    if (array != nil){
        [[modelInPanel arrayListGraphics] addObjectsFromArray:array];
        [listOfCreatedFunctionsTableView reloadData];
    }
    
}

/*!
 * @brief
 */


/*!
 * @brief  Muestra el panel de Modificación enviando la información correspondiente
 *         al objeto que se desea modificar.
 */
-(IBAction) showPanel:(id)sender
{
    if(!panelModController)
        panelModController = [[PanelModificationController alloc] init];
    
    NSLog(@"panel %@\r", panelModController);
    [panelModController showWindow:self];
    
    aRowSelected = [listOfCreatedFunctionsTableView selectedRow];
    
    NSLog(@"Fila seleccionada %ld\r", aRowSelected);
    
    if (aRowSelected != -1) {
        NSMutableArray *array = [modelInPanel arrayListGraphics];
        GraphicsClass *graphicToModify = [array objectAtIndex:aRowSelected];
        NSDictionary *notificationInfo = [NSDictionary dictionaryWithObject:graphicToModify
                                                                     forKey:@"graphicToModify"];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:PanelModifyGraphicNotification
                          object:self
                        userInfo:notificationInfo];
    }
    
    [listOfCreatedFunctionsTableView deselectRow:aRowSelected];
}





@end
