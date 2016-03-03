/**
 *
 *	@file   	: uexZXingScannerViewController.m  in EUExScanner
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

#import "uexZXingScannerViewController.h"
#import <ZXingObjC/ZXingObjC.h>
@interface uexZXingScannerViewController()<ZXCaptureDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic,strong)ZXCapture *ZXingCapture;

@end

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT  ([UIScreen mainScreen].bounds.size.height)


static CGFloat kUexScannerTopToolbarHeitght                 = 60;
static CGFloat kUexScannerBottomToolbarHeitght              = 60;
static CGFloat kUexScannerCaptureWidth                      = 240;
static CGFloat kUexScannerCaptureHeight                     = 240;
static CGFloat kUexScannerPromptVerticalDistanceFromCapture = 20;
static CGFloat kUexScannerPromptMaxWidth                    = 300;


@implementation uexZXingScannerViewController

#pragma mark - Life Cycle

- (instancetype)initWithCompletion:(uexScannerCompletionBlock)completion
{
    self = [super init];
    if (self) {
        [self initializer];
        self.completion=completion;
    }
    return self;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initializer];
    }
    return self;
}

- (void)initializer{
    _scannerTitle = @"扫一扫";
    _scannerPrompt = @"对准二维码/条形码,即可自动扫描";
    _backgroundScanImage = [self bundleImageForName:@"pick_bg"];
    _lineImage = [self bundleImageForName:@"line"];
    ZXCapture *capture = [[ZXCapture alloc] init];
    capture.camera = capture.back;
    capture.focusMode = AVCaptureFocusModeContinuousAutoFocus;
    capture.rotation = 90.0f;
    capture.layer.frame = self.view.bounds;
    

    self.ZXingCapture = capture;

    
}

- (void)viewDidLoad{

    [super viewDidLoad];


}


- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    self.view.backgroundColor=[UIColor whiteColor];

    
    self.ZXingCapture.hints = [self decodeHints];
    self.ZXingCapture.delegate = self;
    self.ZXingCapture.layer.frame = self.view.frame;
    [self.view.layer addSublayer:self.ZXingCapture.layer];
    self.ZXingCapture.layer.frame = self.view.bounds;
    [self addShadow];
    [self addCaptureView];
    [self addTopToolbar];
    [self addBottomToolbar];
    [self addPromptLabel];

    


    CGAffineTransform captureSizeTransform = CGAffineTransformMakeScale(320 / self.view.frame.size.width, 480 / self.view.frame.size.height);
    self.ZXingCapture.scanRect = CGRectApplyAffineTransform([self captureRect], captureSizeTransform);

}

- (void)dealloc{
    [_ZXingCapture.layer removeFromSuperlayer];
    _ZXingCapture = nil;
}

#pragma mark - StatusBarStyle

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Rotate


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}


#pragma mark - Scanner UI


- (void)addShadow{
    CALayer *shadowLayer = [CALayer layer];
    shadowLayer.frame = self.view.frame;
    shadowLayer.backgroundColor = [UIColor blackColor].CGColor;
    shadowLayer.opacity = 0.7;
    [self.view.layer addSublayer:shadowLayer];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:[self captureRect]];
    [maskPath appendPath:[UIBezierPath bezierPathWithRect:self.view.frame]];
    maskLayer.path = maskPath.CGPath;
    maskLayer.fillRule=kCAFillRuleEvenOdd;
    shadowLayer.mask=maskLayer;
}


- (void)addCaptureView{
    UIImageView *captureView=[[UIImageView alloc]initWithImage:self.backgroundScanImage];
    captureView.frame=[self captureRect];
    
    //lineView
    UIImageView *lineView=[[UIImageView alloc] initWithImage:self.lineImage];
    [lineView setFrame:CGRectMake(10, 0, kUexScannerCaptureWidth-20, 2)];
    CAKeyframeAnimation *move=[CAKeyframeAnimation animationWithKeyPath:@"position"];
    CGMutablePathRef path=CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, kUexScannerCaptureWidth/2, 0);
    CGPathAddLineToPoint(path, NULL, kUexScannerCaptureWidth/2, kUexScannerCaptureHeight);
    move.path=path;
    CFRelease(path);
    //足够大
    move.repeatCount=100000;
    move.duration=3;
    move.autoreverses=YES;
    move.removedOnCompletion=NO;
    [captureView addSubview:lineView];
    [lineView.layer addAnimation:move forKey:@"move"];
    
    
    //这个动画有必要么？
    /*
    //animation
    UIImageView *imageUp = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-kUexScannerCaptureWidth/2, SCREEN_HEIGHT/2-kUexScannerCaptureHeight/2, kUexScannerCaptureWidth, kUexScannerCaptureHeight/2)];
    imageUp.image =[self bundleImageForName:@"up"];
    [captureView addSubview:imageUp];
    
    UIImageView *imageDown = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-kUexScannerCaptureWidth/2, SCREEN_HEIGHT/2, kUexScannerCaptureWidth, kUexScannerCaptureHeight/2)];
    imageDown.image =[self bundleImageForName:@"down"];
    [captureView addSubview:imageDown];
    
    //up
    CABasicAnimation *translationUp = [CABasicAnimation animationWithKeyPath:@"position"];
    translationUp.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    translationUp.toValue = [NSValue valueWithCGPoint:CGPointMake(SCREEN_WIDTH/2, -100)];
    translationUp.duration =0.5;
    translationUp.repeatCount = 1;
    translationUp.fillMode = kCAFillModeForwards;
    translationUp.removedOnCompletion = YES;

    //down
    CABasicAnimation *translationDown = [CABasicAnimation animationWithKeyPath:@"position"];
    translationDown.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    translationDown.toValue = [NSValue valueWithCGPoint:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT)];
    translationDown.duration = 0.5;
    translationDown.fillMode = kCAFillModeForwards;
    translationDown.removedOnCompletion = YES;

    [imageUp.layer addAnimation:translationUp forKey:nil];
    [imageDown.layer addAnimation:translationDown forKey:nil];
    */
    [self.view addSubview:captureView];
}


