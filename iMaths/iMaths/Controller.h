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
    /* Punteros o referencias a otras clases */
    
    PanelController *panelController;
    PanelModel *model; 

    /* Outlets */
    
    IBOutlet GraphicView *graphicRepresentationView;
    IBOutlet NSButton *resetZoom;
    IBOutlet NSPopover *helpButton;
    IBOutlet NSPopover *legendButton;
    IBOutlet NSTextField *XLegendField;
    IBOutlet NSTextField *YLegendField;
    IBOutlet NSTextField *nameGraphLabel;
    
    /* Variables de instancia */
    
    BOOL graphicIsZoomed, graphicIsMoved, zoomIsRestored;
    NSRect limit, bounds;

}

-(IBAction) showPanel:(id)sender;
-(IBAction) exportTableGraphicsAs:(id)sender;
-(IBAction) importTableGraphics:(id)sender;
-(IBAction) showHelp:(id)sender;
-(IBAction) showLegend:(id)sender;
-(IBAction) restoreZoom:(id)sender;
-(IBAction) exportGraphicAs:(id)sender;
-(void) sendLabel:(NSString*)s;

    /* Handles de notificaciones */
-(void) handleDrawGraphics:(NSNotification *)aNotification;
-(void) handleShowLegend:(NSNotification *)aNotification;





@end

