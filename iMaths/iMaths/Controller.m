//
//  Controller.m
//  iMaths
//
//  Created by Luis Blazquez Miñambres on 7/10/18.
//  Copyright © 2018 Luis Blazquez Miñambres. All rights reserved.
//

#import "Controller.h"
#import "PanelController.h"
#import "GraphicsClass.h"
#import "GraphicView.h"
#import "PanelModel.h"

/* --------- Esquema metodos ---------
 *   > Tratamiento de ventana
 *       - windowShouldClose()
 *   > showPanel()
 *   > dealloc()
 *   > Dibujar grafica
 *   > Exportar Lista de Graficas
 *       - exportTableGraphicsAs()
 *   > Importar Lista de Graficas
 *       - handleExportGraphics()
 *       - importTableGraphics()
 *   > Exportar Grafica
 *       - exportGraphicAs()
 */


@implementation Controller

/* (Controller -> PanelController) */

// Cuando se importan las graficas de un fichero y se añaden a la tabla.
NSString *NewGraphicImportedNotification = @"NewGraphicImported";
// Manda la instancia de la variable del modelo al resto de controladores.
NSString *SendModelNotification = @"SendModel";

/* (PanelController -> Controller) */

// Cuando se quiere representar una grafica de la tabla
extern NSString *DrawGraphicsNotification;
// Cuando se quiere exportar las graficas de la tabla
extern NSString *ExportGraphicsNotification;

/* (GraphicView -> Controller) */

// Se manda la información de la vista desde el metodo drawRect
extern NSString *DrawRectCalledNotification;
// Manda las coordenadas del puntero en la vista para mostrar la leyenda.
extern NSString *ShowLegendNotification;

/* ---------------------------- TRATAMIENTO DE VENTANA ---------------------------- */

/*!
 * @brief  Inicializa todas las variables de instancias declaradass en fichero .h .
 * @return id, puntero genérico.
 */
-(id)init
{
    self = [super init];
    if (self){
        NSLog(@"En init (Controller)");
        
        zoomIsRestored = NO;
        graphicRepresentationView = [[GraphicView alloc] init];
        model = [[PanelModel alloc] init];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        
        // Observador de la notificación de dibujo de la grafica o graficas seleccionadas (desde el controlador de preferencias)
        [nc addObserver:self
               selector:@selector(handleDrawGraphics:)
                   name:DrawGraphicsNotification
                 object:nil];

        // Observador de la notificación de representancion de la vista (desde drawRect de la vista)
        [nc addObserver:self
               selector:@selector(handleDrawGraphics:)
                   name:DrawRectCalledNotification
                 object:nil];
        
        // Observador de la notificación de envio de la posicion del puntero en la vista (desde la vista)
        [nc addObserver:self
               selector:@selector(handleShowLegend:)
                   name:ShowLegendNotification
                 object:nil];
    }
    
    return self;
}


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
        [NSApp terminate:self];
    return YES;
    
}
#pragma clang diagnostic pop

/*!
 * @brief  Abre y muestra el panel especificado. En este caso muestra el panel de Preferencias y envia la
 *         instancia del modelo a la clase controlador de ese panel.
 */
-(IBAction) showPanel:(id)sender
{
    if(!panelController)
        panelController = [[PanelController alloc] init];
    
    NSLog(@"panel %@\r", panelController);
    [panelController showWindow:self];
    
    // Envia la instancia del modelo a la clase 'PanelController'
    NSDictionary *notificationInfo = [NSDictionary dictionaryWithObject:model
                                                                 forKey:@"model"];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:SendModelNotification
                      object:self
                    userInfo:notificationInfo];
    
}

/* ---------------------------- DIBUJAR GRAFICA ---------------------------- */

/*!
 * @brief  Recoge la lista de graficas a exportar de la tabla en Preferencias
 *         cada vez que se añade una grafica nueva.
 */
