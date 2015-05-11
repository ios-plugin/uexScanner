//
//  EUExScanner.m
//  EUExScanner
//
//  Created by liguofu on 15/3/17.
//  Copyright (c) 2015年 AppCan.can. All rights reserved.
//

#import "EUExScanner.h"

@implementation EUExScanner

- (void)open:(NSMutableArray *)inArguments {
    
    ACPuexScannerViewController *scannerVC = [[ACPuexScannerViewController alloc]initWithEuexObj:self];
    if (_jsonDict) {
        scannerVC.scannerTitle = [_jsonDict objectForKey:@"title"];
        scannerVC.scannerTip = [_jsonDict objectForKey:@"tipLabel"];
        scannerVC.lineImg = [self getImageByPath:[_jsonDict objectForKey:@"lineImg"]];
        scannerVC.pickBgImg = [self getImageByPath:[_jsonDict objectForKey:@"pickBgImg"]];
    }
    self.initialStatusBarStyle =[UIApplication sharedApplication].statusBarStyle;
    
    [EUtility brwView:meBrwView presentModalViewController:scannerVC animated:NO];
    
}

- (void)setJsonData:(NSMutableArray *)inArguments {
    
    NSString *jsonStr = nil;
    
    if (inArguments.count > 0) {
        jsonStr = [inArguments objectAtIndex:0];
        self.jsonDict = [jsonStr JSONValue];
    }else{
        return;
    }
}

- (UIImage *)getImageByPath:(NSString *)path {
    
    NSString *imagePath =[self absPath:path];
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    return [UIImage imageWithData:imageData];
}

- (void)uexScannerWithOpId:(int)inOpId dataType:(int)inDataType data:(NSString *)inData {
    
    if (inData) {
        
        [self jsSuccessWithName:@"uexScanner.cbOpen" opId:inOpId dataType:inDataType strData:inData];
    }
}
- (void)clean {
    
    [self.jsonDict removeAllObjects];
}

@end
