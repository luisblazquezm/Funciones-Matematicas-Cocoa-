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
@class GraphicView;
@class PanelModel;

@interface Controller : NSObject <NSWindowDelegate>
{
    /* Variables relacionadas con PanelController*/
    
    PanelController *panelController;
    
    /* Variables de uso para Exportar e Importar */
    
    NSMutableArray *arrayToExport;
    BOOL enableExportingFlag; // No permite exportar hasta que no haya llegado la notificación del Panel
    NSString *selectedFile;
    
    /* Variables relacionadas con GraphicView */
    
    // Outlet conectado por target-action a la vista donde se representará la gráfica.
    IBOutlet GraphicView *graphicRepresentationView;
    IBOutlet NSButton *resetZoom;
    PanelModel *model;
    
    NSRect limit;
    NSRect bounds;
    BOOL graphicIsZoomed;
}

-(IBAction) showPanel:(id)sender;

    /* Metodos para exportar una lista de gráficas de la tabla */

-(IBAction) exportTableGraphicsAs:(id)sender;

    /* Metodos para importar una lista de graficas y cargarlas en la tabla de preferencias */

-(IBAction) importTableGraphics:(id)sender;

    /* Metodo para dibujar las graficas en el CustomView */

-(void) handleExportAndDrawGraphics:(NSNotification *)aNotification; // Tambien es el que recibe la notificación para dibujar

    /* Metodos para exportar una gráfica de la tabla */

-(IBAction) exportGraphicAs:(id)sender;




@end

