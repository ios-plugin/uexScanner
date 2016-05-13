/**
 *
 *	@file   	: uexZXingScannerViewController.h  in EUExScanner
 *
 *	@author 	: CeriNo 
 * 
 *	@date   	: Created on 15/12/22.
 *
 *	@copyright 	: 2015 The AppCan Open Source Project.
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */
 
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,uexScannerEncodingCharset){
    uexScannerEncodingCharsetUTF8 = 0,
    uexScannerEncodingCharsetGBK,
};


typedef void (^uexScannerCompletionBlock)(NSString *scanResult,NSString *codeType,BOOL isCancelled);


@interface uexZXingScannerViewController : UIViewController
@property (nonatomic,strong)UIImage *lineImage;
@property (nonatomic,strong)UIImage *backgroundScanImage;
@property (nonatomic,strong)NSString *scannerTitle;
@property (nonatomic,strong)NSString *scannerPrompt;
@property (nonatomic,strong)uexScannerCompletionBlock completion;
@property (nonatomic,assign)uexScannerEncodingCharset charset;
@property (nonatomic,assign)float frequency;


- (instancetype)initWithCompletion:(uexScannerCompletionBlock)completion;
@end
