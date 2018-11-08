//
//  PanelModel.m
//  iMaths
//
//  Created by Luis Blazquez Miñambres on 12/10/18.
//  Copyright © 2018 Luis Blazquez Miñambres. All rights reserved.
//

#import "PanelModel.h"
#import "GraphicsClass.h"
#define NUM_PARAM 7

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
        arrayFilteredGraphics = [[NSMutableArray alloc] init];
        rowSelectedToModify = -1;
        
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

/*!
 * @brief  Carga el array del ComboBox con las funciones que se van a mostrar o a utilizar
 */
-(void)initializeArrayListFunctions
{

    // Se utiliza un array estatico al metodo para la reutilización y por si se desease ampliar
    // las funciones disponibles en un futuro.
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

/*!
 * @brief  Crea una nueva grafica con los parametros seleccionados y la añade al array de graficas
 */
-(void) createGraphic:(NSString*)functionName
              withName:(NSString*)graphicName
               paramA:(float)AGraphic
               paramB:(float)BGraphic
               paramC:(float)CGraphic
               paramN:(float)NGraphic
                color:(NSColor*)graphicColour
{
    if (functionName == nil){
        NSLog(@"PanelModel: createGraphic: La función es nil\r");
        return;
    }
    
    if (graphicName == nil){
        NSLog(@"PanelModel: createGraphic: El nombre de la grafica es nil\r");
        return;
    }
    
    if (graphicColour == nil){
        NSLog(@"PanelModel: createGraphic: El color es nil\r");
        return;
    }
    
    GraphicsClass *graphic =[[GraphicsClass alloc] initWithGraphicName:graphicName
                                                              function:functionName
                                                                paramA:AGraphic
                                                                paramB:BGraphic
                                                                paramC:CGraphic
                                                                paramN:NGraphic
                                                                colour:graphicColour];
    
    [arrayListGraphics addObject:graphic];
}

/*!
 * @brief  Indica si el nombre de nueva gráfica existe ya en la tabla de gráficas
 * @return BOOL devuelve YES si el nombre ya existe, de lo contrario devuelve NO
 */
-(BOOL) containsName:(NSString*)name
{
    if (name == nil){
        NSLog(@"PanelModel: containsName: El nombre es nil\r");
        return NO;
    }
    
    for (GraphicsClass *g in arrayListGraphics) {
        if ([[g funcName] isEqualToString:name])
            return YES;
    }
    
    return NO;
}

/*!
 * @brief  Devuelve la grafica que se desea modificar en el panel
 * @return GraphicClass* Grafica que se desea modificar.
 */
-(GraphicsClass*) getGraphicToModify
{
    if (rowSelectedToModify != -1)
        return [arrayListGraphics objectAtIndex:rowSelectedToModify];
    else
        return nil;
}

/*!
 * @brief  Reescribe la información modificada en una grafica determinada en el panel de Modificacion
 * @param  graph Grafica que se ha modificado correctamente en el panel de Modificación
 */
-(void) graphicModified:(GraphicsClass*)graph
{
    if (graph == nil){
        NSLog(@"PanelModel: graphicModified: La gráfica es nil\r");
        return;
    }
    
    [arrayListGraphics setObject:graph atIndexedSubscript:rowSelectedToModify];
}

/*!
 * @brief  Almacena en un array las graficas que el usuario desea dibujar.
 * @param  indexArray Conjunto de los indices de las graficas de la tabla que se desean dibujar.
 */
-(void) arrayOfGraphicToDrawInIndexes:(NSIndexSet*)indexArray;
{
    if (indexArray == nil){
        NSLog(@"PanelModel: arrayOfGraphicToDrawInIndexes: Set de indices es nil\r");
        return;
    }
    
    arrayOfGraphicsToRepresent = [arrayListGraphics objectsAtIndexes:indexArray];
    
}

/*!
 * @brief  Elimina el objeto grafica que se acaba de eliminar de la tabla del panel 'Preferencias' en
 *         array de graficas.
 * @param  graphicDeletedIndexes Posición en el array de graficas de la grafica que se desea eliminar de
 *         la tabla.
 */
-(void) deleteGraphicAtIndexes:(NSIndexSet*)graphicDeletedIndexes;
{
    if (graphicDeletedIndexes == nil){
        NSLog(@"PanelModel: deleteGraphicAtIndex: Indice es -1\r");
        return;
    }
    
    [arrayListGraphics removeObjectsAtIndexes:graphicDeletedIndexes];
}

/*!
 * @brief  Importa la información de un conjunto de gráficas de un fichero.
 * @return NSMutableArray Devuelve el array de graficas que se ha importado de un fichero
 */
-(BOOL) importListOfGraphics
{
    // Instanciación del panel de apertura
    NSOpenPanel *open = [NSOpenPanel openPanel];
    
    BOOL funcFound = NO;
    int i = 0;
    NSInteger result = 0;
    NSError *error = nil;
    NSString* parametersDelimiter = @"#";
    NSString* graphicsDelimiter = @"\n";
    
    // Array con la extension/es con las que se exportará la lista de gráficas
    NSArray *zAryOfExtensions = [NSArray arrayWithObjects:@"txt",@"xml",@"csv",@"log", nil];
    [open setAllowedFileTypes:zAryOfExtensions];
    
    // String que contiene los parametros de cada grafica separados por un delimitador #
    NSString* imported = [[NSString alloc] init];
    NSArray* items = [[NSArray alloc] init];

    // Array que contiene todos las graficas importadas
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    // Parametros que se van a recoger de la grafica.
    GraphicsClass *graphicExported = [[GraphicsClass alloc] init];
    NSString *name = [[NSString alloc] init];
    NSString *func = [[NSString alloc] init];
    float a = 0;
    float b = 0;
    float c = 0;
    float n = 0;
    NSString * colorString = [[NSString alloc] init];
    NSColor *color = [[NSColor alloc] init];
    

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
        if (items == nil || [items count] == 0){
            NSLog(@"PanelModel: importListOfGraphics: Objeto no recuperado\r");
            return NO;
        }
        

        // Va recorriendo
        for (NSString *item in items){
            NSLog(@"Objeto recuperado: %@\n", item);
            
            // Divide los parametros del string a partir del delimitador y los añade a los indices de un array
            NSArray *foo = [item componentsSeparatedByString:parametersDelimiter];
            if (foo == nil){
                NSLog(@"PanelModel: importListOfGraphics: Parámetros no recuperados\r");
                return NO;
                
            // El array tiene que contener 7 elementos (los 7 parámetros de una gráfica)
            } else if ([foo count] != NUM_PARAM) {
                NSLog(@"PanelModel: importListOfGraphics: No se han recogido 7 parametros\r");
                return NO;
            }
        
            name = [foo objectAtIndex: 0];
            if (name == nil){
                NSLog(@"PanelModel: importListOfGraphics: name es nil\r");
                return NO;
            }
            
            // Si el nombre ya está contenido en la tabla, este se cambia
            if ([self containsName:name])
                name = [name stringByAppendingString:@"_imported"];
            
            
            func = [foo objectAtIndex: 1];
            if (func == nil){
                NSLog(@"PanelModel: importListOfGraphics: func es nil\r");
                return NO;
            }
            
            // Comprueba que la función este en la lista de funciones
            for (NSString* f in arrayListFunctions) {
                if ([func isEqualToString:f]){
                    funcFound = YES;
                    break;
                }
            }
            
            if (!funcFound) {
                NSLog(@"PanelModel: importListOfGraphics: Funcion importada no pertenece a una función del programa\r");
                return NO;
            }
            
            a = [[foo objectAtIndex: 2] floatValue];
            b = [[foo objectAtIndex: 3] floatValue];
            c = [[foo objectAtIndex: 4] floatValue];
            n = [[foo objectAtIndex: 5] floatValue];
            
            colorString = [foo objectAtIndex: 6];
            if (colorString == nil){
                NSLog(@"PanelModel: importListOfGraphics: colorString es nil\r");
                return NO;
            }
            
            // Recupera el color como un NSString y a través de un metodo lo transforma en NSColor
            color = [self colorFromString:colorString forColorSpace:[NSColorSpace deviceRGBColorSpace]];
            if (color == nil){
                NSLog(@"PanelModel: importListOfGraphics: color es nil\r");
                return NO;
            }
            
            graphicExported = [[GraphicsClass alloc] initWithGraphicName:name
                                                                function:func
                                                                  paramA:a
                                                                  paramB:b
                                                                  paramC:c
                                                                  paramN:n
                                                                  colour:color];
            [array addObject:graphicExported];
            ++i;
            
            // OJO esto es porque siempre coge una linea en blanco y la toma como otro string más
            if ([items count] == (i+1))
                break;

        } // End of for
    
    } else if(result == NSModalResponseCancel) { // Si se pulsa cancelar
        NSLog(@"Botón Cancelar Pulsado");
        return NO;
    } else {
        NSLog(@"doSaveAs tvarInt not equal 1 or zero = %3ld", result);
        return NO;
    }
    
    if (error) {
        [NSApp presentError:error];
    }
    
    [arrayListGraphics addObjectsFromArray:array];
    
    return YES;
}

