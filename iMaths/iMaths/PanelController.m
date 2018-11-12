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

            /* (PanelController -> Controller) */

// Cuando se exporta la lista de graficas de la tabla
NSString *DrawGraphicsNotification = @"DrawGraphics";
// Cuando se pasa a dibujar la grafica
NSString *ExportGraphicsNotification = @"ExportGraphics";

            /* (PanelController -> PanelModificationController) */
                                                      
// Cuando se modifica una grafica de la lista de graficas de la tabla
NSString *SendModelToModificationPanelNotification = @"SendModelToModificationPanel";

            /* (Controller -> PanelController) */

// Cuando se importa una nueva grafica
extern NSString *NewGraphicImportedNotification;
// Cuando se recibe la instancia del modelo del Controlador principal
extern NSString *SendModelNotification;

            /* (PanelModificationController -> PanelController) */

// Cuando se modifica una grafica de la tabla
extern NSString *PanelGraphicModifiedNotification;

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
        name = [[NSString alloc] init];
        function = [[NSString alloc] init];
        paramA = 0;
        paramB = 0;
        paramC = 0;
        paramN = 0;
        colour = [[NSColor alloc] init];
        
        functionSelectedFlag = NO;      
        previousSelectedRow = -1;
        BisEnabled = NO;
        CisEnabled = NO;
        NisEnabled = NO;
        filterEnabled = NO;
        nameNotRepeated = NO;
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        
        // Observador de la notificación de importación de datos de fichero
        [nc addObserver:self
               selector:@selector(handleReloadTable:)
                   name:NewGraphicImportedNotification
                 object:nil];
        
        // Observador de la notificación de recepción de la instancia del modelo
        [nc addObserver:self
               selector:@selector(handleModelReceived:)
                   name:SendModelNotification
                 object:nil];
        
        // Observador de la notificación de recepción de la grafica modificada
        [nc addObserver:self
               selector:@selector(handleReloadTable:)
                   name:PanelGraphicModifiedNotification
                 object:nil];
    }
    
    return self;
}

/*!
 * @brief  Realiza una operación al cargar el fichero NIB.En este caso, desactiva todos los botones y casillas
 *         de los parametros
 */
-(void) awakeFromNib
{
    // Los botones de progreso incialmente en Rojo
    [functionDefProgressButton setImage:[NSImage imageNamed:NSImageNameStatusUnavailable]];
    [parametersProgressButton setImage:[NSImage imageNamed:NSImageNameStatusUnavailable]];
    [appearanceProgressButton setImage:[NSImage imageNamed:NSImageNameStatusUnavailable]];

    // Deshabilitados los campos y botones principales
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
#pragma clang diagnostic push  // <----- Para hacer desaparecer  los mensajes de deprecated
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

/*!
 * @brief  Recoge la instancia del modelo inicializada en la ventana principal Controller.
 */
-(void) handleModelReceived:(NSNotification *)aNotification
{
    NSLog(@"Notificacion %@ recibida en handleModelReceived\r", aNotification);
    NSDictionary *notificationInfo = [aNotification userInfo];
    modelInPanel = [notificationInfo objectForKey:@"model"];
    
    if (modelInPanel == nil) {
        NSLog(@"PanelController:handleModelReceived: Instancia del modelo recibida es nil");
        return;
    }
    
    // Inicializa el array del modelo de funciones
    [modelInPanel initializeArrayListFunctions];
    
    // Añade esas funciones al ComboBox
    [selectListFuncComboBox addItemsWithObjectValues:[modelInPanel arrayListFunctions]];
    
    /*
     * Añade a cada columna (en nuestro caso solo 1) el descriptor de ordenamiento para ordenar los
     * nombres de las graficas por orden alfabetico
     */
    for (NSTableColumn *column in [listOfCreatedFunctionsTableView tableColumns]) {
        NSLog(@"Coliumn");
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"funcName"
                                                                         ascending:YES
                                                                          selector:@selector(compare:)];
        [column setSortDescriptorPrototype:sortDescriptor];
    }
    
}

/*!
 * @brief  Recibe la notificación de que la grafica ha sido modificada
 *         o de una lista de graficas importadas de fichero para
 *         recargar el contenido de la tabla.
 */
