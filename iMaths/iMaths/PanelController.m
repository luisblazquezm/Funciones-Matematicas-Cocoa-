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
#import "ParametersNumberFormatter.h"

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

/* NOTIFICACIONES*/

// PanelController -> PanelModificationController (Cuando se modifica una grafica de la lista de graficas de la tabla)
NSString *ModifyGraphicNotification = @"ModifyGraphic";
extern NSString *PanelGraphicModifiedNotification;

// PanelController -> Controller (Cuando se exporta la lista de graficas de la tabla)
// PanelController -> Controller (Cuando se pasa a dibujar la grafica)
NSString *DrawGraphicsNotification = @"DrawGraphics";

NSString *ExportGraphicsNotification = @"ExportGraphics";

// PanelModificationController -> PanelController (Cuando se modifica una grafica de la tabla)
// Controller -> PanelController (Cuando se importa una nueva grafica)
extern NSString *NewGraphicImportedNotification;

extern NSString *SendModelNotification;

/* KEYS */


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
        //modelInPanel = [[PanelModel alloc] init]; // Instancia del Modelo
        //formatter = [[ParametersNumberFormatter alloc] init];
        
        functionSelectedFlag = NO;      // Flag que indica si se ha seleccionado o no una fila del ComboBox
        previousSelectedRow = -1;
        BisEnabled = NO;
        CisEnabled = NO;
        NisEnabled = NO;
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        
        // Observador de la notificación de importación de datos de fichero
        [nc addObserver:self
               selector:@selector(handleNewGraphicImported:)
                   name:NewGraphicImportedNotification
                 object:nil];
        
        // Observador de la notificación de recepción de la instancia del modelo
        [nc addObserver:self
               selector:@selector(handleModelReceived:)
                   name:SendModelNotification
                 object:nil];
        
        // Observador de la notificación de recepción de la grafica modificada
        [nc addObserver:self
               selector:@selector(handleGraphicModified:)
                   name:PanelGraphicModifiedNotification
                 object:nil];

        

    }
    
    return self;
}

/*!
 * @brief  Realiza una operación al cargar el fichero NIB
 */

-(void) awakeFromNib
{

    
    [formatter setLocale:[NSLocale currentLocale]];// this ensures the right separator behavior
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setUsesGroupingSeparator:YES];
    [formatter setDecimalSeparator:@"."];
    
    //[[selectParamAField cell] setFormatter:formatter];
    //[[selectParamBField cell] setFormatter:formatter];
    //[[selectParamCField cell] setFormatter:formatter];
    //[[selectParamNField cell] setFormatter:formatter];

    
    //[selectParamAField setFormatter:formatter];
    //[selectParamBField setFormatter:formatter];
    //[selectParamCField setFormatter:formatter];
    //[selectParamNField setFormatter:formatter];
    
    [selectParamAField setEnabled:NO];
    [selectParamBField setEnabled:NO];
    [selectParamCField setEnabled:NO];
    [selectParamNField setEnabled:NO];
    
    [drawGraphicButton setEnabled:NO];
    [modifyGraphicButton setEnabled:NO];
    [deleteGraphicButton setEnabled:NO];
    
}

/* --------------------------- TRATAMIENTO DE VENTANAS ---------------------- */

/*!
 * @brief  Notifica al usuario del cierre total de la ventana de la aplicacion.
 * @param  sender Objeto ventana.
 * @return BOOL, respuesta del usuario al mensaje de cierre.
 */

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
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
#pragma clang diagnostic pop


/*!
 * @brief  Manejador de inicialización del panel al ser cargado del fichero NIB .
 */
-(void) windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


-(void) handleModelReceived:(NSNotification *)aNotification
{
    NSLog(@"Notificacion %@ recibida en handleModelReceived\r", aNotification);
    NSDictionary *notificationInfo = [aNotification userInfo];
    modelInPanel = [notificationInfo objectForKey:@"model"];
    
    // Inicializa el array del modelo de funciones
    [modelInPanel initializeArrayListFunctions];
    
    // Añade esas funciones al ComboBox
    [selectListFuncComboBox addItemsWithObjectValues:[modelInPanel arrayListFunctions]];
    
}


