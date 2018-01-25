//
//  KeyboardAction.h
//  Razor Application
//
//  Created by 白心宇 on 2017/8/8.
//  Copyright © 2017年 BXYMartin. All rights reserved.
//

#ifndef KeyboardAction_h
#define KeyboardAction_h


#import <Cocoa/Cocoa.h>  
@interface KeyBoardTextField : NSTextField
@end



#import "KeyBoardTextField.h"  
@implementation KeyBoardTextField

- (id)initWithFrame:(NSRect)frame{     self = [super initWithFrame:frame];
    
    if (self) {         // Initialization code here.
}
    return self;
}
- (void)viewDidMoveToWindow {}
- (void)drawRect:(NSRect)dirtyRect{     [super drawRect:dirtyRect];

        // Drawing code here.
}
- (void)keyDown:(NSEvent *)theEvent {
    [super keyDown:theEvent];
        NSLog(@"keyDown=%d",[theEvent keyCode]);
}

-(void)keyUp:(NSEvent *)theEvent{
    [super keyUp:theEvent];
    NSLog(@"keyUp=%@",[theEvent characters]);
}

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent{     NSLog(@"performkeyequivalent");
            return YES;
}
- (BOOL) acceptsFirstResponder{
    return YES;
}
- (BOOL) becomeFirstResponder{
    return YES;
}
- (BOOL) resignFirstResponder{
    return NO;
}
@end
#endif /* KeyboardAction_h */
