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
extern NSString *PanelExportAndDrawGraphicsNotification;
/*(Controller -> PanelController) Manda una notificación cuando se importa el fichero del sistema */
extern NSString *PanelNewGraphicNotification;

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
        graphicRepresentationView = [[GraphicView alloc] init];
        //graphicToRepresent = [[GraphicsClass alloc] init];
        model = [[PanelModel alloc] init];

        arrayToExport = [[NSMutableArray alloc] init];
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(handleExportAndDrawGraphics:)
                   name:PanelExportAndDrawGraphicsNotification
                 object:nil];
    }
    
    return self;
}


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
        [NSApp terminate:self];
    return YES;
    
}


/*!
 * @brief  Abre y muestra el panel especificado.
 */
-(IBAction) showPanel:(id)sender
{
    if(!panelController)
        panelController = [[PanelController alloc] init];
    
    NSLog(@"panel %@\r", panelController);
    [panelController showWindow:self];
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
-(void) handleExportAndDrawGraphics:(NSNotification *)aNotification
{
    NSLog(@"Notificacion %@ recibida en handleExportAndDrawGraphic\r", aNotification);
    NSDictionary *notificationInfo = [aNotification userInfo];
    arrayToExport = [notificationInfo objectForKey:@"listOfGraphicsToExport"];

    GraphicsClass *graphic = [notificationInfo objectForKey:@"graphicToRepresent"];
    NSNumber *XMin = [notificationInfo objectForKey:@"XMin"];
    NSNumber *YMin = [notificationInfo objectForKey:@"YMin"];
    NSNumber *XMax = [notificationInfo objectForKey:@"XMax"];
    NSNumber *YMax = [notificationInfo objectForKey:@"YMax"];
    
    NSNumber *oX=[notificationInfo objectForKey:@"OrigenX"];
    NSNumber *oY=[notificationInfo objectForKey:@"OrigenY"];
    NSNumber *alt=[notificationInfo objectForKey:@"Altura"];
    NSNumber *anch=[notificationInfo objectForKey:@"Ancho"];
    NSGraphicsContext *ctx=[notificationInfo objectForKey:@"ContextoGrafico"];
    NSNumber *zoom = [notificationInfo objectForKey:@"graphicIsZoomed"];
    

    
    // Activa el flag que habilita la opcion de exportar el array de la tabla del PanelController
    if (arrayToExport != nil) {
        enableExportingFlag = YES;
    }
    
    // Activa el metodo setNeedsDisplay para poder representar los ajustes de la vista 'CustomView' en el drawRect
    if (graphic != nil && XMin != nil && XMax != nil && YMin != nil && YMax != nil) {
        //graphicToRepresent = graphic;
        limit.origin.x = [XMin integerValue];
        limit.origin.y = [YMin integerValue];
        limit.size.width = [XMax integerValue];
        limit.size.height = [YMax integerValue];
        
        NSLog(@"Limits Controller: oX: %f oY: %f width: %f height: %f", limit.origin.x,
              limit.origin.y,
              limit.size.width,
              limit.size.height);
        
        [model setGraphicToRepresent:graphic ];
        NSLog(@"Notificacion para representar grafica (PanelController -> Controller)\n");
        [graphicRepresentationView setNeedsDisplay:YES]; // EL ERROR ESTA AL LLAMAR AQUI
        // De aqui llama al drawRect de la clase "GraphicView"
    }
    
    
    // Modela la representación de los objetos que se visualizarán dentro del 'Custom View': ejes, graficas,...
    if (oX != nil && oY != nil && alt != nil && anch != nil && ctx != nil) {

        bounds.origin.x=[oX integerValue];
        bounds.origin.y=[oY integerValue];
        bounds.size.height=[alt integerValue];
        bounds.size.width=[anch integerValue];
        graphicIsZoomed = [zoom boolValue];
        
        NSLog(@"Limits Controller: oX: %f oY: %f width: %f height: %f", limit.origin.x,
              limit.origin.y,
              limit.size.width,
              limit.size.height);
        
        NSLog(@"Notificacion para representar grafica (GraphicView -> Controller)\n");
        GraphicsClass *graphic = [model graphicToRepresent];
        [graphic drawInRect:bounds withGraphicsContext:ctx andLimits:limit isZoomed:graphicIsZoomed];

        NSLog(@"Grafica Representada");
    }

}

/* ---------------------------- EXPORTAR LISTA DE GRAFICAS ---------------------------- */

/*!
 * @brief  Exporta en un fichero XML o CSV las graficas dentro de la tabla del panel Preferencias
 */
-(IBAction) exportTableGraphicsAs:(id)sender
{
    if (enableExportingFlag){
        NSLog(@"Exportar HABILITADO\r");
        
        NSSavePanel *save = [NSSavePanel savePanel];
        NSArray *zAryOfExtensions = [NSArray arrayWithObject:@"txt"];
        [save setAllowedFileTypes:zAryOfExtensions];
        
        [save setTitle:@"Informative text."];
        [save setMessage:@"Message text."];
        
        NSInteger result = [save runModal];
        NSError *error = nil;
        NSLog(@"Ventana Desplegada %ld\r", result);
        
        if (result == NSModalResponseOK) {
            
            selectedFile = [[save URL] path];
            /* EN XML */
            if (![[NSFileManager defaultManager] fileExistsAtPath:selectedFile]) {
                [[NSFileManager defaultManager] createFileAtPath: selectedFile contents:nil attributes:nil];
                NSLog(@"Route creato");
            }
            
            NSMutableString *writeString = [NSMutableString stringWithCapacity:0];
            
            for (GraphicsClass *graphic in arrayToExport){
                [writeString appendString:[NSString stringWithFormat:@"%@#%@#%f#%f#%f#%f#%@\n",
                                           [graphic funcName],
                                           [graphic function],
                                           [graphic paramA],
                                           [graphic paramB],
                                           [graphic paramC],
                                           [graphic paramN],
                                           [graphic colour] ]];
            }
            
            NSLog(@"Cadena a enviar %@\n", writeString);
            BOOL zBoolResult = [writeString writeToURL:[save URL]
                                             atomically:NO
                                               encoding:NSASCIIStringEncoding
                                                  error:NULL];
            if (!zBoolResult) {
                NSLog(@"writeUsingSavePanel failed");
            }
            
        } else if(result == NSModalResponseCancel) {
            NSLog(@"doSaveAs we have a Cancel button");
            return;
        } else {
            NSLog(@"doSaveAs tvarInt not equal 1 or zero = %3ld", result);
            return;
        }
        
        NSURL *urlDirectory = [save directoryURL];
        NSString *saveDirectory = [urlDirectory absoluteString];
        NSLog(@"doSaveAs directory = %@", saveDirectory);
        
        NSString * saveFilename = [save representedFilename];
        NSLog(@"doSaveAs filename = %@", saveFilename);
        
        if (error) {
            // This is one way to handle the error, as an example
            [NSApp presentError:error];
        }
    } else {
        return;// Poner un mensaje de error o algo asi
    }
    
}

/* ---------------------------- IMPORTAR LISTA DE GRAFICAS ---------------------------- */

/*!
 * @brief  Carga la lista de graficas de un fichero en el sistema
 *         y las envia al panel Preferencias para cargarlas en la tabla.
 */

-(IBAction) importTableGraphics:(id)sender
{
    NSOpenPanel *open = [NSOpenPanel openPanel];
    NSInteger result = [open runModal];
    NSError *error = nil;
    
    GraphicsClass *graphicExported;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSString *name = [[NSString alloc] init];
    NSString *func = [[NSString alloc] init];
    float a = 0;
    float b = 0;
    float c = 0;
    float n = 0;
    NSString *color = [[NSString alloc] init];
    int i = 0;
    
    if (result == NSModalResponseOK) {
        
        /* En XML */
        
        //NSData* data = [NSData dataWithContentsOfFile:selectedFile];
        //convert the bytes from the file into a string
        NSLog(@"Abriendo en %@\r", [open URL]);
        NSString* imported = [NSString stringWithContentsOfURL:[open URL]
                                                     encoding:NSUTF8StringEncoding
                                                        error:&error]  ;

        NSLog(@"Recogido %@\n", imported);
        
        //split the string around newline characters to create an array
        NSString* delimiter = @"\n";
        NSArray* items = [imported componentsSeparatedByString:delimiter];
        
        for (NSString *item in items){
            NSLog(@"Objeto recuperado: %@\n", item);
            NSArray *foo = [item componentsSeparatedByString: @"#"];
            name = [foo objectAtIndex: 0];
            NSLog(@"Nombre %@",name);
            func = [foo objectAtIndex: 1];
            NSLog(@"Func %@",func);
            a = [[foo objectAtIndex: 2] floatValue];
            NSLog(@"Param A %f", a);
            b = [[foo objectAtIndex: 3] floatValue];
            c = [[foo objectAtIndex: 4] floatValue];
            n = [[foo objectAtIndex: 5] floatValue];
            color = [foo objectAtIndex: 6];
            graphicExported = [[GraphicsClass alloc] initWithGraphicName:name
                                                               function:func
                                                                 paramA:a
                                                                 paramB:b
                                                                 paramC:c
                                                                 paramN:n
                                                                 colour:nil];
            [array addObject:graphicExported];
            ++i;
            
            if ([items count] == (i+1)) // OJO esto es porque siempre coge una linea en blanco y la toma como otro string más
                break;
        }
        

        
        NSDictionary *notificationInfo = [NSDictionary dictionaryWithObject:array
                                                                     forKey:@"graphicsExported"];
        
        NSLog(@"A enviar %@\r", array);
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:PanelNewGraphicNotification
                          object:self
                        userInfo:notificationInfo];
        NSLog(@"Información enviada\r");

    } else if(result == NSModalResponseCancel) {
        NSLog(@"doSaveAs we have a Cancel button");
        return;
    } else {
        NSLog(@"doSaveAs tvarInt not equal 1 or zero = %3ld", result);
        return;
    }
    
    if (error) {
        // This is one way to handle the error, as an example
        [NSApp presentError:error];
    }
    
}