-(void) handleReloadTable:(NSNotification *)aNotification
{
    NSLog(@"Notificacion %@ recibida en handleNewGraphicImported\r", aNotification);
    [listOfCreatedFunctionsTableView reloadData];
    
}

/* --------------------------- ACCIONES DEFINICION GRAFICA ---------------------- */

/*!
 * @brief  Desactiva los campos necesarios cuando se añade una nueva grafica en la tabla.
 */
-(void) deactivateFields
{
    // Flags desactivados
    BisEnabled = NO;
    CisEnabled = NO;
    NisEnabled = NO;
    functionSelectedFlag = NO;
    nameNotRepeated = NO;
    
    // Desactivación de botones y campos
    [addGraphicButton setEnabled:NO];
    [selectParamAField setEnabled:NO];
    [selectParamBField setEnabled:NO];
    [selectParamCField setEnabled:NO];
    [selectParamNField setEnabled:NO];
    
    // ComboBox deseleccionado
    [selectListFuncComboBox deselectItemAtIndex:[selectListFuncComboBox indexOfSelectedItem]];
    
    // Campos vacios
    [selectGraphicNameField setStringValue:@""];
    [selectParamAField setStringValue:@""];
    [selectParamBField setStringValue:@""];
    [selectParamCField setStringValue:@""];
    [selectParamNField setStringValue:@""];
    [selectColorGraphicButton setColor:[NSColor blueColor]];
    
    // Desactivo los botones visuales
    [functionDefProgressButton setImage:[NSImage imageNamed:NSImageNameStatusUnavailable]];
    [functionDefLabel setHidden:YES];
    [parametersProgressButton setImage:[NSImage imageNamed:NSImageNameStatusUnavailable]];
    [parametersLabel setHidden:YES];
    [appearanceProgressButton setImage:[NSImage imageNamed:NSImageNameStatusUnavailable]];
    [appearanceLabel setHidden:YES];
    [limitsLabel setHidden:YES];
}

/*!
 * @brief Metodo notificado cada vez que se selecciona un elemento dentro del ComboBox
 */
- (void) comboBoxSelectionDidChange:(NSNotification *)notification
{
    NSInteger selectedRow = [selectListFuncComboBox indexOfSelectedItem];
    
    if (selectedRow != -1) {
        previousSelectedRow = selectedRow;
        functionSelectedFlag = YES;
    } else {
        [self deactivateFields];
    }
    
    /*
     * Si antes de añadir una nueva grafica, se cambia de repente la función en el comboBox
     * se desactivan todos los campos y se ponen en blanco de nuevo para evitar problemas
     */
    if (previousSelectedRow != selectedRow) {
        [self deactivateFields];
    }
    
}


/*!
 * @brief  Recoge la funcion seleccionada en el ComboBox
 */
-(void) selectFunction
{
    function = [selectListFuncComboBox objectValueOfSelectedItem];
    NSLog(@"Funcion %@ escogida\r", function);

}

/*!
 * @brief  Recoge el nombre introducido para la gráfica
 */
-(void) selectName
{
    name = [selectGraphicNameField stringValue];
    
    // Llamo al método de la clase PanelModel para identificar la existencia del nombre introducido
    if ([modelInPanel containsName:name]) {
        [functionDefProgressButton setImage:[NSImage imageNamed:NSImageNameStatusUnavailable]];
        [functionDefLabel setHidden:NO];
        [functionDefLabel setTextColor:[NSColor redColor]];
        [functionDefLabel setStringValue:@"Nombre de Grafica Ya Existente"];
        nameNotRepeated = NO;
    } else {
        nameNotRepeated = YES;
    }
    
    [functionDefLabel setTextColor:[NSColor blackColor]];
    NSLog(@"Nombre Funcion %@\r", name);
}

/*!
 * @brief  Formatea la entrada en los textFields para que solo se pueda introducir
 *         numeros reales positivos y negativos.
 */
