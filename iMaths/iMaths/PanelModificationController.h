//
//  PanelModificationController.h
//  iMaths
//
//  Created by Luis Blazquez Miñambres on 13/10/18.
//  Copyright © 2018 Luis Blazquez Miñambres. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class GraphicsClass;

@interface PanelModificationController : NSWindowController <NSWindowDelegate>
{
    IBOutlet NSTextField *newFunction;
    IBOutlet NSTextField *newName;
    IBOutlet NSTextField *newParamA;
    IBOutlet NSTextField *newParamB;
    IBOutlet NSTextField *newParamC;
    IBOutlet NSTextField *newParamN;
    IBOutlet NSColorWell *newColour;
    IBOutlet NSButton *confirmChanges;
    IBOutlet NSButton *cancelChanges;
    
    bool fieldsChanged;
}


-(void)handleModifyGraphic:(NSNotification *)aNotification;

-(IBAction)confirmNewGraphic:(id)sender;
-(IBAction)cancelNewGraphic:(id)sender;

@end