/*!
 * @brief  Exporta la lista de graficas añadidas a la tabla del panel 'Preferencias'
 * @param  typeFile Extension del fichero en el que se desea exportar la lista de graficas de la tabla
 */
-(void) exportListOfGraphicsTo:(NSString*)typeFile;
{
    if (typeFile == nil){
        NSLog(@"PanelModel: exportGraphicView: typeFile es nil\r");
        return;
    }
    
    if ([self countOfArrayListGraphics] == 0) {
        NSLog(@"PanelModel: exportGraphicView: Aún no hay gráficas añadidas, introduzca alguna\r");
        return;
    } else {
        // Instanciación del panel de guardado
        NSSavePanel *save = [NSSavePanel savePanel];
        
        // Array con la extension/es con las que se exportará la lista de gráficas
        NSArray *zAryOfExtensions = [NSArray arrayWithObject:typeFile];
        [save setAllowedFileTypes:zAryOfExtensions];
        
        // Cadena que contendra el path o ruta donde se alojará el nuevo fichero
        NSString *selectedFile = [[NSString alloc] init];
        NSError *error = nil;
        NSString *colorString = [[NSString alloc] init];
        
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
                colorString = [self stringRepresentationOf:[graphic colour]];
                if (colorString == nil){
                    NSLog(@"PanelModel: exportListOfGraphics: colorString es nil\r");
                    return;
                }
                
                [writeString appendString:[NSString stringWithFormat:@"%@#%@#%f#%f#%f#%f#%@\n",
                                           [graphic funcName],
                                           [graphic function],
                                           [graphic paramA],
                                           [graphic paramB],
                                           [graphic paramC],
                                           [graphic paramN],
                                           colorString]];
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
        
    } // End of if-else
    

}

