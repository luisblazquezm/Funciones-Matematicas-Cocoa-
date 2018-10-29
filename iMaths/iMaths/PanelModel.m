//
//  PanelModel.m
//  iMaths
//
//  Created by Luis Blazquez Miñambres on 12/10/18.
//  Copyright © 2018 Luis Blazquez Miñambres. All rights reserved.
//

#import "PanelModel.h"
#import "GraphicsClass.h"

@implementation PanelModel
@synthesize arrayListFunctions, arrayListGraphics, parametersC, parametersN, parametersB , arrayOfGraphicsToRepresent, rowSelectedToModify, arrayFilteredGraphics;

//NSString *PanelDisableIndexesFunctionNotification = @"PanelDisableIndexesFunction";

/*!
 * @brief  Inicializa todas las variables de instancias declaradass en fichero .h .
 * @return id, puntero genérico.
 */
-(id)init
{
    self = [super init];
    if (self){
        NSLog(@"En init");
        arrayListFunctions = [[NSMutableArray alloc] init];
        arrayListGraphics = [[NSMutableArray alloc] init];
        arrayOfGraphicsToRepresent = [[NSArray alloc] init];
        
        parametersC = [[NSArray alloc] initWithObjects:
                       @"^c",
                       @"c^",
                       @"c*",
                       @"*c ",
                       @"c+",
                       @"+c",
                       @"-c",
                       @"c-",
                       @"c/",
                       @"/c",
                       nil];
        
        parametersB = [[NSArray alloc] initWithObjects:
                       @"^b",
                       @"b^",
                       @"b*",
                       @"*b",
                       @"b+",
                       @"+b",
                       @"-b",
                       @"b-",
                       @"b/",
                       @"/b",
                        nil];
        
        parametersN = [[NSArray alloc] initWithObjects:
                       @"^n",
                       @"n^",
                       @"n*",
                       @"*n",
                       @"n+",
                       @"+n",
                       @"-n",
                       @"n-",
                       @"n/",
                       @"/n",
                       nil];
    }
    
    return self;
}

-(void)initializeArrayListFunctions
{

    static NSString *defaultFunctions[] =
    {
        @"a*sen(b*x)",
        @"a*x+b",
        @"a*cos(b*x)",
        @"a*x^2+b*x+c",
        @"a*x^n",
        @"a/(b*x)"
        
    };
    
    // Añado las funciones minimas que tiene que tener el programa en un arrayList
    for (int i = 0; i < NUM_DEFAULT_FUNCTIONS; i++) {
        [arrayListFunctions addObject:defaultFunctions[i]];
    }
    
}


-(void) createGraphic:(NSString*)functionName
              withName:(NSString*)graphicName
               paramA:(float)AGraphic
               paramB:(float)BGraphic
               paramC:(float)CGraphic
               paramN:(float)NGraphic
                color:(NSColor*)graphicColour
{
    GraphicsClass *graphic =[[GraphicsClass alloc] initWithGraphicName:graphicName
                                                              function:functionName
                                                                paramA:AGraphic
                                                                paramB:BGraphic
                                                                paramC:CGraphic
                                                                paramN:NGraphic
                                                                colour:graphicColour];
    
    [arrayListGraphics addObject:graphic];
}


-(void) addGraphic:(id)sender
{
    
}

-(void) arrayOfGraphicToDrawInIndexes:(NSIndexSet*)indexArray;
{
    arrayOfGraphicsToRepresent = [arrayListGraphics objectsAtIndexes:indexArray];
    
}

-(void) deleteGraphic:(NSInteger)graphicDeletedIndex;
{
    [arrayListGraphics removeObjectAtIndex:graphicDeletedIndex];
}

-(NSMutableArray*) importListOfGraphics
{
    // Instanciación del panel de apertura
    NSOpenPanel *open = [NSOpenPanel openPanel];
    
    int i = 0;
    NSInteger result = 0;
    NSError *error = nil;
    NSString* parametersDelimiter = @"#";
    NSString* graphicsDelimiter = @"\n";
    
    // String que contiene los parametros de cada grafica separados por un delimitador #
    NSString* imported = [[NSString alloc] init];
    NSArray* items = [[NSArray alloc] init];

    // Array que contiene todos las graficas importadas
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    // Parametros que se van a recoger de la grafica.
    GraphicsClass *graphicExported;
    NSString *name = [[NSString alloc] init];
    NSString *func = [[NSString alloc] init];
    float a = 0;
    float b = 0;
    float c = 0;
    float n = 0;
    NSString *color = [[NSString alloc] init];
    

    result = [open runModal];
    if (result == NSModalResponseOK) {
        
        // Convierte los parametros de cada grafica de un fichero en un string (cada grafica) separados por #
        NSLog(@"Abriendo en %@\r", [open URL]);
        imported = [NSString stringWithContentsOfURL:[open URL]
                                            encoding:NSUTF8StringEncoding
                                               error:&error];
        
        // Cada linea del fichero será una grafica (una serie de parametros delimitados por #)
        // En este caso, cada grafica esta separada por \n
        items = [imported componentsSeparatedByString:graphicsDelimiter];
        
        // Va recorriendo
        for (NSString *item in items){
            NSLog(@"Objeto recuperado: %@\n", item);
            
            // Divide los parametros del string a partir del delimitador y los añade a los indices de un array
            NSArray *foo = [item componentsSeparatedByString:parametersDelimiter];
            name = [foo objectAtIndex: 0];
            func = [foo objectAtIndex: 1];
            a = [[foo objectAtIndex: 2] floatValue];
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
            
            // OJO esto es porque siempre coge una linea en blanco y la toma como otro string más
            if ([items count] == (i+1))
                break;
            
        } // End of for
    
    } else if(result == NSModalResponseCancel) { // Si se pulsa cancelar
        NSLog(@"doSaveAs we have a Cancel button");
        return nil;
    } else {
        NSLog(@"doSaveAs tvarInt not equal 1 or zero = %3ld", result);
        return nil;
    }
    
    if (error) {
        // This is one way to handle the error, as an example
        [NSApp presentError:error];
    }
    
    return array;
}

