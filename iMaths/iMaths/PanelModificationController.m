//
//  PanelModificationController.m
//  iMaths
//
//  Created by Luis Blazquez Miñambres on 13/10/18.
//  Copyright © 2018 Luis Blazquez Miñambres. All rights reserved.
//

#import "PanelModificationController.h"
#import "PanelModel.h"
#import "GraphicsClass.h"

/* --------- Esquema metodos ---------
 *   > Inicializadores
 *       - init()
 *       - initWithWindow()
 *   > Tratamiento de ventana
 *       - windowShouldClose()
 *       - windowDidLoad()
 *   > Acciones de modificación
 *       - handleModifyGraphic()
 *   > Tratamiento de botones de modificación
 *       - confirmNewGraphic()
 *       - cancelNewGraphic()
 */

@interface PanelModificationController ()

@end

@implementation PanelModificationController

extern NSString *ModifyGraphicNotification;
NSString *PanelGraphicModifiedNotification = @"PanelGraphicModified";


/* --------------------------- INICIALIZADORES ---------------------- */

/*!
 * @brief  Inicializa todas las variables de instancias declaradass en fichero .h .
 * @return id, puntero genérico.
 */
-(id) init
{
    if (![super initWithWindowNibName:@"PanelModificationController"])
        return nil;
    
    return self;
}


/*!
 * @brief  Inicializa la ventana principal con el panel
 * @param  window .Ventana panelController.
 * @return instancetype.
 */
-(instancetype) initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self){
        NSLog(@"En init PanelModification");
        fieldsChanged = NO;
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        
        [nc addObserver:self
               selector:@selector(handleModifyGraphic:)
                   name:ModifyGraphicNotification
                 object:nil];
        
    }
    
    return self;
}

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
    
    if(respuesta == NSAlertDefaultReturn) {
        return NO;
    } else {
        [NSApp stopModal];
        return YES;
    }
    
}
#pragma clang diagnostic pop

- (void) windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

/* --------------------------- ACCIONES DE MODIFICACION ---------------------- */

/*!
 * @brief  Recoge los datos de la grafica a modificar así como la instancia del modelo para
 *         que el comboBox pueda utilizarla.
 */
-(void) handleModifyGraphic:(NSNotification *)aNotification
{
    NSLog(@"Notificacion %@ recibida en handleModifyGraphic\r", aNotification);
    NSDictionary *notificationInfoToModify = [aNotification userInfo];
    
    GraphicsClass *graphic = [notificationInfoToModify objectForKey:@"graphicToModify"];
    modelInPanel = [notificationInfoToModify objectForKey:@"modelInPanel"];
    
    NSNumber *availabilityB = [notificationInfoToModify objectForKey:@"BisEnabled"];
    NSNumber *availabilityC = [notificationInfoToModify objectForKey:@"CisEnabled"];
    NSNumber *availabilityN = [notificationInfoToModify objectForKey:@"NisEnabled"];
    
    BisEnabled = [availabilityB boolValue];
    CisEnabled = [availabilityC boolValue];
    NisEnabled = [availabilityN boolValue];
    
    NSLog(@"B: %d C: %d N: %d",BisEnabled,CisEnabled,NisEnabled);
    
    if (BisEnabled)
        [newParamB setEnabled:YES];
        
    if (CisEnabled)
        [newParamC setEnabled:YES];
        
    if (NisEnabled)
        [newParamN setEnabled:YES];
        
    // Inicializa el array del modelo de funciones
    [modelInPanel initializeArrayListFunctions];
    
    // Añade esas funciones al ComboBox
    [newFunction addItemsWithObjectValues:[modelInPanel arrayListFunctions]];
        
    [newFunction selectItemWithObjectValue:[graphic function]];
    [newName setStringValue:[graphic funcName]];
    [newParamA setFloatValue:[graphic paramA]];
    [newParamB setFloatValue:[graphic paramB]];
    [newParamC setFloatValue:[graphic paramC]];
    [newParamN setFloatValue:[graphic paramN]];
    [newColour setColor:[graphic colour]];
    
    NSWindow *w = [self window];
    [NSApp runModalForWindow:w];
    
}


/* --------------------------- TRATMIENTO DE BOTONES DE MODIFICACION ---------------------- */

/*!
 * @brief  Metodo que se llama cuando se confirman los cambios de la ventana.
 */
-(IBAction) confirmNewGraphic:(id)sender
{
    // OJOOOOO NO PERMITIR QUE EL USURIO MODIFIQUE EN PANEL PREFERENCIAS MIENTRAS ESTA ESTE ABIERTO PARA EVITAR QUE aRowSelected cambie
    GraphicsClass *newGraphic = [[GraphicsClass alloc] initWithGraphicName:[newName stringValue]
                                                               function:[newFunction stringValue]
                                                                 paramA:[newParamA floatValue]
                                                                 paramB:[newParamB floatValue]
                                                                 paramC:[newParamC floatValue]
                                                                 paramN:[newParamN floatValue]
                                                                 colour:[newColour color]];
    
    // El modelo guarda la información nueva de la grafica directamente en el array
    // dado que el modelo almacena el indice del objeto que ha sido enviado a este panel para ser modificado
    [modelInPanel graphicModified:newGraphic];
    
    // Se avisa al controlador para que recargue el contenido de la tabla
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:PanelGraphicModifiedNotification
                      object:self];
    
    // Cierra el panel
    [NSApp stopModal];
    [self close];
}