-(void) fomatterOnlyRealNumbers
{
    /*
     * Formateador que no deja introducir palabras salvo numeros float que contengan - o .
     * Si se introduce un - despues de los numeros, varios puntos o varios menos, Estos se ignoran
     */
    NSCharacterSet *charSet = [[NSCharacterSet characterSetWithCharactersInString:@"-1234567890."] invertedSet];
    
    /*
     * Creo varios arrays porque si creo uno general para todos los campos,
     * lo que se escribiera en uno de ellos, se escribiría automaticamente en el resto.
     */
    NSArray<NSString*> *arrayParamA = [[selectParamAField stringValue]
                                       componentsSeparatedByCharactersInSet:charSet];
    NSArray<NSString*> *arrayParamB = [[selectParamBField stringValue]
                                       componentsSeparatedByCharactersInSet:charSet];
    NSArray<NSString*> *arrayParamC = [[selectParamCField stringValue]
                                       componentsSeparatedByCharactersInSet:charSet];
    NSArray<NSString*> *arrayParamN = [[selectParamNField stringValue]
                                       componentsSeparatedByCharactersInSet:charSet];
    
    NSArray<NSString*> *arrayXMin = [[minRangeXField stringValue]
                                     componentsSeparatedByCharactersInSet:charSet];
    NSArray<NSString*> *arrayXMax = [[maxRangeXField stringValue]
                                     componentsSeparatedByCharactersInSet:charSet];
    NSArray<NSString*> *arrayYMin = [[minRangeYField stringValue]
                                     componentsSeparatedByCharactersInSet:charSet];
    NSArray<NSString*> *arrayYMax = [[maxRangeYField stringValue]
                                     componentsSeparatedByCharactersInSet:charSet];
    
    // Aplico el formateador de numeros negativos y positivos float a los campos de los parametros
    [selectParamAField setStringValue:[arrayParamA  componentsJoinedByString:@""]];
    [selectParamBField setStringValue:[arrayParamB  componentsJoinedByString:@""]];
    [selectParamCField setStringValue:[arrayParamC  componentsJoinedByString:@""]];
    [selectParamNField setStringValue:[arrayParamN  componentsJoinedByString:@""]];
    
    // Aplico el formateador de numeros negativos y positivos float a los campos de los limites
    [minRangeXField setStringValue:[arrayXMin  componentsJoinedByString:@""]];
    [maxRangeXField setStringValue:[arrayXMax  componentsJoinedByString:@""]];
    [minRangeYField setStringValue:[arrayYMin  componentsJoinedByString:@""]];
    [maxRangeYField setStringValue:[arrayYMax  componentsJoinedByString:@""]];
    
    NSLog(@"Formateador aplicado");
}

/*!
 * @brief  Recoge los parametros introducidos para A y B,C o N (si tocan).
 */