/*!
 * @brief  Exporta el contenido de la vista a una imagen.
 * @param  extension Extension del formato de la imagen, puede ser .png, .pdf o .jpeg
 */
-(void) exportGraphicView:(NSView*)view To:(NSString*)extension
{
    if (extension == nil){
        NSLog(@"PanelModel: exportGraphicView: Extension es nil\r");
        return;
    }
    
    NSLog(@"Exportar HABILITADO\r");
    
    // Conjunto de bytes donde se alojara el contenido del NSView para exportarlo a una imagen
    NSData *imageData;
    
    // Instancia el panel de Guardado
    NSSavePanel *save = [NSSavePanel savePanel];
    
    NSError *error;
    
    // URL o ruta del fichero exportado y bitmap en el que se añadirá el contenido de la vista
    NSURL *fileURL;
    NSBitmapImageRep *imageRep;
    NSBitmapImageFileType imageExtension = NSPNGFileType; // Por defecto será de tipo PNG
    
    BOOL wasHidden = view.isHidden;
    CGFloat wantedLayer = view.wantsLayer;
    
    view.hidden = NO;
    view.wantsLayer = YES;
    
    // Objeto imágen donde se alojará el contenido de la vista
    NSImage *image = [[NSImage alloc] initWithSize:view.bounds.size];
    
    /*
     * Se bloquea la representación de la vista para renderizar los bordes en su contexto gráfico
     * actual y poder lograr sacar su contenido.
     */
    [image lockFocus];
    CGContextRef ctx = [NSGraphicsContext currentContext].graphicsPort;
    [view.layer renderInContext:ctx];
    [image unlockFocus];

    /*
     * Al poner la funcionalidad de la vista a YES, se utiliza un objeto CALayer
     * para manejar el contenido renderizado.
     */
    view.wantsLayer = wantedLayer;
    view.hidden = wasHidden; // Vista no está escondida
    
    // Configuración del SavePanel y las extension en la que se va a exportar
    [save setAllowedFileTypes:[NSArray arrayWithObject:extension]];
    [save setTitle:@"Guardar Grafica como..."];
    [save setMessage:@"Message text."];
    
    NSInteger result = [save runModal];
    NSLog(@"Ventana Desplegada %ld\r", result);
    
    if ([extension isEqualToString:@"jpeg"]) {
        imageExtension = NSJPEGFileType;
    } else if ([extension isEqualToString:@"png"]) {
        imageExtension = NSPNGFileType;
    } else if ([extension isEqualToString:@"bmp"]) {
        imageExtension = NSBMPFileType;
    }
    
    if (result == NSModalResponseOK) {
        
        fileURL = [save URL];
        
        /*
         * Reducimos la imagen a través de su representación en formato TIFF
         * Y comprimimos el conjunto de bits de la imagen en un objeto de tipo Bitmap orientado
         * a la compresión de imagenes.
         */
        imageData = [image TIFFRepresentation];
        imageRep = [NSBitmapImageRep imageRepWithData:imageData];
        
        NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0]
                                                               forKey:NSImageCompressionFactor];
        imageData = [imageRep representationUsingType:imageExtension properties:imageProps];
        
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

