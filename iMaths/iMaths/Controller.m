//
//  Controller.m
//  iMaths
//
//  Created by Luis Blazquez Miñambres on 7/10/18.
//  Copyright © 2018 Luis Blazquez Miñambres. All rights reserved.
//

#import "Controller.h"
#import "PanelController.h"

/* --------- Esquema metodos ---------
 *   > Tratamiento de ventana
 *       - windowShouldClose()
 *   > Representacion graficas
 *
 */


@implementation Controller

extern NSString *PanelExportGraphicsNotification;

/*!
 * @brief  Inicializa todas las variables de instancias declaradass en fichero .h .
 * @return id, puntero genérico.
 */

-(id)init
{
    self = [super init];
    if (self){
        NSLog(@"En init");
        enableExportingFlag = NO;
        arrayToExport = [[NSMutableArray alloc] init];
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(handleExportGraphics:)
                   name:PanelExportGraphicsNotification
                 object:nil];
    }
    
    return self;
}


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

-(IBAction)showPanel:(id)sender
{
    if(!panelController)
        panelController = [[PanelController alloc] init];
    
    NSLog(@"panel %@\r", panelController);
    [panelController showWindow:self];
}

/*!
 * @brief  Elimina el registro de objetos instanciados.
 */
-(void)dealloc
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

-(void) handleExportGraphics:(NSNotification *)aNotification
{
    NSLog(@"Notificacion %@ recibida en handleModifyGraphic\r", aNotification);
    NSDictionary *notificationInfoToModify = [aNotification userInfo];
    arrayToExport = [notificationInfoToModify objectForKey:@"listOfGraphicsToExport"];
    
    enableExportingFlag = YES;
}

-(IBAction) exportTableGraphicsAs:(id)sender
{
    if (enableExportingFlag){
        NSLog(@"Exportar HABILITADO\r");

        NSSavePanel *save = [NSSavePanel savePanel];
        [save setAllowedFileTypes:[NSArray arrayWithObjects:@"txt", @"pdf", nil]];
        [save setAllowsOtherFileTypes:NO];
        
        [save setTitle:@"Informative text."];
        [save setMessage:@"Message text."];
        [save runModal];
        
        NSInteger result = [save runModal];
        NSError *error = nil;
        NSLog(@"Ventana Desplegada %ld\r", result);
        
        if (result == NSModalResponseOK)
        {

            NSString *selectedFile = [[save URL] path];
            NSString *content = [arrayToExport componentsJoinedByString:@" "];
            
            [content writeToFile:selectedFile
                      atomically:NO
                        encoding:NSUTF8StringEncoding
                           error:&error];
        }
        
        if (error) {
            // This is one way to handle the error, as an example
            [NSApp presentError:error];
        }
    } else {
        return;// Poner un mensaje de error o algo asi
    }

}

-(IBAction)exportGraphicAs:(id)sender
{
    
}


@end
