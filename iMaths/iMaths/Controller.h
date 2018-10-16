//
//  Controller.h
//  iMaths
//
//  Created by Luis Blazquez Miñambres on 7/10/18.
//  Copyright © 2018 Luis Blazquez Miñambres. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PanelController;

@interface Controller : NSObject <NSWindowDelegate>
{
    PanelController *panelController;
    
    NSMutableArray *arrayToExport;
    BOOL enableExportingFlag;
}

-(IBAction)showPanel:(id)sender;
-(void)handleExportGraphics:(NSNotification *)aNotification;
-(IBAction)exportTableGraphicsAs:(id)sender;
-(IBAction)exportGraphicAs:(id)sender;

@end