/*!
 * @brief  (Si viene de la tabla de Modificacion) Reescribe el contenido del objeto que ha sido modificado
 *         en el panel de Modificación al confirmar su modificación en dicho panel.
 *
 *         (Si viene del panel principal) Recoge la lista de graficas de un fichero
 *         enviada desde el panel principal Controller
 */
-(void) handleNewGraphicImported:(NSNotification *)aNotification
{
    NSLog(@"Notificacion %@ recibida en handleNewGraphicImported\r", aNotification);
    NSDictionary *notificationInfo = [aNotification userInfo];
    NSArray *array = [notificationInfo objectForKey:@"graphicsImported"];
    
    if (array != nil){
        [[modelInPanel arrayListGraphics] addObjectsFromArray:array];
        [listOfCreatedFunctionsTableView reloadData];
    }
    
}

-(void) handleGraphicModified:(NSNotification *)aNotification
{
    NSLog(@"Notificacion %@ recibida en handleNewGraphicImported\r", aNotification);
    NSDictionary *notificationInfo = [aNotification userInfo];
    GraphicsClass *graphic = [notificationInfo objectForKey:@"newGraphic"];
    NSInteger row = [modelInPanel rowSelectedToModify];
    
    if (graphic != nil && row != -1) {
        [[modelInPanel arrayListGraphics] setObject:graphic atIndexedSubscript:row];
        [listOfCreatedFunctionsTableView reloadData];
    }
    
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

-(void) deactivateFields
{
    [addGraphicButton setEnabled:NO];
    [selectParamAField setEnabled:NO];
    [selectParamBField setEnabled:NO];
    [selectParamCField setEnabled:NO];
    [selectParamNField setEnabled:NO];
    [selectParamAField setStringValue:@""];
    [selectParamBField setStringValue:@""];
    [selectParamCField setStringValue:@""];
    [selectParamNField setStringValue:@""];
    functionSelectedFlag = NO;
}

- (void) comboBoxSelectionDidChange:(NSNotification *)notification
{
    NSInteger selectedRow = [selectListFuncComboBox indexOfSelectedItem];
    
    if (selectedRow != -1) {
        previousSelectedRow = selectedRow;
        functionSelectedFlag = YES;
    } else {
        [self deactivateFields];
    }
    
    // Si antes de añadir una nueva grafica, se cambia de repente la función en el comboBox
    // se desactivan todos los campos y se ponen en blanco de nuevo para evitar problemas
    if (previousSelectedRow != selectedRow) {
        [self deactivateFields];
    }
    
}


/*!
 * @brief  Añade una nueva grafica a la tabla de Parámetros generales
 */
-(IBAction) addNewGraphic:(id)sender
{

    [modelInPanel createGraphic:function
                       withName:name
                         paramA:paramA
                         paramB:paramB
                         paramC:paramC
                         paramN:paramN
                          color:colour];
  
    NSLog(@"Grafica nueva guardada en tabla\r");
    [listOfCreatedFunctionsTableView reloadData];
    
    BisEnabled = NO;
    CisEnabled = NO;
    NisEnabled = NO;
    
    [addGraphicButton setEnabled:NO];
    [selectParamBField setEnabled:NO];
    [selectParamCField setEnabled:NO];
    [selectParamNField setEnabled:NO];
    
    [selectListFuncComboBox deselectItemAtIndex:[selectListFuncComboBox indexOfSelectedItem]];
    [selectGraphicNameField setStringValue:@""];
    [selectParamAField setStringValue:@""];
    [selectParamBField setStringValue:@""];
    [selectParamCField setStringValue:@""];
    [selectParamNField setStringValue:@""];
    
    /*
     * Envia una notificación al controlador principal con el contenido del arrayDeGraficas del Modelo
     * En cuanto se añada la primera grafica ya estará disponible la opcion de exportar los datos.
     * Cada vez que se añade una grafica nueva envia la nueva grafica al controlador para guardar
     * el contenido de toda la tabla
     */
    
    // Notificación sin contenido
    /*
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:ExportGraphicsNotification
                      object:self
                    userInfo:notificationInfo];
     */
    
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
        [showParamAField setFloatValue:[[array objectAtIndex:aRowSelected] paramA] ];
        [showParamBField setFloatValue:[[array objectAtIndex:aRowSelected] paramB] ];
        [showParamCField setFloatValue:[[array objectAtIndex:aRowSelected] paramC] ];
        [showParamNField setFloatValue:[[array objectAtIndex:aRowSelected] paramN] ];
        [showColorGraphicField takeColorFrom:selectColorGraphicButton];
        
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
    return [modelInPanel countOfArrayListGraphics];
}

-(void) selectFunction
{
    function = [selectListFuncComboBox stringValue];
    NSLog(@"Funcion %@ escogida\r", function);
}

-(void) selectName
{
    name = [selectGraphicNameField stringValue];
    NSLog(@"Nombre Funcion %@\r", name);
}

-(void) selectParameters
{
    // Formateador que no deja introducir palabras salvo numeros float que contengan - o .
    // Si se introduce un - despues de los numeros, varios puntos o varios menos, Estos se ignoran
    NSCharacterSet *charSet = [[NSCharacterSet characterSetWithCharactersInString:@"-1234567890."] invertedSet];
    
    // Creo varios arrays porque si creo uno general para todos los campos, lo que se escribiera en uno de ellos, se escribiría automaticamente en el resto.
    NSArray<NSString*> *arrayParamA = [[selectParamAField stringValue] componentsSeparatedByCharactersInSet:charSet];
        NSArray<NSString*> *arrayParamB = [[selectParamBField stringValue] componentsSeparatedByCharactersInSet:charSet];
        NSArray<NSString*> *arrayParamC = [[selectParamCField stringValue] componentsSeparatedByCharactersInSet:charSet];
        NSArray<NSString*> *arrayParamN = [[selectParamNField stringValue] componentsSeparatedByCharactersInSet:charSet];
    
    // Aplico el formateador de numeros negativos y positivos float a los campos de los parametros
    [selectParamAField setStringValue:[arrayParamA  componentsJoinedByString:@""]];
    [selectParamBField setStringValue:[arrayParamB  componentsJoinedByString:@""]];
    [selectParamCField setStringValue:[arrayParamC  componentsJoinedByString:@""]];
    [selectParamNField setStringValue:[arrayParamN  componentsJoinedByString:@""]];
    
    [selectParamAField setEnabled:YES];
    paramA = [selectParamAField floatValue];
    
    /* A traves de estos bucles for se realiza un busqueda secuencial en el que
     * se va comprobando que la funcion pasada contenga una subcadena que incluya
     * una de las combinaciones para los parametros B ,C o N instanciadas en
     * varios arrays estaticos de parametros que permitan habilitar o deshabilitar los
     * campos de texto de dichos parametros dependiendo si están o no incluidos en la función
     * seleccionada.
     */
    
    
    if (!BisEnabled && !CisEnabled && !NisEnabled) {
        // Habilitación Campo Variable N
        for (int j = 0; j < NUM_PARAMETERS; j++) {
            NSLog(@"Funcion %@ - Patron %@\r", function, [[modelInPanel parametersN] objectAtIndex:j]);
            if ([function rangeOfString:[[modelInPanel parametersN] objectAtIndex:j]                              options:NSCaseInsensitiveSearch].location != NSNotFound) {
                [selectParamNField setEnabled:YES];
                NisEnabled = YES;
                break;
            } else {
                [selectParamNField setEnabled:NO];
            }
            
        }
        
        // Habilitación Campo Variable B
        for (int j = 0; j < NUM_PARAMETERS; j++) {
            NSLog(@"Funcion %@ - Patron %@\r", function, [[modelInPanel parametersB] objectAtIndex:j]);
            if ([function rangeOfString:[[modelInPanel parametersB] objectAtIndex:j] options:NSCaseInsensitiveSearch].location != NSNotFound) {
                [selectParamBField setEnabled:YES];
                BisEnabled = YES;
                break;
            } else {
                [selectParamBField setEnabled:NO];
            }
        }
        
        // Habilitación Campo Variable C
        for (int j = 0; j < NUM_PARAMETERS; j++) {
            NSLog(@"Funcion %@ - Patron %@\r", function, [[modelInPanel parametersC] objectAtIndex:j]);
            if ([function rangeOfString:[[modelInPanel parametersC] objectAtIndex:j] options:NSCaseInsensitiveSearch].location != NSNotFound) {
                [selectParamCField setEnabled:YES];
                CisEnabled = YES;
                break;
            } else {
                [selectParamCField setEnabled:NO];
            }
        }
        
    }// End of if-else
    
    if (BisEnabled)
        paramB = [selectParamBField floatValue];
    
    if (CisEnabled)
        paramC = [selectParamCField floatValue];
    
    if (NisEnabled)
        paramN = [selectParamNField floatValue];
    
    NSLog(@"Parámetros introducidos correctamente A:%f B:%f C:%f N:%f\r", paramA, paramB, paramC, paramN);
}

-(void) selectColour
{
    // LLama al metodo observeValueForKeyPath cada vez que se cambia el color del colorWell
    [selectColorGraphicButton addObserver:self
                               forKeyPath:@"color"
                                  options:0
                                  context:nil];
    
    colour = [selectColorGraphicButton color];
    NSLog(@"Apariencia introducida correctamente color: %@\r", colour);
}

-(void) checkAddGraphicIsAvailable
{
    // Para habilitar el Boton de Añadir tiene que cumplir estas codiciones
    NSLog(@"Nombre: %@ Funcion: %@ ParamA: %f ParamB: %f ParamC: %f ParamN: %f\n",name,
                                                                                  function,
                                                                                  paramA,
                                                                                  paramB,
                                                                                  paramC,
                                                                                  paramN);
    
    if([name length] != 0 &&
       [function length] != 0 &&
       (
        ([selectParamAField isEnabled] && [selectParamBField isEnabled] && ![selectParamCField isEnabled] && paramA != 0 && paramB != 0) ||
        ([selectParamAField isEnabled] && [selectParamNField isEnabled] && paramA != 0 && paramN != 0) ||
        ([selectParamAField isEnabled] && [selectParamBField isEnabled] && [selectParamCField isEnabled] && paramA != 0 && paramB != 0 && paramC != 0)
        ||
        ([selectParamAField isEnabled] && paramA != 0 && ![selectParamBField isEnabled] && ![selectParamCField isEnabled] && ![selectParamNField isEnabled]) )
       )
    {
        [addGraphicButton setEnabled:YES];
    } else {
        [addGraphicButton setEnabled:NO];
    }
}

/*!
 * @brief  Función que es notificada cada vez que se escribe
 *         un caracter dentro del textField
 */
-(IBAction) controlTextDidChange:(NSNotification *)obj;
{

    
    //NSString *regex = @"[+-]?([0-9]+([.][0-9]*)?|[.][0-9]+)";
    //NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    //int lengthField;
    //NSString *mystring;
    
    /*
     *--------- Definicion Funcion ------------
     */
    
    [self selectFunction];
    
    if ([function length] > 0) {
        // Comprueba que no se introduzca una grafica con un nombre vacio
        NSString *cadena = [selectGraphicNameField stringValue];
        if ([cadena length] == 0){
            [addGraphicButton setEnabled:NO];
        }
        
        [self selectName];
        
        /*
         *--------- Parametros ------------
         */
        
        if(functionSelectedFlag){

            [self selectParameters];

        }
        
        /*
         *--------- Apariencia ------------
         */
        
        [self selectColour];
    }

    [self checkAddGraphicIsAvailable];
    
}

/*!
 * @brief  Metodo que es llamado cada vez que se produce un cambio en el color del del outlet 'colorWell'
 */
-(void) observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"color"]){
        colour = [selectColorGraphicButton color];
    }
}