-(void) selectParameters
{
    [self fomatterOnlyRealNumbers];
    
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

/*!
 * @brief  Recoge el color seleccionado para la grafica o el color por defecto.
 */
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

/*!
 * @brief  Función que es notificada cada vez que se escribe
 *         un caracter dentro del textField (Controla la introduccion de parametros de la grafica)
 */
-(IBAction) controlTextDidChange:(NSNotification *)obj;
{
    
    /*
     *--------- Definicion Funcion ------------
     */
    
    if ([obj object] == searchField) {
        NSLog(@"Llamando a applyFilter");
        
        // LLamada al metodo de filtrado de la tabla
        [self applyFilterWithString:[searchField stringValue]];
        
    } else if ([obj object] == maxRangeXField || [obj object] == minRangeXField
               || [obj object] == maxRangeYField || [obj object] == minRangeYField) {
        [self selectLimits];
    } else {
        
        [self selectFunction];
        
        if ([function length] > 0) {
            
            // Progreso parcial (Apariencia amarilla)
            [functionDefProgressButton setImage:[NSImage imageNamed:NSImageNameStatusPartiallyAvailable]];
            
            [self selectName];
            
            // Se activa en comboBoxSelectionDidChange
            if(functionSelectedFlag) {
                
                [self selectParameters];
                
                if (nameNotRepeated) {
                    // Progreso parcial (Apariencia amarilla)
                    [functionDefProgressButton setImage:[NSImage imageNamed:NSImageNameStatusAvailable]];
                    [functionDefLabel setHidden:NO];
                    [functionDefLabel setStringValue:@"Función y Nombre introducidos"];
                }
                
            }
            
            // Progreso parcial (Apariencia amarilla)
            [parametersProgressButton setImage:[NSImage imageNamed:NSImageNameStatusPartiallyAvailable]];
            
            [self selectColour];
            
        } else {
            [functionDefProgressButton setImage:[NSImage imageNamed:NSImageNameStatusPartiallyAvailable]];
            [functionDefLabel setHidden:NO];
            [functionDefLabel setStringValue:@"¡La función es lo primero!"];
            [selectGraphicNameField setStringValue:@""];
        }
        
        [self checkAddGraphicIsAvailable];
    }
    
}


/*!
 * @brief  Comprueba que todos los datos introducidos para la creación de la grafica han sido
 *         introducidos
 */
-(void) checkAddGraphicIsAvailable
{
    NSLog(@"Nombre: %@ Funcion: %@ ParamA: %f ParamB: %f ParamC: %f ParamN: %f\n",name,
          function,
          paramA,
          paramB,
          paramC,
          paramN);
    
    // Tienen que cumplirse los parametros para habilitar el boton 'Añadir'
    if([name length] != 0 &&
       [function length] != 0 &&
       nameNotRepeated &&
       (
        ([selectParamAField isEnabled] && [selectParamBField isEnabled] && ![selectParamCField isEnabled] && paramA != 0 && paramB != 0) ||
        ([selectParamAField isEnabled] && [selectParamNField isEnabled] && paramA != 0 && paramN != 0) ||
        ([selectParamAField isEnabled] && [selectParamBField isEnabled] && [selectParamCField isEnabled] && paramA != 0 && paramB != 0 && paramC != 0)
        ||
        ([selectParamAField isEnabled] && paramA != 0 && ![selectParamBField isEnabled] && ![selectParamCField isEnabled] && ![selectParamNField isEnabled]) )
       )
    {
        // Mensaje de progreso de los parámetros
        [parametersProgressButton setImage:[NSImage imageNamed:NSImageNameStatusAvailable]];
        [parametersLabel setHidden:NO];
        [parametersLabel setStringValue:@"Parametros introducidos"];
        
        // Mensaje de progreso del color
        [appearanceProgressButton setImage:[NSImage imageNamed:NSImageNameStatusAvailable]];
        [appearanceLabel setHidden:NO];
        [appearanceLabel setStringValue:@"Color por defecto utilizado"];
        
        [addGraphicButton setEnabled:YES];
    } else {
        [parametersProgressButton setImage:[NSImage imageNamed:NSImageNameStatusUnavailable]];
        [parametersLabel setHidden:YES];
        
        [appearanceProgressButton setImage:[NSImage imageNamed:NSImageNameStatusUnavailable]];
        [appearanceLabel setHidden:YES];
        
        // Si no se cumplen los parametros mantengo en botón de añadir gráfica deshabilitado
        [addGraphicButton setEnabled:NO];
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

    [self deactivateFields];

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
        
        // Si se selecciona una fila sus parámetros son mostrados en los campos de información
        [showFuncField setStringValue:[[array objectAtIndex:aRowSelected] function] ];
        [showNameGraphicField setStringValue:[[array objectAtIndex:aRowSelected] funcName] ];
        [showParamAField setFloatValue:[[array objectAtIndex:aRowSelected] paramA] ];
        [showParamBField setFloatValue:[[array objectAtIndex:aRowSelected] paramB] ];
        [showParamCField setFloatValue:[[array objectAtIndex:aRowSelected] paramC] ];
        [showParamNField setFloatValue:[[array objectAtIndex:aRowSelected] paramN] ];
        [showColorGraphicField setColor:[[array objectAtIndex:aRowSelected] colour]];
        
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
    NSString *cadena = [[NSString alloc] init];
    
    if (filterEnabled) {
        cadena = [[[modelInPanel arrayFilteredGraphics] objectAtIndex:row] funcName];
        return cadena;
    } else {
        cadena = [[[modelInPanel arrayListGraphics] objectAtIndex:row] funcName];
        NSLog(@"Fila %ld - Texto (%@)\r", row, cadena);
        return cadena;
    }

}

/*!
 * @brief  Aplica a la tabla un descriptor de ordenamiento (en nuestro caso nombres por orden
 *         alfabético) para una o varias columnas
 */
-(void) tableView:(NSTableView *)tableView
sortDescriptorsDidChange:(NSArray<NSSortDescriptor *> *)oldDescriptors
{
    NSMutableArray *array = [modelInPanel arrayListGraphics];
    if (array == nil)
        NSLog(@"PanelController:sortDescriptorDidChange: El array es nil");
    
    if ([modelInPanel countOfArrayListGraphics] > 0){
        [array sortUsingDescriptors:[tableView sortDescriptors]];
        [listOfCreatedFunctionsTableView reloadData];
        NSLog(@"SortDescriptor implementado");
    }

    

}

/*!
 * @brief  Devuelve el numero de filas de la tabla
 */
-(NSInteger) numberOfRowsInTableView:(NSTableView *)tableView
{
    /*
     * Devuelve el número de filas dependiendo si el usuario está filtrando
     * los nombres de las gráficas a través de la barra de búsqueda o no.
     */
    if (filterEnabled && [modelInPanel arrayFilteredGraphics] != nil) {
        return [[modelInPanel arrayFilteredGraphics] count];
    } else {
        return [modelInPanel countOfArrayListGraphics];
    }
}

/*!
 * @brief  Comprueba que los limites que se introduzcan cumplan los requisitos propuestos
 */
-(void) selectLimits
{
    NSLog(@"Seleccionando los limites");
    
    // Numeros reales positivos o negativos
    [self fomatterOnlyRealNumbers];
    
    /*
     * Si los rangos se cambian de valor no podrán tener el máximo y el mínimo con
     * el mismo valor porque la gráfica no se mostraría.
     * Por defecto si no se añade nada será 0.
     */
    
    if ([maxRangeYField floatValue] == [minRangeYField floatValue] && [minRangeYField floatValue] != 0 && [maxRangeYField floatValue] != 0) {
        NSLog(@"Y iguales");
        [limitsLabel setHidden:NO];
        [limitsLabel setTextColor:[NSColor redColor]];
        [limitsLabel setStringValue:@"Valores minimo y maximo de Y coinciden"];
        [maxRangeYField setStringValue:@""];
        return;
    }
    
    if ([maxRangeXField floatValue] == [minRangeXField floatValue] && [minRangeXField floatValue] != 0 && [maxRangeXField floatValue] != 0) {
        NSLog(@"X iguales");
        [limitsLabel setHidden:NO];
        [limitsLabel setTextColor:[NSColor redColor]];
        [limitsLabel setStringValue:@"Valores minimo y maximo de X coinciden"];
        [maxRangeXField setStringValue:@""];
        return;
    }
    
    // El valor del limite minimo tiene que ser menor que el valor del limite máximo
    
    if ([maxRangeYField floatValue] < [minRangeYField floatValue]) {
        NSLog(@"Y errones (mayor que otro)");
        [limitsLabel setHidden:NO];
        [limitsLabel setTextColor:[NSColor redColor]];
        [limitsLabel setStringValue:@"El valor de Y maximo debe ser mayor que el valor de Y minimo"];
        [maxRangeYField setStringValue:@""];
        return;
    }
    
    if ([maxRangeXField floatValue] < [minRangeXField floatValue]) {
        NSLog(@"X errones (mayor que otro)");
        [limitsLabel setHidden:NO];
        [limitsLabel setTextColor:[NSColor redColor]];
        [limitsLabel setStringValue:@"El valor de X maximo debe ser mayor que el valor de X minimo"];
        [maxRangeXField setStringValue:@""];
        return;
    }
    
    [limitsLabel setTextColor:[NSColor greenColor]];
    [limitsLabel setStringValue:@"Limites correctos"];
}


/*!
 * @brief  Metodo que filtra en la tabla las graficas que coincidan con la cadena
 *         introducida en la barra de búsqueda.
 */
-(void) applyFilterWithString:(NSString *)filter
{
    NSArray *array = [[NSArray alloc] init];
    NSMutableArray *mutArray = [[NSMutableArray alloc] init];
    
    if ([filter length] > 0) {
        NSLog(@"Filtrado mayor que 0");
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"self.funcName CONTAINS[cd] %@", filter];
        NSLog(@"Predicado correcto");
        array = [[modelInPanel arrayListGraphics] filteredArrayUsingPredicate:filterPredicate];
        filterEnabled = YES;
    } else {
        NSLog(@"NO hay filtrado");
        array = [modelInPanel arrayListGraphics];
        filterEnabled = NO;
    }
    
    if (array != nil){
        mutArray = [array mutableCopy];
        [modelInPanel setArrayFilteredGraphics:mutArray];
        [listOfCreatedFunctionsTableView reloadData];
        NSLog(@"Filtro ReloadData realizado");
    } else {
        NSLog(@"PanelController:applyFilterWithString:El array de graficas filtradas es nil");
    }

}

/*!
 * @brief  Metodo que es llamado cada vez que se produce un cambio en el color del del outlet
 *         'colorWell'
 */
-(void) observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"color"]){
        colour = [selectColorGraphicButton color];
        [appearanceLabel setStringValue:@"Color introducido utilizado"];
    }
}

