//
//  Controller.h
//  iMaths
//
//  Created by Luis Blazquez Miñambres on 7/10/18.
//  Copyright © 2018 Luis Blazquez Miñambres. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PanelController;
@class GraphicsClass;

@interface Controller : NSObject <NSWindowDelegate>
{
    PanelController *panelController;
    
    NSMutableArray *arrayToExport;
    BOOL enableExportingFlag; // No permite exportar hasta que no haya llegado la notificación del Panel
    NSString *selectedFile;
}

-(IBAction) showPanel:(id)sender;

/* Metodos para exportar una lista de gráficas de la tabla */
-(IBAction) exportTableGraphicsAs:(id)sender;

/* Metodos para importar una lista de graficas y cargarlas en la tabla de preferencias */
-(IBAction) importTableGraphics:(id)sender;
-(void) handleExportGraphics:(NSNotification *)aNotification;

/* Metodos para exportar una gráfica de la tabla */
-(IBAction) exportGraphicAs:(id)sender;

@end