/*!
 * @brief  Manda una notificación al metodo drawRect de la clase "GraphicsView" para poder representar la
 *         grafica seleccionada en la venta principal.
 */
-(IBAction) drawGraphic:(id)sender
{
    float varXMax = 0, varXMin = 0, varYMax = 0, varYMin = 0;
    //NSInteger aRowSelected = [listOfCreatedFunctionsTableView selectedRow];
    NSMutableArray *graphicsToRepresent = [[NSMutableArray alloc] init];
    NSIndexSet *rowsSelected = [[NSIndexSet alloc] init];
    rowsSelected = [listOfCreatedFunctionsTableView selectedRowIndexes];
    
    //NSLog(@"Filas seleccionada %ld\r", [rowsSelected ]);
    NSLog(@"modelInPanel drawIndexes done");
    [modelInPanel arrayOfGraphicToDrawInIndexes:rowsSelected];

        NSLog(@"minX: %f minY: %f maxX: %f maxY: %f",[minRangeXField floatValue],
                                                      [minRangeYField floatValue],
                                                      [maxRangeXField floatValue],
                                                      [maxRangeYField floatValue]);
        
        if ([maxRangeXField floatValue] != 0 ||
            [maxRangeYField floatValue] != 0 ||
            [minRangeXField floatValue] != 0 ||
            [minRangeYField floatValue] != 0){
                varXMax = [maxRangeXField floatValue];
                varXMin = [minRangeXField floatValue];
                varYMax = [maxRangeYField floatValue];
                varYMin = [minRangeYField floatValue];
        }
        
        NSLog(@"VAR minX: %f minY: %f maxX: %f maxY: %f",varXMin,
              varYMin,
              varXMax,
              varYMax);
        
        NSNumber *XMax = [[NSNumber alloc]initWithFloat:varXMax];
        NSNumber *XMin = [[NSNumber alloc]initWithFloat:varXMin];
        NSNumber *YMax = [[NSNumber alloc]initWithFloat:varYMax];
        NSNumber *YMin = [[NSNumber alloc]initWithFloat:varYMin];
        
        [minRangeXField setStringValue:@""];
        [maxRangeXField setStringValue:@""];
        [minRangeYField setStringValue:@""];
        [maxRangeYField setStringValue:@""];
        
        NSDictionary *notificationInfo = [NSDictionary dictionaryWithObjectsAndKeys:graphicsToRepresent,@"graphicsToRepresent",
                                         XMax,@"XMax",
                                         XMin,@"XMin",
                                         YMax,@"YMax",
                                         YMin,@"YMin",
                                         nil];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:DrawGraphicsNotification
                          object:self
                        userInfo:notificationInfo];
        

}

