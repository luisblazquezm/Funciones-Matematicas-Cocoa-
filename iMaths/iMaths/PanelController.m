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
 *
 */


@interface PanelController ()

@end

@implementation PanelController

//NSString *PanelChangeTableNotification = @"PanelChangeTable";
//extern NSString *PanelDisableIndexesFunctionNotification;

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
-(instancetype)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self){
        NSLog(@"En init Panel");
        modelInPanel = [[PanelModel alloc] init];
        //NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        //[nc addObserver:self
               // selector:@selector(handlePanelChange:)
               // name:PanelDisableIndexesFunctionNotification
               // object:nil];
    }
    
    return self;
}

/*!
 * @brief  Realiza una operación al cargar el fichero NIB
 */

- (void)awakeFromNib
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
-(BOOL)windowShouldClose:(NSWindow *)sender
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
        [NSApp terminate:self];
    return YES;
    
}

/*!
 * @brief  Manejador de inicialización del panel al ser cargado del fichero NIB .
 */
- (void)windowDidLoad {
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


-(IBAction)selectNewGraphic:(id)sender
{
    
    NSString *parametersN[] =
    {
        @"^n",
        @"n^",
        @"n*",
        @"*n",
        @"n+",
        @"+n",
        @"-n",
        @"n-",
        @"n/",
        @"/n"
    };
    
    NSString *parametersB[] =
    {
        @"^b",
        @"b^",
        @"b*",
        @"*b",
        @"b+",
        @"+b",
        @"-b",
        @"b-",
        @"b/",
        @"/b"
    };
    
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
            
            NSLog(@"Funcion %@ - Patron %@\r", function, parametersN[j]);
            if ([function rangeOfString:parametersN[j] options:NSCaseInsensitiveSearch].location != NSNotFound){
                [selectParamNField setEnabled:YES];
                paramN = [selectParamNField floatValue];
                break;
            } else {
                [selectParamNField setEnabled:NO];
            }
            
            NSLog(@"Funcion %@ - Patron %@\r", function, parametersB[j]);
            if ([function rangeOfString:parametersB[j] options:NSCaseInsensitiveSearch].location != NSNotFound){
                [selectParamBField setEnabled:YES];
                paramB = [selectParamBField floatValue];
                break;
            } else {
                [selectParamBField setEnabled:NO];
            }
            
        }
        
        NSLog(@"Parámetros introducidos correctamente A:%f B:%f N:%f\r", paramA, paramB, paramN);
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
        ([selectParamAField isEnabled] && paramA != 0) )
       )
    {
        [addGraphicButton setEnabled:YES];
        
    } else {
        [addGraphicButton setEnabled:NO];
    }
    

}

-(IBAction)addNewGraphic:(id)sender
{
    newGraphic = [[GraphicsClass alloc] init];
    
    [newGraphic setFunction:function];
    [newGraphic setFuncName:name];
    [newGraphic setParamA:paramA];
    [newGraphic setParamB:paramB];
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
    [selectParamNField setStringValue:@""];
    
}


/* --------------------------- ACCIONES PARAMETROS GENERALES ---------------------- */

// Si selecciona alguna fila, se habilita el botón eliminar. En caso contrario se deshabilita
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
        [showParamNField setStringValue:@""];
        [showColorGraphicField setColor: [NSColor blueColor]];
    }
     
}


// Añade el contenido del array en la fila correspondiente de la tabla
-(id) tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(NSInteger)row
{
    NSString *cadena = [[[modelInPanel arrayListGraphics] objectAtIndex:row] funcName];
    NSLog(@"Fila %ld - Texto (%@)\r", row, cadena);
    return cadena;
}


// Permite editar los campos de las filas de la tabla
-(void) tableView:(NSTableView *)tableView
   setObjectValue:(nullable id)object
   forTableColumn:(nullable NSTableColumn *)tableColumn
              row:(NSInteger)row
{
    GraphicsClass *grafic = [[modelInPanel arrayListGraphics] objectAtIndex:row];
    [[modelInPanel arrayListGraphics] setObject:object atIndexedSubscript:row];
    //NSLog(@"Texto Antiguo (%@) - Texto nuevo(%@)\r", cadena, object);
}


// Devuelve el numero de columnas de la tabla
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [[modelInPanel arrayListGraphics] count];
}

// En cuanto el usuario meta un solo carácter, el boton añadir se hará visible
-(IBAction)controlTextDidChange:(NSNotification *)obj;
{
    NSString *cadena = [selectGraphicNameField stringValue];
    if ([cadena length] == 0){
        [addGraphicButton setEnabled:NO];
    }
    
}

-(IBAction)drawGraphic:(id)sender
{
    
}

-(IBAction)modifyGraphic:(id)sender
{
    
}

-(IBAction)showPanel:(id)sender
{
    if(!panelModController)
        panelModController = [[PanelModificationController alloc] init];
    
    NSLog(@"panel %@\r", panelModController);
    [panelModController showWindow:self];
}

-(IBAction)deleteGraphic:(id)sender
{
    NSInteger aRowSelected = [listOfCreatedFunctionsTableView selectedRow];
    [listOfCreatedFunctionsTableView abortEditing]; // Orden que deniega la edición al usuario (Es necesrio en el caso en el que el usuario intente editar un campo y pulse el botón eliminar (produce un bug)
    if (aRowSelected == -1)
        return;
    
    [[modelInPanel arrayListGraphics] removeObjectAtIndex:aRowSelected];
    NSLog(@"Cadena eliminada en array en pos %ld\r", aRowSelected);
    [listOfCreatedFunctionsTableView reloadData];
}

-(IBAction)selectDrawingRange:(id)sender
{
    NSInteger minX = [minRangeXField integerValue];
    NSInteger minY = [minRangeYField integerValue];
    NSInteger maxX = [maxRangeXField integerValue];
    NSInteger maxY = [maxRangeYField integerValue];
}

@end