/*!
 * @brief  Manda una notificación al metodo drawRect de la clase "GraphicsView" para poder representar
 *         la grafica seleccionada en la venta principal.
 */
-(IBAction) drawGraphic:(id)sender
{
    float varXMax = 0, varXMin = 0, varYMax = 0, varYMin = 0;
    NSIndexSet *rowsSelected = [listOfCreatedFunctionsTableView selectedRowIndexes];
    
    NSLog(@"Enviando notificación para dibujar");
    [limitsLabel setHidden:YES];
    
    // Guarda las graficas que se van a dibujar
    [modelInPanel arrayOfGraphicToDrawInIndexes:rowsSelected];
        
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
    
        // Elimino el contenido de los campos de los limites
        [minRangeXField setStringValue:@""];
        [maxRangeXField setStringValue:@""];
        [minRangeYField setStringValue:@""];
        [maxRangeYField setStringValue:@""];
    
        NSNumber *XMax = [[NSNumber alloc]initWithFloat:varXMax];
        NSNumber *XMin = [[NSNumber alloc]initWithFloat:varXMin];
        NSNumber *YMax = [[NSNumber alloc]initWithFloat:varYMax];
        NSNumber *YMin = [[NSNumber alloc]initWithFloat:varYMin];
    
        NSDictionary *notificationInfo = [NSDictionary dictionaryWithObjectsAndKeys:XMax,@"XMax",
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
    NSIndexSet *rowsSelected = [[NSIndexSet alloc] init];
    rowsSelected = [listOfCreatedFunctionsTableView selectedRowIndexes];
    /*
     * Orden que deniega la edición al usuario (Es necesrio en el caso en el que
     * el usuario intente editar un campo y pulse el botón eliminar (produce un bug)
     */
    [listOfCreatedFunctionsTableView abortEditing];
    [modelInPanel deleteGraphicAtIndexes:rowsSelected];
    NSLog(@"Cadena/s eliminada/s en array\r");
    [listOfCreatedFunctionsTableView reloadData];
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
    NSLog(@"Fila seleccionada %ld\r", RowSelected);
    
    // Tambien envio la instancia del modelo al panel de Modificaciones para el ComboBox
    if (RowSelected != -1) {
        // Se guarda el indice de la gráfica a modificar en el modelo
        [modelInPanel setRowSelectedToModify:RowSelected];
        
        availabilityB = [[NSNumber alloc]initWithBool:BisEnabled];
        availabilityC  = [[NSNumber alloc]initWithBool:CisEnabled];
        availabilityN  = [[NSNumber alloc]initWithBool:NisEnabled];
        
        NSDictionary *notificationInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                          modelInPanel,@"modelInPanel",
                                          availabilityB,@"BisEnabled",
                                          availabilityC,@"CisEnabled",
                                          availabilityN,@"NisEnabled",
                                          nil];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:SendModelToModificationPanelNotification
                          object:self
                        userInfo:notificationInfo];
        
    }
    
    [listOfCreatedFunctionsTableView deselectRow:RowSelected];
}

/*!
 * @brief  Elimina el registro de objetos instanciados.
 */
-(void) dealloc
{
    [selectColorGraphicButton removeObserver:self forKeyPath:@"color"];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    
    name = nil;
    function = nil;
    colour = nil;
}


@end