/*!
 * @brief  Elimina la grafica seleccionada en la tabla
 */
-(IBAction) deleteGraphic:(id)sender
{
    NSInteger aRowSelected = [listOfCreatedFunctionsTableView selectedRow];
    // Orden que deniega la edición al usuario (Es necesrio en el caso en el que el usuario intente editar un campo y pulse el botón eliminar (produce un bug)
    [listOfCreatedFunctionsTableView abortEditing];
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
    //varXMin = [minRangeXField integerValue];
    //varYMin = [minRangeYField integerValue];
    //varXMax = [maxRangeXField integerValue];
    //varYMax = [maxRangeYField integerValue];
}


/*!
 * @brief  Muestra el panel de Modificación enviando la información acerca
 *         del objeto que se desea modificar.
 */
-(IBAction) showPanel:(id)sender
{
    if(!panelModController)
        panelModController = [[PanelModificationController alloc] init];
    
    NSLog(@"panel %@\r", panelModController);
    [panelModController showWindow:self];
    
    NSInteger RowSelected = [listOfCreatedFunctionsTableView selectedRow];
    [modelInPanel setRowSelectedToModify:RowSelected];
    
    NSLog(@"Fila seleccionada %ld\r", RowSelected);
    
    if (RowSelected != -1) {
        NSMutableArray *array = [modelInPanel arrayListGraphics];
        GraphicsClass *graphicToModify = [array objectAtIndex:RowSelected];
        NSDictionary *notificationInfo = [NSDictionary dictionaryWithObject:graphicToModify
                                                                     forKey:@"graphicToModify"];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:ModifyGraphicNotification
                          object:self
                        userInfo:notificationInfo];
        
    }
    
    [listOfCreatedFunctionsTableView deselectRow:RowSelected];
}

- (void)dealloc
{
    [selectColorGraphicButton removeObserver:self forKeyPath:@"color"];
}

@end