-(void) handleDrawGraphics:(NSNotification *)aNotification
{
    NSLog(@"Notificacion %@ recibida en handleDrawGraphic\r", aNotification);
    NSDictionary *notificationInfo = [aNotification userInfo];

    // Del Panel al controlador, se envia la información de los ejes x e y y las graficas a representar
    NSNumber *XMin = [notificationInfo objectForKey:@"XMin"];
    NSNumber *YMin = [notificationInfo objectForKey:@"YMin"];
    NSNumber *XMax = [notificationInfo objectForKey:@"XMax"];
    NSNumber *YMax = [notificationInfo objectForKey:@"YMax"];
    
    // De la vista al controlador, se envia la información referente a las dimensiones de la vista, su contexto grafico y otros parametros referidos al zoom
    NSNumber *oX = [notificationInfo objectForKey:@"OrigenX"];
    NSNumber *oY = [notificationInfo objectForKey:@"OrigenY"];
    NSNumber *alt = [notificationInfo objectForKey:@"Altura"];
    NSNumber *anch = [notificationInfo objectForKey:@"Ancho"];
    NSGraphicsContext *ctx = [notificationInfo objectForKey:@"ContextoGrafico"];
    NSNumber *zoom = [notificationInfo objectForKey:@"graphicIsZoomed"];
    NSNumber *move = [notificationInfo objectForKey:@"graphicIsMoved"];
    NSNumber *w = [notificationInfo objectForKey:@"width"];
    NSNumber *h = [notificationInfo objectForKey:@"height"];
    
    // Activa el metodo setNeedsDisplay para poder representar los ajustes de la vista 'CustomView' en el drawRect
    if (XMin != nil && XMax != nil && YMin != nil && YMax != nil) {
        limit.origin.x = [XMin integerValue];
        limit.origin.y = [YMin integerValue];
        limit.size.width = [XMax integerValue];
        limit.size.height = [YMax integerValue];
        
        NSLog(@"Limits Controller: oX: %f oY: %f width: %f height: %f", limit.origin.x,
              limit.origin.y,
              limit.size.width,
              limit.size.height);
        
        zoomIsRestored = YES;
        [graphicRepresentationView setNeedsDisplay:YES];
        // De aqui llama al drawRect de la clase "GraphicView"
    }
    
    
    // Modela la representación de los objetos que se visualizarán dentro del 'Custom View': ejes, graficas,...
    if (oX != nil && oY != nil && alt != nil && anch != nil && ctx != nil) {
        // Variables locales
        NSArray *array = [[NSArray alloc] init];
        
        bounds.origin.x = [oX integerValue];
        bounds.origin.y = [oY integerValue];
        bounds.size.height = [alt integerValue];
        bounds.size.width = [anch integerValue];
        graphicIsZoomed = [zoom boolValue];
        graphicIsMoved = [move boolValue];
        wid = [w floatValue];
        heig = [h floatValue];
        
        NSLog(@"Limits Controller: oX: %f oY: %f width: %f height: %f", limit.origin.x,
              limit.origin.y,
              limit.size.width,
              limit.size.height);
        
        array = [model arrayOfGraphicsToRepresent];
        if ([array count] != 0) {
            NSLog(@"Entrar para dibujar");
            
            [graphicRepresentationView drawAxisAndPoints];
            
            if (zoomIsRestored) {
                NSLog(@"Zoom is Restored");
                graphicIsZoomed = NO;
            }
            
            NSLog(@"Valor Zoom antes de dibujar: %hhd", graphicIsZoomed);
            for (GraphicsClass *g in array) {
                [g drawInRect:bounds withGraphicsContext:ctx andLimits:limit isZoomed:graphicIsZoomed withMovement:graphicIsMoved w:wid h:heig];
                
                [self sendLabel:g];
            }
            NSLog(@"Grafica Representada");
            
        } else {
            [graphicRepresentationView drawAxisAndPoints];
        }
        
        zoomIsRestored = NO;
    }

}

