//
//  EUExScanner.m
//  EUExScanner
//
//  Created by liguofu on 15/3/17.
//  Copyright (c) 2015年 AppCan.can. All rights reserved.
//

#import "EUExScanner.h"
#import <Foundation/Foundation.h>
#import "uexAVCaptureOutputViewController.h"
#import "uexZXingScannerViewController.h"
#import "JSON.h"


#define UEX_SCANNER_AVAILABLE_STRING_FOR_KEY(x) (self.jsonDict[x] && [self.jsonDict[x] isKindOfClass:[NSString class]])

@interface EUExScanner()
@property (nonatomic,strong)NSDictionary *jsonDict;
@end

@implementation EUExScanner




- (void)open:(NSMutableArray *)inArguments {
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus ==AVAuthorizationStatusRestricted ||  authStatus==AVAuthorizationStatusDenied){
        //NSLog(@"相机权限受限");
        NSString *jsonString=[NSString stringWithFormat:@"if(uexScanner.cbOpen!=null){uexScanner.cbOpen(1,1,0);}"];
        [EUtility brwView:self.meBrwView evaluateScript:jsonString];
        return;
    }
    else if(authStatus ==AVAuthorizationStatusNotDetermined){
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            if(granted==NO){
                NSString *jsonString=[NSString stringWithFormat:@"if(uexScanner.cbOpen!=null){uexScanner.cbOpen(1,1,0);}"];
                [EUtility brwView:self.meBrwView evaluateScript:jsonString];
                return ;
            }
            else{
                [self openCamera];
            }
        }];
    }
    else{
        [self openCamera];
    }

    
}
-(void)openCamera{
    
    UIStatusBarStyle initialStatusBarStyle =[UIApplication sharedApplication].statusBarStyle;
    float phoneVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if(phoneVersion<8.0){
        uexZXingScannerViewController *scanner=[[uexZXingScannerViewController alloc]initWithCompletion:^(NSString *scanResult, NSString *codeType, BOOL isCancelled) {
            [[UIApplication sharedApplication]setStatusBarStyle:initialStatusBarStyle];
            if(isCancelled){
                return;
            }
            
            NSMutableDictionary *result=[NSMutableDictionary dictionary];
            [result setValue:scanResult forKey:@"code"];
            [result setValue:codeType forKey:@"type"];
            NSString *jsonString=[NSString stringWithFormat:@"if(uexScanner.cbOpen!=null){uexScanner.cbOpen(0,1,'%@');}",[result JSONFragment]];
            [EUtility brwView:self.meBrwView evaluateScript:jsonString];
        }];
        
        
        if(UEX_SCANNER_AVAILABLE_STRING_FOR_KEY(@"title")){
            scanner.scannerTitle=self.jsonDict[@"title"];
        }
        if(UEX_SCANNER_AVAILABLE_STRING_FOR_KEY(@"tipLabel") ){
            scanner.scannerPrompt=self.jsonDict[@"tipLabel"];
        }
        if(UEX_SCANNER_AVAILABLE_STRING_FOR_KEY(@"lineImg")){
            scanner.lineImage=[self getImageByPath:self.jsonDict[@"lineImg"]];
        }
        if(UEX_SCANNER_AVAILABLE_STRING_FOR_KEY(@"pickBgImg")){
            scanner.backgroundScanImage=[self getImageByPath:self.jsonDict[@"pickBgImg"]];
        }
        if (UEX_SCANNER_AVAILABLE_STRING_FOR_KEY(@"charset")){
            NSString *charsetStr = [self.jsonDict[@"charset"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].lowercaseString;
            if ([charsetStr isEqual:@"gbk"]) {
                scanner.charset = uexScannerEncodingCharsetGBK;
            }
        }
        if([self.jsonDict objectForKey:@"frequency"]){
            scanner.frequency=[[self.jsonDict objectForKey:@"frequency"] floatValue];
        }
        else{
            scanner.frequency=1.5;
        }
        
        
        [EUtility brwView:self.meBrwView presentModalViewController:scanner animated:YES];
        
    }
    else{
        uexAVCaptureOutputViewController *scanner=[[uexAVCaptureOutputViewController alloc]initWithCompletion:^(NSString *scanResult, NSString *codeType, BOOL isCancelled) {
            [[UIApplication sharedApplication]setStatusBarStyle:initialStatusBarStyle];
            if(isCancelled){
                return;
            }
            
            NSMutableDictionary *result=[NSMutableDictionary dictionary];
            [result setValue:scanResult forKey:@"code"];
            [result setValue:codeType forKey:@"type"];
            NSString *jsonString=[NSString stringWithFormat:@"if(uexScanner.cbOpen!=null){uexScanner.cbOpen(0,1,'%@');}",[result JSONFragment]];
            [EUtility brwView:self.meBrwView evaluateScript:jsonString];
        }];
        
        
        if(UEX_SCANNER_AVAILABLE_STRING_FOR_KEY(@"title")){
            scanner.scannerTitle=self.jsonDict[@"title"];
        }
        if(UEX_SCANNER_AVAILABLE_STRING_FOR_KEY(@"tipLabel") ){
            scanner.scannerPrompt=self.jsonDict[@"tipLabel"];
        }
        if(UEX_SCANNER_AVAILABLE_STRING_FOR_KEY(@"lineImg")){
            scanner.lineImage=[self getImageByPath:self.jsonDict[@"lineImg"]];
        }
        if(UEX_SCANNER_AVAILABLE_STRING_FOR_KEY(@"pickBgImg")){
            scanner.backgroundScanImage=[self getImageByPath:self.jsonDict[@"pickBgImg"]];
        }
        if (UEX_SCANNER_AVAILABLE_STRING_FOR_KEY(@"charset")){
            NSString *charsetStr = [self.jsonDict[@"charset"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].lowercaseString;
            if ([charsetStr isEqual:@"gbk"]) {
                scanner.charset = uexScannerEncodingCGBK;
            }
        }
        if([self.jsonDict objectForKey:@"frequency"]){
            scanner.frequency=[[self.jsonDict objectForKey:@"frequency"] floatValue];
        }
        else{
            scanner.frequency=1.5;
        }
        
        
        [EUtility brwView:self.meBrwView presentModalViewController:scanner animated:YES];
    }
}

- (void)setJsonData:(NSMutableArray *)inArguments{
    if([inArguments count] < 1){
        return;
    }
    id info = [inArguments[0] JSONValue];
    if(!info || ![info isKindOfClass:[NSDictionary class]]){
        return;
    }
    self.jsonDict=info;
}


-(NSString*)recognizeFromImage:(NSMutableArray *)inArguments{
    if([inArguments count] < 1){
        return nil;
    }
    NSString* imagePath = nil;
    if(inArguments[0] && [inArguments[0] isKindOfClass:[NSString class]]){
        imagePath = inArguments[0];
    }else{
        return nil;
    }
    UIImage *image = nil;
    if ([imagePath hasPrefix:@"https"] || [imagePath hasPrefix:@"http"]) {
        NSURL *url = [NSURL URLWithString:imagePath];
        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    } else {
        image = [UIImage imageWithContentsOfFile:[self absPath:imagePath]];
    }
    
    CIDetector*detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    if (!features || features.count<1) {
        return nil;
    }
    NSMutableArray *resultArr = [NSMutableArray array];
    for (int index = 0; index < [features count]; index ++) {
        CIQRCodeFeature *feature = [features objectAtIndex:index];
        NSString *scannedResult = feature.messageString;
        NSLog(@"result:%@",scannedResult);
        [resultArr addObject:scannedResult];
        
    }
    return [resultArr copy][0];
}

- (UIImage *)getImageByPath:(NSString *)path {
    NSString *imagePath =[self absPath:path];
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    return [UIImage imageWithData:imageData];
}


- (void)clean {
    
    self.jsonDict=nil;
}

@end