- (void)addTopToolbar{
    UIToolbar *statusBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, SCREEN_WIDTH, 20)];
    [statusBar setBarStyle:UIBarStyleBlack];
    UIToolbar *topToolbar=[[UIToolbar alloc] initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, kUexScannerTopToolbarHeitght)];
    UIBarButtonItem *titleItem=[[UIBarButtonItem alloc]initWithTitle:self.scannerTitle style:UIBarButtonItemStylePlain target:nil action:nil];
    titleItem.tintColor=[UIColor whiteColor];
    [topToolbar setItems:@[[self toolbarItemWithImageName:@"ocrBack" action:@selector(cancelButtonClicked:)],
                           [self flexibleSpaceItem],
                           titleItem,
                           [self flexibleSpaceItem]]];
    [topToolbar setBarStyle:UIBarStyleBlack];
    [topToolbar setTintColor:[UIColor whiteColor]];
    //[topToolbar setTranslucent:NO];
    [self.view addSubview:statusBar];
    [self.view addSubview:topToolbar];
}

- (void)addBottomToolbar{
    UIToolbar *bottomToolbar=[[UIToolbar alloc] initWithFrame:CGRectMake(0,SCREEN_HEIGHT-kUexScannerBottomToolbarHeitght, SCREEN_WIDTH, kUexScannerBottomToolbarHeitght)];
    [bottomToolbar setBarStyle:UIBarStyleBlack];
    [bottomToolbar setTintColor:[UIColor whiteColor]];
    //[bottomToolbar setTranslucent:NO];
    [bottomToolbar setItems:@[[self toolbarItemWithImageName:@"ocr_flash-off" action:@selector(lightButtonClicked:)],
                             [self flexibleSpaceItem],
                              [self toolbarItemWithImageName:@"ocr_albums" action:@selector(albumButtonClicked:)]]];
    [self.view addSubview:bottomToolbar];
}

-  (void)addPromptLabel{
    UILabel *promptLabel=[[UILabel alloc] init];
//CGRectMake(SCREEN_WIDTH*0.5-kUexScannerCaptureWidth*0.5, SCREEN_HEIGHT*.5+kUexScannerCaptureHeight*0.5+kUexScannerPromptVerticalMargin, kUexScannerCaptureWidth, 0)];
    promptLabel.numberOfLines=0;
    promptLabel.text=self.scannerPrompt;
    promptLabel.lineBreakMode=NSLineBreakByWordWrapping;
    promptLabel.textColor=[UIColor whiteColor];
    UIFont *promptFont=[UIFont systemFontOfSize:16];
    promptLabel.font=promptFont;

    CGRect promptRect=[self.scannerPrompt boundingRectWithSize:CGSizeMake(kUexScannerPromptMaxWidth, CGFLOAT_MAX)
                                                       options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName:promptFont}
                                                       context:nil];
    [promptLabel setFrame:CGRectMake(SCREEN_WIDTH*0.5-promptRect.size.width*0.5, SCREEN_HEIGHT*.5+kUexScannerCaptureHeight*0.5+kUexScannerPromptVerticalDistanceFromCapture, kUexScannerPromptMaxWidth,promptRect.size.height)];
    [self.view addSubview:promptLabel];
    
}

#pragma mark - Bar Button Action