/*!
 * @brief  Devuelve el numero de graficas añadidas a la tabla del panel 'Preferencias'
 * @return NSInteger Numero de elementos del array de graficas
 */
-(NSInteger) countOfArrayListGraphics
{
    return [arrayListGraphics count];
}

/*!
 * @brief  Devuelve la información de la función que se acaba
 * @param  graph Grafica que se caba de representar
 * @return NSString Cadena que contiene el nombre de la grafica y la función que representa
 */
-(NSString*) graphicLabelInfo:(GraphicsClass*)graph
{
    if (graph == nil){
        NSLog(@"PanelModel: graphicLabelInfo: Grafica es nil\r");
        return nil;
    }
    
    NSMutableString *s = [[NSMutableString alloc] init];
    NSMutableString *subS = [[NSMutableString alloc] init];
    NSString *a = [NSString stringWithFormat:@"%f",[graph paramA]];
    NSString *b = [NSString stringWithFormat:@"%f",[graph paramB]];
    NSString *c = [NSString stringWithFormat:@"+%f",[graph paramC]];
    NSString *n = [NSString stringWithFormat:@"%f",[graph paramN]];
    
    [subS appendString:[graph function]];
    [subS stringByReplacingOccurrencesOfString:@"a" withString:a];
    [subS stringByReplacingOccurrencesOfString:@"b" withString:b];
    [subS stringByReplacingOccurrencesOfString:@"+c" withString:c];
    [subS stringByReplacingOccurrencesOfString:@"n" withString:n];
    
    [s appendString:[graph funcName]];
    [s appendString:@":"];
    [s appendString:subS];
    
    NSString *message = [NSString stringWithString:s];
    
    return message;
}

/*!
 * @brief  Devuelve la representación del color en formato NSString
 * @param  colour Color de la grafica
 * @return NSString Cadena que contiene el color en otro formato para ser exportado
 */
- (NSString*) stringRepresentationOf:(NSColor*) colour
{
    if (colour == nil){
        NSLog(@"PanelModel: stringRepresentationOf: colour es nil\r");
        return nil;
    }
    
    CGFloat components[10];
    [colour getComponents:components];
    NSMutableString *string = [NSMutableString string];
    for (int i = 0; i < [colour numberOfComponents]; i++) {
        [string appendFormat:@"%f ", components[i]];
    }
    [string deleteCharactersInRange:NSMakeRange([string length]-1, 1)]; // Corta el espacio sobrante
    
    // Se podria pasar el color como NSData pero hay problemas de formato con los otros parametros
    return string;
}

/*!
 * @brief  Devuelve el color a su formato original a partir de la información en forma de NSString importada de fichero
 * @param  string Color de la grafica pasada o importada de fichero como una cadena
 *         colorSpace Espacio de colores en los que se representará el color devuelto (RGB por defecto)
 * @return NSColor Color formateado desde NSString
 */
- (NSColor*) colorFromString:(NSString*)string forColorSpace:(NSColorSpace*)colorSpace
{
    if (string == nil || colorSpace == nil){
        NSLog(@"PanelModel: colorFromString: parametros nil\r");
        return nil;
    }
    
    CGFloat components[10];    // Los espacios de colores necesitan entre 10 y más espacios
    NSArray *componentStrings = [string componentsSeparatedByString:@" "];
    int count = (int)[componentStrings count];
    NSColor *color = nil;
    if (count <= 10) {
        /*
         * Cada indice del array componentes contiene cada uno de los componentes(en formato CGfloat -> un numero)
         * de la paleta de colores necesarios para formar el NSColor correspondiente
         */
        for (int i = 0; i < count; i++) {
            components[i] = [[componentStrings objectAtIndex:i] floatValue];
        }
        color = [NSColor colorWithColorSpace:colorSpace components:components count:count];
    }
    return color;
}

@end
