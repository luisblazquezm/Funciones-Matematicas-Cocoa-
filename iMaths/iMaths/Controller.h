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
    PanelModel *model; // instanciación del modelo

    /* Outlets */
    
    // Outlet conectado por target-action a la vista donde se representará la gráfica.
    IBOutlet GraphicView *graphicRepresentationView;
    IBOutlet NSButton *resetZoom;
    IBOutlet NSPopover *helpButton;
    IBOutlet NSPopover *legendButton;
    IBOutlet NSTextField *XLegendField;
    IBOutlet NSTextField *YLegendField;
    IBOutlet NSTextField *nameGraphLabel;
    
    
    NSRect limit;
    NSRect bounds;
    BOOL graphicIsZoomed;
    BOOL graphicIsMoved;
    BOOL zoomIsRestored;
    float wid, heig;
    

    
}

-(IBAction) showPanel:(id)sender;

    /* Metodos para exportar una lista de gráficas de la tabla */
-(IBAction) exportTableGraphicsAs:(id)sender;

    /* Metodos para importar una lista de graficas y cargarlas en la tabla de preferencias */
-(IBAction) importTableGraphics:(id)sender;

    /* Metodo para dibujar las graficas en el CustomView */
-(void) handleDrawGraphics:(NSNotification *)aNotification;

    /* Metodos para exportar una gráfica de la tabla */
-(IBAction) exportGraphicAs:(id)sender;

    /* Metodos de la barra de herramientas */
-(void) handleShowLegend:(NSNotification *)aNotification;
-(IBAction) showHelp:(id)sender;
-(IBAction) showLegend:(id)sender;
-(IBAction) restoreZoom:(id)sender;
-(void) sendLabel:(GraphicsClass*)g;

@end

