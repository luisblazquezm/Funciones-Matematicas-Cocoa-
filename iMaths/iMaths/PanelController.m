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
        //NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        //[nc addObserver:self
               // selector:@selector(handlePanelChange:)
               // name:PanelDisableIndexesFunctionNotification
               // object:nil];
    }
    
    return self;
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

-(IBAction)selectForNewGraphic:(id)sender
{
    static NSString *parametersN[] =
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
    
    static NSString *parametersB[] =
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
    
    // Definición
    NSString *function = [selectListFuncComboBox stringValue];
    NSString *name = [selectGraphicNameField stringValue];
    NSLog(@"Definición introducida correctamente\r");
    
    // Parametros
    
    float A = [selectParamAField floatValue];
    
    /* Hallo los indices del array de funciones cuyas formulas no contienen una 'n'
     * para poder deshabilitar el campo del parámetro 'n' en el controlador PanelController
     * Lo envio a través de un set de indices dentro de un NSDictionary por medio de una Notificación
     */
    for (int i = 0; i < NUM_DEFAULT_FUNCTIONS; i++) {
        for (int j = 0; j < NUM_PARAMETERS; j++) {
            
            if ([function containsString:parametersN[j]]){
                [selectParamNField setEnabled:YES];
                float N = [selectParamNField floatValue];
            } else {
                [selectParamNField setEnabled:NO];
            }
            
            if ([function containsString:parametersB[j]]){
                [selectParamBField setEnabled:YES];
                float B = [selectParamBField floatValue];
            } else {
                [selectParamBField setEnabled:NO];
            }
            
        }
    }
    
    NSLog(@"Parámetros introducidos correctamente\r");
    
    // Apariencia
}

-(IBAction)addNewGraphic:(id)sender
{
    [addGraphicButton setEnabled:YES];
}


/* --------------------------- ACCIONES PARAMETROS GENERALES ---------------------- */

// Si selecciona alguna fila, se habilita el botón eliminar. En caso contrario se deshabilita
-(void) tableViewSelectionDidChange:(NSNotification *)notification
{
    
}


// Añade el contenido del array en la fila correspondiente de la tabla
-(id) tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(NSInteger)row
{
    return nil;
}

// Permite editar los campos de las filas de la tabla
-(void) tableView:(NSTableView *)tableView
   setObjectValue:(nullable id)object
   forTableColumn:(nullable NSTableColumn *)tableColumn
              row:(NSInteger)row
{
    
}

// Devuelve el numero de columnas de la tabla
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return 1;
}

// En cuanto el usuario meta un solo carácter, el boton añadir se hará visible
-(IBAction)controlTextDidChange:(NSNotification *)obj;
{
    
    
}

@end
