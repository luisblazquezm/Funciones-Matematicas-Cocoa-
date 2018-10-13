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
extern NSString *PanelDisableIndexesFunctionNotification;

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
        newGraphic = [[GraphicsClass alloc] init];
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


-(IBAction)addNewGraphic:(id)sender
{
    NSLog(@"Activar boton: nombre(%ld), function(%ld), paramA(%f), paramB(%f), paramN(%f)\r",
          [[newGraphic funcName] length],
          [[newGraphic function] length],
          [newGraphic paramA],
          [newGraphic paramB],
          [newGraphic paramN]);
    
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
    
    [newGraphic setFunction:[selectListFuncComboBox stringValue]];
    NSLog(@"Funcion %@ escogida\r", [newGraphic function]);
    
    [newGraphic setFuncName:[selectGraphicNameField stringValue]];
    NSLog(@"Nombre Funcion %@\r", [newGraphic funcName]);
    
    /*
     *--------- Parametros ------------
     */
    
    if([[newGraphic function] length] != 0){
        [selectParamAField setEnabled:YES];
        [newGraphic setParamA:[selectParamAField floatValue]];
        
        /* Hallo los indices del array de funciones cuyas formulas no contienen una 'n'
         * para poder deshabilitar el campo del parámetro 'n' en el controlador PanelController
         * Lo envio a través de un set de indices dentro de un NSDictionary por medio de una Notificación
         */
        for (int j = 0; j < NUM_PARAMETERS; j++) {
            
            NSLog(@"Funcion %@ - Patron %@\r",[newGraphic function],parametersN[j]);
            if ([[newGraphic function] rangeOfString:parametersN[j] options:NSCaseInsensitiveSearch].location != NSNotFound){
                [selectParamNField setEnabled:YES];
                [newGraphic setParamN:[selectParamNField floatValue]];
                break;
            } else {
                [selectParamNField setEnabled:NO];
            }
            
            NSLog(@"Funcion %@ - Patron %@\r",[newGraphic function],parametersB[j]);
            if ([[newGraphic function] rangeOfString:parametersB[j] options:NSCaseInsensitiveSearch].location != NSNotFound){
                [selectParamBField setEnabled:YES];
                [newGraphic setParamB:[selectParamBField floatValue]];
                break;
            } else {
                [selectParamBField setEnabled:NO];
            }
            
        }
        
        NSLog(@"Parámetros introducidos correctamente A:%f B:%f N:%f\r", [newGraphic paramA], [newGraphic paramB], [newGraphic paramN]);
    }
    
    /*
     *--------- Apariencia ------------
     */
    
    [newGraphic setColour:[selectColorGraphicButton color]];
    NSLog(@"Apariencia introducida correctamente color: %@\r", [newGraphic colour]);
    
    if([[newGraphic funcName] length] != 0 &&
       [[newGraphic function] length] != 0 &&
       (
        ([selectParamAField isEnabled] && [selectParamBField isEnabled] && [newGraphic paramA] != 0 && [newGraphic paramB] != 0) ||
        ([selectParamAField isEnabled] && [selectParamNField isEnabled] && [newGraphic paramA] != 0 && [newGraphic paramN] != 0) ||
        ([selectParamAField isEnabled] && [newGraphic paramA] != 0) )
       )
    {
        [addGraphicButton setEnabled:YES];
        [[modelInPanel arrayListGraphics] addObject:newGraphic];
        NSLog(@"Grafica nueva guardada en tabla\r");
        [listOfCreatedFunctionsTableView reloadData];
    } else {
        [addGraphicButton setEnabled:NO];
    }

}


/* --------------------------- ACCIONES PARAMETROS GENERALES ---------------------- */

// Si selecciona alguna fila, se habilita el botón eliminar. En caso contrario se deshabilita
-(void) tableViewSelectionDidChange:(NSNotification *)notification
{
    NSInteger aRowSelected = [listOfCreatedFunctionsTableView selectedRow];
    if (aRowSelected != -1){
        [drawGraphicButton setEnabled:YES];
        [modifyGraphicButton setEnabled:YES];
        [deleteGraphicButton setEnabled:YES];
    } else {
        [drawGraphicButton setEnabled:NO];
        [modifyGraphicButton setEnabled:NO];
        [deleteGraphicButton setEnabled:NO];
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

/* CAMPO NO EDITABLE, HAY QUE DARLE AL BOTON MODIFICAR
// Permite editar los campos de las filas de la tabla
-(void) tableView:(NSTableView *)tableView
   setObjectValue:(nullable id)object
   forTableColumn:(nullable NSTableColumn *)tableColumn
              row:(NSInteger)row
{
    
}
*/

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

@end