/*!
 * @brief  Metodo que se llama cuando se cierra la ventana.
 */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
-(IBAction) cancelNewGraphic:(id)sender
{
    NSInteger respuesta;
    respuesta = NSRunAlertPanel(@"Cambios realizados no guardados",
                                @"¿Está seguro de que desea cerrar la ventana?",
                                @"No. Guardar y cerrar panel",

                                @"Si. Cerrar panel",
                                nil);
    
    NSLog(@"NSAlertDefaultReturn %d", NSAlertDefaultReturn);
    
    if(respuesta == NSAlertDefaultReturn) { // No.Guardar y cerrar panel
        if (fieldsChanged) {
            [self confirmNewGraphic:sender];
        } else {
            [NSApp stopModal];
            [self close];
        }
    } else if (respuesta == NSAlertSecondButtonReturn) {// Si.Cerrar panel
         [NSApp stopModal];
         [self close];
     }
    
}
#pragma clang diagnostic pop

-(IBAction) controlTextDidChange:(NSNotification *)obj
{
    fieldsChanged = YES;
    
    [self fomatterOnlyRealNumbers];
}

/*!
 * @brief Metodo notificado cada vez que se selecciona un elemento dentro del ComboBox
 */
-(void)comboBoxSelectionDidChange:(NSNotification *)notification
{
    NSLog(@"Fila cambiada");
    [newParamB setStringValue:@""];
    [newParamC setStringValue:@""];
    [newParamN setStringValue:@""];
    BisEnabled = NO;
    CisEnabled = NO;
    NisEnabled = NO;
    [self selectParameters];
}


/*!
 * @brief  Recoge los parametros introducidos para A y B,C o N (si tocan).
 */
-(void) selectParameters
{

    NSString *function = [newFunction objectValueOfSelectedItem];
    
    if (!BisEnabled && !CisEnabled && !NisEnabled) {
        // Habilitación Campo Variable N
        for (int j = 0; j < NUM_PARAMETERS; j++) {
            if ([function rangeOfString:[[modelInPanel parametersN] objectAtIndex:j]                              options:NSCaseInsensitiveSearch].location != NSNotFound) {
                NSLog(@"Funcion %@ - Patron %@\r", function, [[modelInPanel parametersN] objectAtIndex:j]);
                [newParamN setEnabled:YES];
                NisEnabled = YES;
                break;
            } else {
                [newParamN setEnabled:NO];
            }
            
        }
        
        // Habilitación Campo Variable B
        for (int j = 0; j < NUM_PARAMETERS; j++) {
            if ([function rangeOfString:[[modelInPanel parametersB] objectAtIndex:j] options:NSCaseInsensitiveSearch].location != NSNotFound) {
                NSLog(@"Funcion %@ - Patron %@\r", function, [[modelInPanel parametersB] objectAtIndex:j]);
                [newParamB setEnabled:YES];
                BisEnabled = YES;
                break;
            } else {
                [newParamB setEnabled:NO];
            }
        }
        
        // Habilitación Campo Variable C
        for (int j = 0; j < NUM_PARAMETERS; j++) {
            if ([function rangeOfString:[[modelInPanel parametersC] objectAtIndex:j] options:NSCaseInsensitiveSearch].location != NSNotFound) {
                NSLog(@"Funcion %@ - Patron %@\r", function, [[modelInPanel parametersC] objectAtIndex:j]);
                [newParamC setEnabled:YES];
                CisEnabled = YES;
                break;
            } else {
                [newParamC setEnabled:NO];
            }
        }
        
    }// End of if-else

}

/*!
 * @brief  Formatea la entrada en los textFields para que solo se pueda introducir
 *         numeros reales positivos y negativos (al igual que en el panelController).
 */
-(void) fomatterOnlyRealNumbers
{
    // Formateador que no deja introducir palabras salvo numeros float que contengan - o .
    // Si se introduce un - despues de los numeros, varios puntos o varios menos, Estos se ignoran
    NSCharacterSet *charSet = [[NSCharacterSet characterSetWithCharactersInString:@"-1234567890."] invertedSet];
    
    // Creo varios arrays porque si creo uno general para todos los campos, lo que se escribiera en uno de ellos, se escribiría automaticamente en el resto.
    NSArray<NSString*> *arrayParamA = [[newParamA stringValue]
                                       componentsSeparatedByCharactersInSet:charSet];
    NSArray<NSString*> *arrayParamB = [[newParamB stringValue]
                                       componentsSeparatedByCharactersInSet:charSet];
    NSArray<NSString*> *arrayParamC = [[newParamC stringValue]
                                       componentsSeparatedByCharactersInSet:charSet];
    NSArray<NSString*> *arrayParamN = [[newParamN stringValue]
                                       componentsSeparatedByCharactersInSet:charSet];
    
    // Aplico el formateador de numeros negativos y positivos float a los campos de los parametros
    [newParamA setStringValue:[arrayParamA  componentsJoinedByString:@""]];
    [newParamB setStringValue:[arrayParamB  componentsJoinedByString:@""]];
    [newParamC setStringValue:[arrayParamC  componentsJoinedByString:@""]];
    [newParamN setStringValue:[arrayParamN  componentsJoinedByString:@""]];
    
}



@end