-(void) exportListOfGraphicsTo:(NSString*)typeFile;
{
    // Instanciación del panel de guardado
    NSSavePanel *save = [NSSavePanel savePanel];

    // Array con la extension/es con las que se exportará la lista de gráficas
    NSArray *zAryOfExtensions = [NSArray arrayWithObject:typeFile];
    [save setAllowedFileTypes:zAryOfExtensions];

    // Cadena que contendra el path o ruta donde se alojará el nuevo fichero
    NSString *selectedFile = [[NSString alloc] init];
    NSError *error = nil;
    //NSLog(@"Ventana Desplegada %ld\r", result);

    [save setTitle:@"Guardado de la Lista de Graficas"];
    [save setMessage:@"Por favor, introduzca el nombre del nuevo fichero."];

    NSInteger result = [save runModal];
    if (result == NSModalResponseOK) {
        
        selectedFile = [[save URL] path];
        
        // Compruebo que el fichero no exista en la ruta seleccionada.
        // En caso contrario, creo el nuevo fichero
        if (![[NSFileManager defaultManager] fileExistsAtPath:selectedFile]) {
            [[NSFileManager defaultManager] createFileAtPath: selectedFile contents:nil attributes:nil];
            NSLog(@"Ruta creada");
        }
        
        // Enviaré el contenido de cada gráfica al fichero como un String
        // cuyos parametros estarán separados por #
        NSMutableString *writeString = [NSMutableString stringWithCapacity:0];
        for (GraphicsClass *graphic in arrayListGraphics){
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
        
        // En caso de que la exportación falle
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

    /* DEPURACIÓN DE FICHEROS Y RUTAS */
    NSURL *urlDirectory = [save directoryURL];
    NSString *saveDirectory = [urlDirectory absoluteString];
    NSLog(@"doSaveAs directory = %@", saveDirectory);
    
    NSString * saveFilename = [save representedFilename];
    NSLog(@"doSaveAs filename = %@", saveFilename);
    
    if (error) {
        [NSApp presentError:error];
    }
}

-(void) exportGraphicView:(NSView*)view To:(NSString*)extension
{
    NSLog(@"Exportar HABILITADO\r");
    
    // Conjunot de bytes donde se alojara el contenido del NSView para exportarlo a una imagen
    NSData *exportedData;
    NSData *imageData;
    
    // Instancia el panel de Guardado
    NSSavePanel *save = [NSSavePanel savePanel];
    
    NSError *error;
    
    NSURL *fileURL;
    NSBitmapImageRep *imageRep;
    
    BOOL wasHidden = view.isHidden;
    CGFloat wantedLayer = view.wantsLayer;
    
    view.hidden = NO;
    view.wantsLayer = YES;
    
    NSImage *image = [[NSImage alloc] initWithSize:view.bounds.size];
    [image lockFocus];
    CGContextRef ctx = [NSGraphicsContext currentContext].graphicsPort;
    [view.layer renderInContext:ctx];
    [image unlockFocus];
    
    view.wantsLayer = wantedLayer;
    view.hidden = wasHidden;
    
    [save setAllowedFileTypes:[NSArray arrayWithObject:extension]];
    
    [save setTitle:@"Guardar Grafica como..."];
    [save setMessage:@"Message text."];
    
    NSInteger result = [save runModal];
    NSLog(@"Ventana Desplegada %ld\r", result);
    
    if (result == NSModalResponseOK) {
        
        fileURL = [save URL];
        
        // Reducimos la imagen a través de su representación en formato TIFF
        // Y comprimimos el conjunto de bits de la imagen en Bitmap orientado a la compresión de imagenes
        imageData = [image TIFFRepresentation];
        imageRep = [NSBitmapImageRep imageRepWithData:imageData];
        
        
        NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0]
                                                               forKey:NSImageCompressionFactor];
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

    } else if(result == NSModalResponseCancel) {
        NSLog(@"doSaveAs we have a Cancel button");
        return;
    } else {
        NSLog(@"doSaveAs tvarInt not equal 1 or zero = %3ld", result);
        return;
    }
    
    /* DEPURACIÓN DE FICHEROS Y RUTAS */
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

-(NSInteger) countOfArrayListGraphics
{
    return [arrayListGraphics count];
}

@end
