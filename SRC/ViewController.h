//
//  ViewController.h
//  Razor Application
//
//  Created by 白心宇 on 2017/8/3.
//  Copyright © 2017年 BXYMartin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController{
    
    IBOutlet NSTextField *RGBField;
    IBOutlet NSButton *Run;
    IBOutlet NSButton *Set;
    IBOutlet NSTextField *Indicator;
    IBOutlet NSTextField *Status;
    IBOutlet NSTextField *DeviceType;
    IBOutlet NSPopUpButton *Color;
    IBOutlet NSPopUpButton *Directions;
    IBOutlet NSPopUpButton *Speed;
    IBOutlet NSView *MainView;
    IBOutlet NSView *KBView;
    IBOutlet NSBox *CIndicator;
    IBOutlet NSBox *CFIndicator;
    IBOutlet NSPopUpButton *LogoState;
    IBOutlet NSSlider *R;
    IBOutlet NSSlider *G;
    IBOutlet NSSlider *B;
    IBOutlet NSBox *RIn;
    IBOutlet NSBox *GIn;
    IBOutlet NSBox *BIn;
    IBOutlet NSTextField *RGB;
    IBOutlet NSTextField *One;
    IBOutlet NSTextField *Two;
    IBOutlet NSSlider *ColorMode;

}

- (NSColor *) colorWithHexString: (NSString *)color;

-(void)textDidChange:(NSNotification *)notification;

@end

