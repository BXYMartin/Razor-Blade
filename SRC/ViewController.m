//
//  ViewController.m
//  Razor Application
//
//  Created by 白心宇 on 2017/8/3.
//  Copyright © 2017年 BXYMartin. All rights reserved.
//

#import "ViewController.h"

#import <Foundation/Foundation.h>

#include "razerkbd_driver.h"

int Mode=8,Dual=1,speed=1,SliderMode = 0;
int color[6] = {255,255,255,255,255,255},sMode = 1,doul = 0,p = 0;
char *a = "000" , Mix[]="0000", Long[]="0000000", *b="000";
char *temp = "000";
char *Dir = "1";
char * device_type="";



@implementation ViewController





- (void)viewDidLoad {
    [super viewDidLoad];

    
    
    Indicator.stringValue = @"Status Not Set";
    R.hidden = false;
    G.hidden = false;
    B.hidden = false;
    Speed.hidden = true;
    Color.hidden = false;
    Directions.hidden = true;
    LogoState.hidden = true;
    RGBField.hidden = true;
    @autoreleasepool {
        // insert code here...
        //NSLog(@"Hello, World!");
        //Controller();
        //
        //razer_attr_write_set_logo(dev, "1", 1);
        
        CFMutableDictionaryRef matchingDict;
        io_iterator_t iter;
        kern_return_t kr;
        io_service_t usbDevice;
        
        /* set up a matching dictionary for the class */
        matchingDict = IOServiceMatching(kIOUSBDeviceClassName);
        
        
        /* Now we have a dictionary, get an iterator.*/
        kr = IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDict, &iter);
        
        /* iterate */
        while ((usbDevice = IOIteratorNext(iter))) {
            kern_return_t kr;
            IOCFPlugInInterface **plugInInterface = NULL;
            SInt32 score;
            HRESULT result;
            IOUSBDeviceInterface **dev = NULL;
            
            UInt16 vendor;
            UInt16 product;
            UInt16 release;
            
            kr = IOCreatePlugInInterfaceForService(usbDevice, kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID, &plugInInterface, &score);
            
            //Don’t need the device object after intermediate plug-in is created
            kr = IOObjectRelease(usbDevice);
            if ((kIOReturnSuccess != kr) || !plugInInterface) {
                printf("Unable to create a plug-in (%08x)\n", kr);
                continue;
                
            }
            
            
            //Now create the device interface
            result = (*plugInInterface)->QueryInterface(plugInInterface, CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID), (LPVOID *)&dev);
            
            //Don’t need the intermediate plug-in after device interface is created
            (*plugInInterface)->Release(plugInInterface);
            
            if (result || !dev) {
                printf("Couldn’t create a device interface (%08x)\n",
                       (int) result);
                continue;
                
            }
            
            //Check these values for confirmation
            kr = (*dev)->GetDeviceVendor(dev, &vendor);
            kr = (*dev)->GetDeviceProduct(dev, &product);
            kr = (*dev)->GetDeviceReleaseNumber(dev, &release);
            
            if (!is_blade_laptop(dev)) {
                (void) (*dev)->Release(dev);
                continue;
            }
            
            //Open the device to change its state
            kr = (*dev)->USBDeviceOpen(dev);
            if (kr != kIOReturnSuccess)  {
                printf("Unable to open device: %08x\n", kr);
                (void) (*dev)->Release(dev);
                continue;
                
            }
            
            
            switch (read_razor_device(dev))
            {
                case 1:
                    device_type = "Razer Blade Stealth";
                    break;
                    
                case 2:
                    device_type = "Razer Blade Stealth (Late 2016)";
                    break;
                    
                case 3:
                    device_type = "Razer Blade Pro (Late 2016)";
                    break;
                    
                case 4:
                    device_type = "Razer Blade Pro";
                    break;
                    
                case 5:
                    device_type = "Razer BlackWidow Chroma Tournament Edition";
                    break;
                default:
                    device_type = "Unknown Device";
            }
            
            DeviceType.stringValue = [NSString stringWithFormat:@"%s", device_type];
            
            //Close this device and release object
            kr = (*dev)->USBDeviceClose(dev);
            kr = (*dev)->Release(dev);
        }
        
        /* Done, release the iterator */
        IOObjectRelease(iter);
    }

    
    // Do any additional setup after loading the view.
}