- (void)cancelButtonClicked:(id)sender{
    [self dismissWithResult:@"" codeType:@"" isCancelled:YES];
}
- (void)lightButtonClicked:(id)sender{
    self.ZXingCapture.torch=!self.ZXingCapture.torch;
}

- (void)albumButtonClicked:(id)sender{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = YES;
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:nil];
}


#pragma mark - Helper

- (void)dismissWithResult:(NSString *)scanResult codeType:(NSString *)codeType isCancelled:(BOOL)isCancelled{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:^{
            if(self.completion){
                self.completion(scanResult,codeType,isCancelled);
            }
        }];
    });
}


- (UIImage *)bundleImageForName:(NSString *)fileName{
    NSBundle *resBundle=[EUtility bundleForPlugin:@"uexScanner"];
    
    return [UIImage imageWithContentsOfFile:[[resBundle resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",fileName]]];
}

- (CGRect)captureRect{
    return CGRectMake(SCREEN_WIDTH/2-kUexScannerCaptureWidth/2, SCREEN_HEIGHT/2-kUexScannerCaptureHeight/2, kUexScannerCaptureWidth, kUexScannerCaptureHeight);
}


- (UIBarButtonItem *)flexibleSpaceItem{
    return [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}

- (UIBarButtonItem *)toolbarItemWithImageName:(NSString *)imageName action:(SEL)action{
    UIImage *image=[self bundleImageForName:imageName];
    UIBarButtonItem *item=[[UIBarButtonItem alloc]initWithImage:image style:UIBarButtonItemStylePlain target:self action:action];
    item.tintColor=[UIColor whiteColor];
    return item;
}

- (NSString *)barcodeFormatToString:(ZXBarcodeFormat)format {
    switch (format) {
        case kBarcodeFormatAztec:{
            return @"Aztec";
        }
        case kBarcodeFormatCodabar:{
            return @"CODABAR";
        }
        case kBarcodeFormatCode39:{
            return @"Code 39";
        }
        case kBarcodeFormatCode93:{
            return @"Code 93";
        }
        case kBarcodeFormatCode128:{
            return @"Code 128";
        }
        case kBarcodeFormatDataMatrix:{
            return @"Data Matrix";
        }
        case kBarcodeFormatEan8:{
            return @"EAN-8";
        }
        case kBarcodeFormatEan13:{
            return @"EAN-13";
        }
        case kBarcodeFormatITF:{
            return @"ITF";
        }
        case kBarcodeFormatPDF417:{
            return @"PDF417";
        }
        case kBarcodeFormatQRCode:{
            return @"QR Code";
        }
        case kBarcodeFormatRSS14:{
            return @"RSS 14";
        }
        case kBarcodeFormatRSSExpanded:{
            return @"RSS Expanded";
        }
        case kBarcodeFormatUPCA:{
            return @"UPCA";
        }
        case kBarcodeFormatUPCE:{
            return @"UPCE";
        }
        case kBarcodeFormatUPCEANExtension:{
            return @"UPC/EAN extension";
        }
        case kBarcodeFormatMaxiCode:{
            return @"Maxi Code";
        }
    }
}


#pragma mark - ZXing Delegate

- (void)captureResult:(ZXCapture *)capture result:(ZXResult *)result{
    if(!result){
        return;
    }
    [self.ZXingCapture stop];
    [self dismissWithResult:result.text codeType:[self barcodeFormatToString:result.barcodeFormat] isCancelled:NO];

}

- (ZXDecodeHints *)decodeHints{
    ZXDecodeHints *hints = [ZXDecodeHints hints];
    hints.tryHarder = YES;

    switch (self.charset) {
        case uexScannerEncodingCharsetUTF8: {
            break;
        }
        case uexScannerEncodingCharsetGBK: {
            NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            hints.encoding = gbkEncoding;
            break;
        }
    }
    
    return hints;
}


#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    dispatch_async(dispatch_get_main_queue(), ^{
        [picker dismissViewControllerAnimated:YES completion:^{
            [picker removeFromParentViewController];
            

        }];
    });
    
    UIImage * image = [info objectForKey:UIImagePickerControllerEditedImage];
    ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:image.CGImage];
    ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];

    NSError *error = nil;
    

    
    ZXMultiFormatReader *reader = [ZXMultiFormatReader reader];
    ZXResult *result = [reader decode:bitmap hints:[self decodeHints] error:&error];
    if (result) {
        [self dismissWithResult:result.text codeType:[self barcodeFormatToString:result.barcodeFormat] isCancelled:NO];
    }else{
        NSLog(@"%@",[error localizedDescription]);
    }
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    dispatch_async(dispatch_get_main_queue(), ^{
        [picker dismissViewControllerAnimated:YES completion:^{
            [picker removeFromParentViewController];
        }];
    });
}
@end
