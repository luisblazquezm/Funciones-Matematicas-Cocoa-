//
//  ParametersNumberFormatter.m
//  iMaths
//
//  Created by Luis Blazquez Miñambres on 18/10/18.
//  Copyright © 2018 Luis Blazquez Miñambres. All rights reserved.
//

#import "ParametersNumberFormatter.h"

@implementation ParametersNumberFormatter


- (BOOL)isPartialStringValid:(NSString*)partialString
            newEditingString:(NSString**)newString
            errorDescription:(NSString**)error
{
    NSLog(@"PartialString: %@",partialString);
    
    if([partialString length] == 0) {
        return YES;
    }
    
    NSScanner* scanner = [NSScanner scannerWithString:partialString];
    
    if(!([scanner scanInt:0] && [scanner isAtEnd])) {
        NSBeep();
        return NO;
    }
    
    return YES;
}



/*
- (BOOL)isPartialStringValid:(NSString **)partialStringPtr
       proposedSelectedRange:(NSRangePointer)proposedSelRangePtr
              originalString:(NSString *)origString
       originalSelectedRange:(NSRange)origSelRange
            errorDescription:(NSString **)error {
    
    unsigned long total;
    NSRange inRange;
    NSCharacterSet *allowedChars;
    
    // Check Original String for Decimal
    NSArray * array = [*partialStringPtr componentsSeparatedByString:@"."];
    total = [array count] -1;
    
    if (total > 1) {
        // Decimal place already exists
        allowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    } else {
        allowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
    }
    
    inRange = [*partialStringPtr rangeOfCharacterFromSet:allowedChars];
    if(inRange.location != NSNotFound)
    {
        NSLog(@"Name input contains disallowed character.");
        NSBeep();
        return NO;
    } else {
        return YES;
    }
}
 */



@end
