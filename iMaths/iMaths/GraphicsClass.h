//
//  GraphicsClass.h
//  iMaths
//
//  Created by Luis Blazquez Miñambres on 13/10/18.
//  Copyright © 2018 Luis Blazquez Miñambres. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GraphicsClass : NSObject
{
    NSString *funcName;
    NSString *function;
    float paramA;
    float paramB;
    float paramN;
    NSColor *colour;
}

/* Getters y setters */

@property (nonatomic) NSString *funcName;
@property (nonatomic) NSString *function;
@property (nonatomic) float paramA;
@property (nonatomic) float paramB;
@property (nonatomic) float paramN;
@property (nonatomic) NSColor *colour;

@end
