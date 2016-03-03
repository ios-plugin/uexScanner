//
//  EUExScanner.m
//  EUExScanner
//
//  Created by liguofu on 15/3/17.
//  Copyright (c) 2015年 AppCan.can. All rights reserved.
//

#import "EUExScanner.h"
#import "uexZXingScannerViewController.h"
#import "JSON.h"


#define UEX_SCANNER_AVAILABLE_STRING_FOR_KEY(x) (self.jsonDict[x] && [self.jsonDict[x] isKindOfClass:[NSString class]])

@interface EUExScanner()
@property (nonatomic,strong)NSDictionary *jsonDict;
@end

@implementation EUExScanner




- (void)open:(NSMutableArray *)inArguments {

    UIStatusBarStyle initialStatusBarStyle =[UIApplication sharedApplication].statusBarStyle;
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
    
    
    [EUtility brwView:self.meBrwView presentModalViewController:scanner animated:YES];

    
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




- (UIImage *)getImageByPath:(NSString *)path {
    NSString *imagePath =[self absPath:path];
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    return [UIImage imageWithData:imageData];
}


- (void)clean {
    
    self.jsonDict=nil;
}

@end
