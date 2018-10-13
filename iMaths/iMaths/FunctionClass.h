//
//  FunctionClass.h
//  iMaths
//
//  Created by Luis Blazquez Miñambres on 13/10/18.
//  Copyright © 2018 Luis Blazquez Miñambres. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FunctionClass : NSObject
{
    NSString *name;
    NSString *formula;
    float paramA;
    float paramB;
    float paramN;
    NSColor *colour;
}

/* Getters y setters */

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *formula;
@property (nonatomic) float paramA;
@property (nonatomic) float paramB;
@property (nonatomic) float paramN;
@property (nonatomic) NSColor *colour;

@end
