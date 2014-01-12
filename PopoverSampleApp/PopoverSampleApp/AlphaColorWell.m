//
//  AlphaColorWell.m
//  PopoverSampleApp
//
//  Created by Indragie Karunaratne on 1/11/2014.
//

#import "AlphaColorWell.h"

@implementation AlphaColorWell

- (void)activate:(BOOL)exclusive
{
    [[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
    [super activate:exclusive];
}

@end
