//
//  PanelController.m
//  iMaths
//
//  Created by Luis Blazquez Miñambres on 12/10/18.
//  Copyright © 2018 Luis Blazquez Miñambres. All rights reserved.
//

#import "PanelController.h"
#import "PanelModel.h"
#import "FunctionClass.h"

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

/* --------------------------- INICIALIZADORES ---------------------- */

/*!
* @brief  Inicializa todas las variables de instancias declaradass en fichero .h .
* @return id, puntero genérico.
*/
-(id)init
{
    if (![super initWithWindowNibName:@"PanelWindowController"])
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

-(IBAction)selectForNewFunction:(id)sender
{
    FunctionClass *newFunction;
    
    // Definición
    [newFunction setFormula:[selectListFuncComboBox stringValue]];
    [newFunction setName:[selectFuncNameField stringValue]];
    
    // Parametros
    if (sender == selectParamAField) {
        ;
    } else if (sender == selectParamBField) {
        
    } else {
        
    }
    
    // Apariencia
}

-(IBAction)addNewFunction:(id)sender
{
    
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