/* ---------------------------- EXPORTAR GRAFICA ---------------------------- */

/*!
 * @brief  Exporta en una imagen la grafica representada en esta ventana
 */
-(IBAction) exportGraphicAs:(id)sender
{
    NSLog(@"Exportar HABILITADO\r");
    
    NSData *exportedData;
    NSSavePanel *save = [NSSavePanel savePanel];
    NSError *error;
    
    BOOL wasHidden = graphicRepresentationView.isHidden;
    CGFloat wantedLayer = graphicRepresentationView.wantsLayer;
    
    graphicRepresentationView.hidden = NO;
    graphicRepresentationView.wantsLayer = YES;
    
    NSImage *image = [[NSImage alloc] initWithSize:graphicRepresentationView.bounds.size];
    [image lockFocus];
    CGContextRef ctx = [NSGraphicsContext currentContext].graphicsPort;
    [graphicRepresentationView.layer renderInContext:ctx];
    [image unlockFocus];
    
    graphicRepresentationView.wantsLayer = wantedLayer;
    graphicRepresentationView.hidden = wasHidden;
    
    
    [save setAllowedFileTypes:[NSArray arrayWithObject:@"png"]];
    
    [save setTitle:@"Guardar Grafica como..."];
    [save setMessage:@"Message text."];
    
    NSInteger result = [save runModal];
    NSLog(@"Ventana Desplegada %ld\r", result);
    
    if (result == NSModalResponseOK) {
        NSURL *fileURL = [save URL];
        // Cache the reduced image
        NSData *imageData = [image TIFFRepresentation];
        NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
        NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
        imageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
        
        if (exportedData == nil)
            NSLog(@"ERROR");
        
        BOOL zBoolResult = [imageData writeToURL:fileURL
                                            options:NSDataWritingAtomic
                                              error:&error];
        if (!zBoolResult) {
            NSLog(@"%s: %@", __FUNCTION__, error);
            NSLog(@"writeUsingSavePanel failed");
        }
        /*
         //save as pdf, succeeded but with flaw
         data = [self dataWithPDFInsideRect:[self frame]];
         [data writeToFile:@"asd.pdf" atomically:YES];
         */
    } else if(result == NSModalResponseCancel) {
        NSLog(@"doSaveAs we have a Cancel button");
        return;
    } else {
        NSLog(@"doSaveAs tvarInt not equal 1 or zero = %3ld", result);
        return;
    }
    
    NSURL *urlDirectory = [save directoryURL];
    NSString *saveDirectory = [urlDirectory absoluteString];
    NSLog(@"doSaveAs directory = %@", saveDirectory);
    
    NSString * saveFilename = [save representedFilename];
    NSLog(@"doSaveAs filename = %@", saveFilename);
    
    if (error) {
        // This is one way to handle the error, as an example
        [NSApp presentError:error];
    }
}


@end
