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

/*(PanelController -> Controller) Manda una notificación cada vez que se añade una grafica a la tabla */
extern NSString *DrawGraphicsNotification;

extern NSString *ExportGraphicsNotification;

/*(Controller -> PanelController) Manda una notificación cuando se importa el fichero del sistema */
NSString *NewGraphicImportedNotification = @"NewGraphicImported";

/* (Controller -> PanelController) Manda una notificación con la instancia de la variable del modelo al resto de controladores*/
NSString *SendModelNotification = @"SendModel";

extern NSString *DrawRectCalledNotification;

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
        NSLog(@"En init");
        
        enableExportingFlag = NO;
        zoomIsRestored = NO;
        graphicRepresentationView = [[GraphicView alloc] init];
        model = [[PanelModel alloc] init];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(handleDrawGraphics:)
                   name:DrawGraphicsNotification
                 object:nil];

        
        [nc addObserver:self
               selector:@selector(handleDrawGraphics:)
                   name:DrawRectCalledNotification
                 object:nil];
        
        
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
 * @brief  Abre y muestra el panel especificado.
 */
-(IBAction) showPanel:(id)sender
{
    if(!panelController)
        panelController = [[PanelController alloc] init];
    
    NSLog(@"panel %@\r", panelController);
    [panelController showWindow:self];
    
    NSDictionary *notificationInfo = [NSDictionary dictionaryWithObject:model
                                                                 forKey:@"model"];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:SendModelNotification
                      object:self
                    userInfo:notificationInfo];
    
}

/*!
 * @brief  Elimina el registro de objetos instanciados.
 */
-(void) dealloc
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
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
    NSArray *array = [[NSArray alloc] init];
    NSMutableString *s = [[NSMutableString alloc] init];

    // Del Panel al controlador, se envia la información de los ejes x e y y las graficas a representar
    //NSMutableArray *graphicsArray = [notificationInfo objectForKey:@"graphicsToRepresent"];
    NSNumber *XMin = [notificationInfo objectForKey:@"XMin"];
    NSNumber *YMin = [notificationInfo objectForKey:@"YMin"];
    NSNumber *XMax = [notificationInfo objectForKey:@"XMax"];
    NSNumber *YMax = [notificationInfo objectForKey:@"YMax"];
    
    // De la vista al controlador, se envia la información referente a las dimensiones de la vista, su contexto grafico y otros parametros referidos al zoom
    NSNumber *oX=[notificationInfo objectForKey:@"OrigenX"];
    NSNumber *oY=[notificationInfo objectForKey:@"OrigenY"];
    NSNumber *alt=[notificationInfo objectForKey:@"Altura"];
    NSNumber *anch=[notificationInfo objectForKey:@"Ancho"];
    NSGraphicsContext *ctx=[notificationInfo objectForKey:@"ContextoGrafico"];
    NSNumber *zoom = [notificationInfo objectForKey:@"graphicIsZoomed"];
    NSNumber *w = [notificationInfo objectForKey:@"width"];
    NSNumber *h = [notificationInfo objectForKey:@"height"];
    
    // Activa el metodo setNeedsDisplay para poder representar los ajustes de la vista 'CustomView' en el drawRect
    if (XMin != nil && XMax != nil && YMin != nil && YMax != nil) {
        //graphicToRepresent = graphic;
        limit.origin.x = [XMin integerValue];
        limit.origin.y = [YMin integerValue];
        limit.size.width = [XMax integerValue];
        limit.size.height = [YMax integerValue];
        
        NSLog(@"Limits Controller: oX: %f oY: %f width: %f height: %f", limit.origin.x,
              limit.origin.y,
              limit.size.width,
              limit.size.height);
        
        zoomIsRestored = YES;
        NSLog(@"Notificacion para representar grafica (PanelController -> Controller)\n");
        [graphicRepresentationView setNeedsDisplay:YES];
        // De aqui llama al drawRect de la clase "GraphicView"
    }
    
    
    // Modela la representación de los objetos que se visualizarán dentro del 'Custom View': ejes, graficas,...
    if (oX != nil && oY != nil && alt != nil && anch != nil && ctx != nil) {

        bounds.origin.x=[oX integerValue];
        bounds.origin.y=[oY integerValue];
        bounds.size.height=[alt integerValue];
        bounds.size.width=[anch integerValue];
        graphicIsZoomed = [zoom boolValue];
        wid = [w floatValue];
        heig = [h floatValue];
        
        NSLog(@"Limits Controller: oX: %f oY: %f width: %f height: %f", limit.origin.x,
              limit.origin.y,
              limit.size.width,
              limit.size.height);
        
        NSLog(@"Notificacion para representar grafica (GraphicView -> Controller)\n");
        array = [model arrayOfGraphicsToRepresent];
        if ([array count] != 0) {
            NSLog(@"Entre para dibujar");
            
            if (zoomIsRestored)
                graphicIsZoomed = NO;
            
            for (GraphicsClass *g in array) {
                [g drawInRect:bounds withGraphicsContext:ctx andLimits:limit isZoomed:graphicIsZoomed w:wid h:heig];
                [s appendString:[g funcName]];
                [s appendString:@":"];
                [s appendString:[g function]];
                [nameGraphLabel setHidden:NO];
                [nameGraphLabel setStringValue:s];
            }
        } else {
            GraphicsClass *g = [[GraphicsClass alloc] init];
            [g drawInRect:bounds withGraphicsContext:ctx andLimits:limit isZoomed:NO w:wid h:heig];
        }
        NSLog(@"Grafica Representada");
        zoomIsRestored = NO;
    }

}

-(void) handleShowLegend:(NSNotification *)aNotification
{
    NSLog(@"Notificacion %@ recibida en handleShowLegend\r", aNotification);
    NSDictionary *notificationInfo = [aNotification userInfo];
    
    NSNumber *X = [notificationInfo objectForKey:@"LeyendaX"];
    NSNumber *Y = [notificationInfo objectForKey:@"LeyendaY"];
    
    int absX = fabsf([X floatValue]);
    int absY = fabsf([Y floatValue]);
    
    [XLegendField setFloatValue:absX];
    [YLegendField setFloatValue:absY];
}

/* ---------------------------- EXPORTAR LISTA DE GRAFICAS ---------------------------- */

/*
-(void) handleExportGraphicsAvailable:(NSNotification *)aNotification
{
    NSLog(@"Notificacion %@ recibida en handleExportGraphicsAvailable\r", aNotification);
    enableExportingFlag = YES; // NO hace falta notificaciones , basta con que haya un solo elemento en el array de graficas del modelo
}
*/

/*!
 * @brief  Exporta en un fichero XML o CSV las graficas dentro de la tabla del panel Preferencias
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
    
    //NSLog(@"A enviar %@\r", array);
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:NewGraphicImportedNotification
                      object:self
                    userInfo:notificationInfo];
    //NSLog(@"Información enviada\r");
    
}

/* ---------------------------- EXPORTAR GRAFICA ---------------------------- */

/*!
 * @brief  Exporta en una imagen la grafica representada en esta ventana
 */
-(IBAction) exportGraphicAs:(id)sender
{
    [model exportGraphicView:graphicRepresentationView To:@"png"];
}

-(IBAction) showHelp:(id)sender
{
    [helpButton showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxXEdge];
}

-(IBAction) showLegend:(id)sender
{
    [legendButton showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxXEdge];
}

-(IBAction) restoreZoom:(id)sender
{
    zoomIsRestored = YES;
    [graphicRepresentationView setNeedsDisplay:YES];
}

@end
