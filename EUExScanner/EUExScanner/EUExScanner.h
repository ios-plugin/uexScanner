//
//  EUExScanner.h
//  EUExScanner
//
//  Created by liguofu on 15/3/17.
//  Copyright (c) 2015年 AppCan.can. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EUExBase.h"
#import "EUtility.h"
#import "ACPuexScannerViewController.h"
#import "JSON.h"
#define UEX_JKCODE						  @"code"
#define UEX_JKTYPE						  @"type"
@interface EUExScanner : EUExBase {
    
}

@property (nonatomic, assign)UIStatusBarStyle initialStatusBarStyle;

@property (nonatomic, retain) NSMutableDictionary *jsonDict;
-(void)uexScannerWithOpId:(int)inOpId dataType:(int)inDataType data:(NSString *)inData;
@end