- (NSColor *) colorWithHexString: (NSString *)color
    {
        NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
        
        // String should be 6 or 8 characters
        if ([cString length] < 6) {
            return [NSColor clearColor];
        }
        
        // strip 0X if it appears
        if ([cString hasPrefix:@"0X"])
            cString = [cString substringFromIndex:2];
        if ([cString hasPrefix:@"#"])
            cString = [cString substringFromIndex:1];
        if ([cString length] != 6)
            return [NSColor clearColor];
        
        // Separate into r, g, b substrings
        NSRange range;
        range.location = 0;
        range.length = 2;
        
        //r
        NSString *rString = [cString substringWithRange:range];
        
        //g
        range.location = 2;
        NSString *gString = [cString substringWithRange:range];
        
        //b
        range.location = 4;
        NSString *bString = [cString substringWithRange:range];
        
        // Scan values
        unsigned int r, g, b;
        [[NSScanner scannerWithString:rString] scanHexInt:&r];
        [[NSScanner scannerWithString:gString] scanHexInt:&g];
        [[NSScanner scannerWithString:bString] scanHexInt:&b];
        
        return [NSColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
    }

- (IBAction)Low:(id)sender {
    Mix[0] = '1';
    Long[0] = '1';
    speed = 3;
}

- (IBAction)Middle:(id)sender {
    Mix[0] = '2';
    Long[0] = '2';
    speed = 2;
}

- (IBAction)High:(id)sender {
    Mix[0] = '3';
    Long[0] = '3';
    speed = 1;
}

- (IBAction)LtoR:(id)sender {
    Dir = "1";
}

- (IBAction)RtoL:(id)sender {
    Dir = "2";
}


- (IBAction)RandomC:(id)sender {
    Dual=1;
    sMode = 0;
    ColorMode.maxValue = 0;
}

- (IBAction)Single:(id)sender {
    Dual=3;
    sMode = 1;
    ColorMode.maxValue = 0;
}

- (IBAction)Dual:(id)sender {
    Dual=6;
    sMode = 2;
    ColorMode.maxValue = 1;
}

- (IBAction)Logo:(id)sender {
    Status.stringValue = @"Logo Mode";
    R.hidden = true;
    G.hidden = true;
    B.hidden = true;
    RIn.hidden = true;
    GIn.hidden = true;
    BIn.hidden = true;
    RGB.hidden = true;
    RGBField.hidden = true;
    Speed.hidden = true;
    Color.hidden = true;
    Directions.hidden = true;
    LogoState.hidden = false;
    One.hidden = true;
    Two.hidden = true;
    ColorMode.hidden = true;
    ColorMode.intValue = 0;
    Mode = 10;
}

- (IBAction)Custom:(id)sender {
    Status.stringValue = @"";
    R.hidden = true;
    G.hidden = true;
    B.hidden = true;
    RIn.hidden = true;
    GIn.hidden = true;
    BIn.hidden = true;
    RGB.hidden = true;
    RGBField.hidden = true;
    Speed.hidden = true;
    Color.hidden = true;
    Directions.hidden = true;
    LogoState.hidden = true;
    ColorMode.hidden = true;
    ColorMode.intValue = 0;
    One.hidden = true;
    Two.hidden = true;
    ColorMode.hidden = true;
    Mode = 9;
}

- (IBAction)Breath:(id)sender {
    Status.stringValue = @"Speed";
    R.hidden = false;
    G.hidden = false;
    B.hidden = false;
    RIn.hidden = false;
    GIn.hidden = false;
    BIn.hidden = false;
    RGBField.hidden = true;
    RGB.hidden = false;
    Speed.hidden = false;
    Color.hidden = false;
    Directions.hidden = true;
    LogoState.hidden = true;
    One.hidden = false;
    Two.hidden = true;
    ColorMode.intValue = 0;
    SliderMode=0;
    if(sMode==2){
        ColorMode.maxValue = 1;
    }else{
    ColorMode.maxValue = 0;
    }
    ColorMode.hidden = false;
    Mode = 8;
}

- (IBAction)Starlight:(id)sender {
    Status.stringValue = @"Speed";
    R.hidden = false;
    G.hidden = false;
    B.hidden = false;
    RIn.hidden = false;
    GIn.hidden = false;
    BIn.hidden = false;
    RGBField.hidden = true;
    RGB.hidden = false;
    Speed.hidden = false;
    Color.hidden = false;
    Directions.hidden = true;
    LogoState.hidden = true;
    One.hidden = false;
    Two.hidden = true;
    SliderMode=0;
    ColorMode.intValue = 0;
    ColorMode.hidden = false;
    ColorMode.intValue = 0;
    if(sMode==2){
        ColorMode.maxValue = 1;
    }else{
        ColorMode.maxValue = 0;
    }
    Mode = 7;
}

- (IBAction)Reactive:(id)sender {
    Status.stringValue = @"Speed";
    R.hidden = false;
    G.hidden = false;
    B.hidden = false;
    RIn.hidden = false;
    GIn.hidden = false;
    BIn.hidden = false;
    RGB.hidden = false;
    RGBField.hidden = true;
    Speed.hidden = false;
    Color.hidden = true;
    Directions.hidden = true;
    LogoState.hidden = true;
    One.hidden = false;
    Two.hidden = true;
    SliderMode=0;
    ColorMode.maxValue = 0;
    ColorMode.hidden = false;
    ColorMode.intValue = 0;
    Mode = 6;
}

- (IBAction)Wave:(id)sender {
    Status.stringValue = @"Directions";
    RGB.hidden = true;
    RGBField.hidden = true;
    R.hidden = true;
    G.hidden = true;
    B.hidden = true;
    RIn.hidden = true;
    GIn.hidden = true;
    BIn.hidden = true;
    Speed.hidden = true;
    Color.hidden = true;
    Directions.hidden = false;
    LogoState.hidden = true;
    SliderMode=0;
    One.hidden = true;
    Two.hidden = true;
    ColorMode.maxValue = 0;
    ColorMode.hidden = true;
    ColorMode.intValue = 0;
    Mode = 5;
}

- (IBAction)None:(id)sender {
    Status.stringValue = @"";
    RGB.hidden = true;
    RGBField.hidden = true;
    R.hidden = true;
    G.hidden = true;
    B.hidden = true;
    RIn.hidden = true;
    GIn.hidden = true;
    BIn.hidden = true;
    Speed.hidden = true;
    Color.hidden = true;
    Directions.hidden = true;
    LogoState.hidden = true;
    One.hidden = true;
    Two.hidden = true;
    SliderMode=0;
    ColorMode.hidden = true;
    ColorMode.maxValue = 0;
    ColorMode.intValue = 0;
    Mode = 4;
}

- (IBAction)TextChange:(id)sender {
    a = [RGBField.stringValue UTF8String];
}

- (IBAction)Logo_On:(id)sender {
    b = "0";
}

- (IBAction)Logo_Cycle:(id)sender {
    b = "1";
}

- (IBAction)Logo_Flash:(id)sender {
    b = "2";
}

- (NSInteger)numberWithHexString:(NSString *)hexString{
    
    const char *hexChar = [hexString cStringUsingEncoding:NSUTF8StringEncoding];
    
    int hexNumber;
    
    sscanf(hexChar, "%x", &hexNumber);
    
    return (NSInteger)hexNumber;
}

- (IBAction)Relation:(id)sender {
    Status.stringValue = @"";
    RGB.hidden = true;
    RGBField.hidden = true;
    R.hidden = true;
    G.hidden = true;
    B.hidden = true;
    RIn.hidden = true;
    GIn.hidden = true;
    BIn.hidden = true;
    Speed.hidden = true;
    Color.hidden = true;
    Directions.hidden = true;
    LogoState.hidden = true;
    
}

- (IBAction)RChange:(id)sender {
    if(ColorMode.intValue==0){
        color[0]=R.doubleValue;
        color[1]=G.doubleValue;
        color[2]=B.doubleValue;
        CIndicator.fillColor =[NSColor colorWithRed:((float) color[0] / 255.0f) green:((float) color[1] / 255.0f) blue:((float) color[2] / 255.0f) alpha:1.0f];
        Indicator.stringValue = @"Color Set 1";
        Run.enabled = true;
    }
    else{
        color[3]=R.doubleValue;
        color[4]=G.doubleValue;
        color[5]=B.doubleValue;
        CFIndicator.fillColor =[NSColor colorWithRed:((float) color[3] / 255.0f) green:((float) color[4] / 255.0f) blue:((float) color[5] / 255.0f) alpha:1.0f];
        Indicator.stringValue = @"Color Set 2";
    }
    if(Mode!=7&&Mode!=8){
        Indicator.stringValue = @"Color Set";
    }
}

- (IBAction)GChange:(id)sender {
    if(ColorMode.intValue==0){
        color[0]=R.doubleValue;
        color[1]=G.doubleValue;
        color[2]=B.doubleValue;
        CIndicator.fillColor =[NSColor colorWithRed:((float) color[0] / 255.0f) green:((float) color[1] / 255.0f) blue:((float) color[2] / 255.0f) alpha:1.0f];
        Indicator.stringValue = @"Color Set 1";
        Run.enabled = true;
    }
    else{
        color[3]=R.doubleValue;
        color[4]=G.doubleValue;
        color[5]=B.doubleValue;
        CFIndicator.fillColor =[NSColor colorWithRed:((float) color[3] / 255.0f) green:((float) color[4] / 255.0f) blue:((float) color[5] / 255.0f) alpha:1.0f];
        Indicator.stringValue = @"Color Set 2";
    }
    if(Mode!=7&&Mode!=8){
        Indicator.stringValue = @"Color Set";
    }
}


- (IBAction)BChange:(id)sender {
    if(ColorMode.intValue==0){
        color[0]=R.doubleValue;
        color[1]=G.doubleValue;
        color[2]=B.doubleValue;
        CIndicator.fillColor =[NSColor colorWithRed:((float) color[0] / 255.0f) green:((float) color[1] / 255.0f) blue:((float) color[2] / 255.0f) alpha:1.0f];
        Indicator.stringValue = @"Color Set 1";
        Run.enabled = true;
    }
    else{
        color[3]=R.doubleValue;
        color[4]=G.doubleValue;
        color[5]=B.doubleValue;
        CFIndicator.fillColor =[NSColor colorWithRed:((float) color[3] / 255.0f) green:((float) color[4] / 255.0f) blue:((float) color[5] / 255.0f) alpha:1.0f];
        Indicator.stringValue = @"Color Set 2";
    }
    if(Mode!=7&&Mode!=8){
        Indicator.stringValue = @"Color Set";
    }
}

- (IBAction)SliderChange:(id)sender {
    if(ColorMode.intValue==0){
        One.hidden = false;
        Two.hidden = true;
    }
    else{
        One.hidden = true;
        Two.hidden = false;
    }
}

- (IBAction)ColorChange:(id)sender {
    int i = 0;
    switch (Mode){
    case 7:
            switch(sMode){
                case 2:
            if (doul == 0) {
                color[0]=R.doubleValue;
                color[1]=G.doubleValue;
                color[2]=B.doubleValue;
                CIndicator.fillColor =[NSColor colorWithRed:((float) color[0] / 255.0f) green:((float) color[1] / 255.0f) blue:((float) color[2] / 255.0f) alpha:1.0f];
                Indicator.stringValue = @"Color Set 1";
                Run.enabled = true;
                doul = 1;
            }
            else{
                color[3]=R.doubleValue;
                color[4]=G.doubleValue;
                color[5]=B.doubleValue;
                CFIndicator.fillColor =[NSColor colorWithRed:((float) color[3] / 255.0f) green:((float) color[4] / 255.0f) blue:((float) color[5] / 255.0f) alpha:1.0f];
                Indicator.stringValue = @"Color Set 2";
                Run.enabled = true;
                doul = 0;
            }
                    break;
                default:
                    color[0]=R.doubleValue;
                    color[1]=G.doubleValue;
                    color[2]=B.doubleValue;
                    CIndicator.fillColor =[NSColor colorWithRed:((float) color[0] / 255.0f) green:((float) color[1] / 255.0f) blue:((float) color[2] / 255.0f) alpha:1.0f];
                    Indicator.stringValue = @"Color Set";
                    Run.enabled = true;
                    break;
            }
            break;
        case 8:
            switch(sMode){
                case 2:
                    if (doul == 0) {
                        color[0]=R.doubleValue;
                        color[1]=G.doubleValue;
                        color[2]=B.doubleValue;
                        CIndicator.fillColor =[NSColor colorWithRed:((float) color[0] / 255.0f) green:((float) color[1] / 255.0f) blue:((float) color[2] / 255.0f) alpha:1.0f];
                        Indicator.stringValue = @"Color Set 1";
                        Run.enabled = true;
                        doul = 1;
                    }
                    else{
                        color[3]=R.doubleValue;
                        color[4]=G.doubleValue;
                        color[5]=B.doubleValue;
                        CFIndicator.fillColor =[NSColor colorWithRed:((float) color[3] / 255.0f) green:((float) color[4] / 255.0f) blue:((float) color[5] / 255.0f) alpha:1.0f];
                        Indicator.stringValue = @"Color Set 2";
                        Run.enabled = true;
                        doul = 0;
                    }
                    break;
                default:
                    color[0]=R.doubleValue;
                    color[1]=G.doubleValue;
                    color[2]=B.doubleValue;
                    CIndicator.fillColor =[NSColor colorWithRed:((float) color[0] / 255.0f) green:((float) color[1] / 255.0f) blue:((float) color[2] / 255.0f) alpha:1.0f];
                    Indicator.stringValue = @"Color Set";
                    Run.enabled = true;
                    break;
            }
            break;
        case 6:
                    color[0]=R.doubleValue;
                    color[1]=G.doubleValue;
                    color[2]=B.doubleValue;
                    CIndicator.fillColor =[NSColor colorWithRed:((float) color[0] / 255.0f) green:((float) color[1] / 255.0f) blue:((float) color[2] / 255.0f) alpha:1.0f];
                    Indicator.stringValue = @"Color Set";
                    Run.enabled = true;
            break;
        case 3:
            color[0]=R.doubleValue;
            color[1]=G.doubleValue;
            color[2]=B.doubleValue;
            CIndicator.fillColor =[NSColor colorWithRed:((float) color[0] / 255.0f) green:((float) color[1] / 255.0f) blue:((float) color[2] / 255.0f) alpha:1.0f];
            Indicator.stringValue = @"Color Set";
            Run.enabled = true;
            break;
    default:
    a = [RGBField.stringValue UTF8String];
    for (i=0; a[i]!='\0'; i++) {
        if ((a[i]>='0'&&a[i]<='9')||(a[i]>='a'&&a[i]<='f')) {
            CIndicator.fillColor =[self colorWithHexString:[[NSString alloc] initWithFormat:@"%c%c%c%c%c%c", a[0], a[0],a[1],a[1],a[2],a[2]]];
            
            //color[1]=strtoul([[[NSString alloc] initWithFormat:@"0x%c%c", a[1], a[1]] UTF8String],0,0);
            //color[2]=strtoul([[[NSString alloc] initWithFormat:@"0x%c%c", a[2], a[2]] UTF8String],0,0);
        }
        else
        {
            a = "000";
            b = "000";
            RGBField.stringValue = @"000";
            CIndicator.fillColor =[self colorWithHexString:[[NSString alloc] initWithFormat:@"ffffff"]];
            break;
        }
        temp = a;
    }

    if(a[0]<='1'){
        CIndicator.fillColor =[self colorWithHexString:[[NSString alloc] initWithFormat:@"ffffff"]];
    }
    if(a[i]=='\0'){
        Indicator.stringValue = @"Color Set";
        Run.enabled = true;
    }
    else
    {
        Indicator.stringValue = @"Incorrect Format";
        Run.enabled = false;
    }
    }
}

- (IBAction)Static:(id)sender {
    Status.stringValue = @"";
    R.hidden = false;
    G.hidden = false;
    B.hidden = false;
    RIn.hidden = false;
    GIn.hidden = false;
    BIn.hidden = false;
    RGB.hidden = false;
    RGBField.hidden = true;
    Speed.hidden = true;
    Color.hidden = true;
    Directions.hidden = true;
    LogoState.hidden = true;
    One.hidden = false;
    Two.hidden = true;
    ColorMode.hidden = false;
    ColorMode.maxValue = 0;
    ColorMode.intValue = 0;
    Mode = 3;
}

- (IBAction)Random:(id)sender {
    Status.stringValue = @"";
    R.hidden = true;
    G.hidden = true;
    B.hidden = true;
    RIn.hidden = true;
    GIn.hidden = true;
    BIn.hidden = true;
    RGB.hidden = false;
    RGBField.hidden = false;
    Speed.hidden = true;
    Color.hidden = true;
    Directions.hidden = true;
    LogoState.hidden = true;
    One.hidden = true;
    Two.hidden = true;
    ColorMode.hidden = true;
    ColorMode.maxValue = 0;
    ColorMode.intValue = 0;
    Mode = 2;
}

-(void)textFieldNotAllowedInput:(NSTextField*)textField inString:(NSString*)inString atIndex:(int)atIndex
{
    NSRange rangeFirst =NSMakeRange(0, atIndex -1);
    NSString* strFirst = [inString substringWithRange:rangeFirst];
    NSRange rangeLast =NSMakeRange(atIndex, [inString length]-atIndex);
    NSString* strSec = [inString substringWithRange:rangeLast];
    [textField setStringValue:@""];
    NSString* strInputTemp;
    [textField setStringValue:[strInputTemp stringByAppendingString:strFirst]];
    strInputTemp = [textField stringValue];
    [textField setStringValue:[strInputTemp stringByAppendingString:strSec]];
    [[textField currentEditor] setSelectedRange:NSMakeRange(atIndex-1,0)];
}

- (void)RGBFieldCallBack
{
    NSRange range = [[RGBField currentEditor] selectedRange];
    int iSel = range.location;
    NSString*strInput = [RGBField stringValue];
    const char *acStr = [strInput UTF8String];
    int nLen = [strInput length];
    // 限制最大输入长度
    if (nLen >3)
    {
        [self textFieldNotAllowedInput:RGBField inString:strInput atIndex:iSel];
        return;
    }
    char cInputTmp = acStr[iSel -1];
    // 限制输入：只有小数点和数字可以输入
    if ((cInputTmp>='a' && cInputTmp<='f') || (cInputTmp >= '0' && cInputTmp <='9') )
    {
    }
    else
    {
        [self textFieldNotAllowedInput:RGBField inString:strInput atIndex:iSel];
        return;
    }
}

- (IBAction)runDown:(id)sender {
    a = [RGBField.stringValue UTF8String];
    Indicator.stringValue = @"Processing";
    Run.enabled = false;
    Mix[1]=*a;
    Long[1]=*a;
    Long[4]=*b;
    @autoreleasepool {
        // insert code here...
        //NSLog(@"Hello, World!");
            //Controller();
            //
            //razer_attr_write_set_logo(dev, "1", 1);

        CFMutableDictionaryRef matchingDict;
        io_iterator_t iter;
        kern_return_t kr;
        io_service_t usbDevice;
        
        /* set up a matching dictionary for the class */
        matchingDict = IOServiceMatching(kIOUSBDeviceClassName);
        
        
        /* Now we have a dictionary, get an iterator.*/
        kr = IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDict, &iter);
        
        /* iterate */
        while ((usbDevice = IOIteratorNext(iter))) {
            kern_return_t kr;
            IOCFPlugInInterface **plugInInterface = NULL;
            SInt32 score;
            HRESULT result;
            IOUSBDeviceInterface **dev = NULL;
            
            UInt16 vendor;
            UInt16 product;
            UInt16 release;
            
            kr = IOCreatePlugInInterfaceForService(usbDevice, kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID, &plugInInterface, &score);
            
            //Don’t need the device object after intermediate plug-in is created
            kr = IOObjectRelease(usbDevice);
            if ((kIOReturnSuccess != kr) || !plugInInterface) {
                printf("Unable to create a plug-in (%08x)\n", kr);
                continue;
                
            }
            
            
            //Now create the device interface
            result = (*plugInInterface)->QueryInterface(plugInInterface, CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID), (LPVOID *)&dev);
            
            //Don’t need the intermediate plug-in after device interface is created
            (*plugInInterface)->Release(plugInInterface);
            
            if (result || !dev) {
                printf("Couldn’t create a device interface (%08x)\n",
                       (int) result);
                continue;
                
            }
            
            //Check these values for confirmation
            kr = (*dev)->GetDeviceVendor(dev, &vendor);
            kr = (*dev)->GetDeviceProduct(dev, &product);
            kr = (*dev)->GetDeviceReleaseNumber(dev, &release);
            
            if (!is_blade_laptop(dev)) {
                (void) (*dev)->Release(dev);
                continue;
            }
            
            //Open the device to change its state
            kr = (*dev)->USBDeviceOpen(dev);
            if (kr != kIOReturnSuccess)  {
                printf("Unable to open device: %08x\n", kr);
                (void) (*dev)->Release(dev);
                continue;
                
            }
        
        
        
            switch (Mode) {
                case 2:
                    razer_attr_write_mode_pulsate(dev, "1", 1);
                    Indicator.stringValue = @"Set Pulsate";
                    break;
                case 3:
                    razer_attr_write_mode_static(dev, color, 3);
                    Indicator.stringValue = @"Set Static";
                    break;
                case 4:
                    color[0]=0;
                    color[1]=0;
                    color[2]=0;
                    razer_attr_write_mode_static(dev, color, 3);
                    Indicator.stringValue = @"Set None";
                    break;
                case 5:
                    razer_attr_write_mode_wave(dev, Dir, 1);
                    Indicator.stringValue = @"Set Wave";
                    break;
                case 6:
                    razer_attr_write_mode_reactive(dev, Mix[0], color);
                    Indicator.stringValue = @"Set Reactive";
                    break;
                case 7:
                    switch(sMode){
                        case 0:
                            razer_attr_write_mode_starlight_random(dev, speed);
                            Indicator.stringValue = @"Set Starlight";
                            break;
                        case 1:
                        razer_attr_write_mode_starlight(dev, color, speed);
                            Indicator.stringValue = @"Set Starlight";
                            break;
                        case 2:
                            razer_attr_write_mode_starlight_double(dev, color, speed);
                        Indicator.stringValue = @"Set Starlight";
                    }
                    break;
                case 8:
                    razer_attr_write_mode_breath(dev, color, Dual);
                    Indicator.stringValue = @"Set breath";
                    break;
                case 10:
                    razer_attr_write_set_logo(dev, b, 1);
                    Indicator.stringValue = @"Set Logo";
                    break;
                case 9:
                    razer_attr_write_mode_custom(dev, "1", 1);
                    Indicator.stringValue = @"Set Custom";
                    break;
                default:
                    break;
            }
            //Close this device and release object
            kr = (*dev)->USBDeviceClose(dev);
            kr = (*dev)->Release(dev);
        }
        
        /* Done, release the iterator */
        IOObjectRelease(iter);
    }
    Run.enabled = true;
}



- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