-(void) sendLabel:(GraphicsClass*)g
{
    NSMutableString *s = [[NSMutableString alloc] init];
    NSString *a = [NSString stringWithFormat:@"%f",[g paramA]];
    NSString *b = [NSString stringWithFormat:@"%f",[g paramB]];
    NSString *c = [NSString stringWithFormat:@"+%f",[g paramC]];
    NSString *n = [NSString stringWithFormat:@"%f",[g paramN]];
    
    [s appendString:[g funcName]];
    [s stringByReplacingOccurrencesOfString:@"a" withString:a];
    [s stringByReplacingOccurrencesOfString:@"b" withString:b];
    [s stringByReplacingOccurrencesOfString:@"+c" withString:c];
    [s stringByReplacingOccurrencesOfString:@"n" withString:n];
    [s appendString:@":"];
    [s appendString:[g function]];
    [nameGraphLabel setHidden:NO];
    [nameGraphLabel setStringValue:s];
}

/*!
 * @brief  Recibe las coordenadas donde el usuario ha pulsado en la vista para mostrar la leyenda
 */
-(void) handleShowLegend:(NSNotification *)aNotification
{
    NSLog(@"Notificacion %@ recibida en handleShowLegend\r", aNotification);
    NSDictionary *notificationInfo = [aNotification userInfo];
    
    NSNumber *X = [notificationInfo objectForKey:@"LeyendaX"];
    NSNumber *Y = [notificationInfo objectForKey:@"LeyendaY"];
    
    float x = [X floatValue];
    float y = -([Y floatValue]);
    
    [XLegendField setFloatValue:x];
    [YLegendField setFloatValue:y];
}

/* ---------------------------- EXPORTAR LISTA DE GRAFICAS ---------------------------- */

/*!
 * @brief  Exporta en un fichero XML o TXT las graficas dentro de la tabla del panel Preferencias
 */
-(IBAction) exportTableGraphicsAs:(id)sender
{
    NSInteger numberOfGraphics = [model countOfArrayListGraphics];
    
    if (numberOfGraphics > 0) {
        NSLog(@"Exportar HABILITADO\r");
        [model exportListOfGraphicsTo:@"txt"]; // title
    }

}

/* ---------------------------- IMPORTAR LISTA DE GRAFICAS ---------------------------- */

/*!
 * @brief  Carga la lista de graficas de un fichero en el sistema
 *         y las envia al panel Preferencias para cargarlas en la tabla.
 */

-(IBAction) importTableGraphics:(id)sender
{

    NSMutableArray *array = [model importListOfGraphics];
    NSDictionary *notificationInfo = [NSDictionary dictionaryWithObject:array
                                                                 forKey:@"graphicsImported"];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:NewGraphicImportedNotification
                      object:self
                    userInfo:notificationInfo];
    
}

/* ---------------------------- EXPORTAR GRAFICA ---------------------------- */

/*!
 * @brief  Exporta en una imagen la grafica representada en esta ventana
 */
-(IBAction) exportGraphicAs:(id)sender
{
    [model exportGraphicView:graphicRepresentationView To:@"png"];
}

/* ---------------------------- REPRESENTACION DE LA BARRA DE HERRAMIENTAS ---------------------------- */

/*!
 * @brief  Muestra a través del botón de ayuda un panel emergente los pasos principales a seguir para
 *         representar una grafica.
 */
-(IBAction) showHelp:(id)sender
{
    [helpButton showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxXEdge];
}

/*!
 * @brief  Muestra un panel emergente con los valores de X e Y de la vista donde el usuario ha pulsado con
 *         el puntero del raton.
 */
-(IBAction) showLegend:(id)sender
{
    [legendButton showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxXEdge];
}

/*!
 * @brief  Reinicia o resetea la matriz de transformación afín a la vista por defecto antes de llevar a
 *         cabo el zoom sobre la misma.
 */
-(IBAction) restoreZoom:(id)sender
{
    zoomIsRestored = YES;
    [graphicRepresentationView restoreView:YES];
    [graphicRepresentationView setNeedsDisplay:YES];
}

/*!
 * @brief  Elimina el registro de objetos instanciados.
 */
-(void) dealloc
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

@end
