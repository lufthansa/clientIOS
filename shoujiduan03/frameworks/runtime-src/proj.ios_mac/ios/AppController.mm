/****************************************************************************
 Copyright (c) 2010-2013 cocos2d-x.org
 Copyright (c) 2013-2014 Chukong Technologies Inc.

 http://www.cocos2d-x.org
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

#import <UIKit/UIKit.h>
#include "cocos2d.h"
#include "json/document.h"
#include "json/stringbuffer.h"
#include "json/writer.h"

#if CC_ENABLE_SCRIPT_BINDING
#include "CCLuaEngine.h"
#include "CCLuaBridge.h"
#include "tolua_fix.h"
#endif

#import "WXApi.h"
#import "WXApiObject.h"

#import "AppController.h"
#import "AppDelegate.h"
#import "RootViewController.h"
#import "platform/ios/CCEAGLView-ios.h"

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#import "utils/Utils.h"

static const std::string g_LuaToastFun = "g_NativeToast";

using namespace cocos2d;
@implementation AppController

#pragma mark -
#pragma mark Application lifecycle

// cocos2d application instance
static AppDelegate s_sharedApplication;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    cocos2d::Application *app = cocos2d::Application::getInstance();
    app->initGLContextAttrs();
    cocos2d::GLViewImpl::convertAttrs();

    // Override point for customization after application launch.

    // Add the view controller's view to the window and display.
    window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    CCEAGLView *eaglView = [CCEAGLView viewWithFrame: [window bounds]
                                     pixelFormat: (NSString*)cocos2d::GLViewImpl::_pixelFormat
                                     depthFormat: cocos2d::GLViewImpl::_depthFormat
                              preserveBackbuffer: NO
                                      sharegroup: nil
                                   multiSampling: NO
                                 numberOfSamples: 0 ];

    [eaglView setMultipleTouchEnabled:FALSE];
    
    // Use RootViewController manage CCEAGLView
    viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
    viewController.wantsFullScreenLayout = YES;
    viewController.view = eaglView;

    // Set RootViewController to window
    if ( [[UIDevice currentDevice].systemVersion floatValue] < 6.0)
    {
        // warning: addSubView doesn't work on iOS6
        [window addSubview: viewController.view];
    }
    else
    {
        // use this method on ios6
        [window setRootViewController:viewController];
    }
    
    [window makeKeyAndVisible];

    [[UIApplication sharedApplication] setStatusBarHidden: YES];

    // IMPORTANT: Setting the GLView should be done after creating the RootViewController
    cocos2d::GLView *glview = cocos2d::GLViewImpl::createWithEAGLView(eaglView);
    cocos2d::Director::getInstance()->setOpenGLView(glview);

    //向微信注册
    [WXApi registerApp:@"wx2675e915e32971a4"];  // guagua
//    [WXApi registerApp:@"wxe25e78084fb65f35"];  // baz
    
    
    [self initAppController];
    app->run();
    return YES;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
#ifdef __IPHONE_6_0
    return UIInterfaceOrientationMaskAllButUpsideDown;
#endif
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    cocos2d::Director::getInstance()->pause();
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    cocos2d::Director::getInstance()->resume();
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    cocos2d::Application::getInstance()->applicationDidEnterBackground();
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
//    [[ThirdParty getInstance] willEnterForegound];
    cocos2d::Application::getInstance()->applicationWillEnterForeground();
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    NSLog(@"in application handleOpenURL %@", url);
    return  [WXApi handleOpenURL:url delegate:self];

    return false; //[[ThirdParty getInstance] openURL:url];
}

#pragma mark -
#pragma mark picking image
- (UIImage*)reSizeImage:(UIImage*)image toSize:(CGSize)reSize
{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return reSizeImage;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [picker dismissModalViewControllerAnimated:YES];
    UIImage *pimage = [self reSizeImage:image toSize:CGSizeMake(96.0, 96.0)];
    NSData *imageData = UIImagePNGRepresentation(pimage);
    
    cocos2d::Image * pcimage = new cocos2d::Image();
    if (pcimage->initWithImageData((const unsigned char *)[imageData bytes], [imageData length]))
    {
        std::string bundle = [[[NSBundle mainBundle] bundleIdentifier] UTF8String];
        
        std::string path = cocos2d::StringUtils::format("%s/@ci_%s.png",cocos2d::FileUtils::getInstance()->getWritablePath().c_str(), bundle.c_str());
        if(true == pcimage->saveToFile(path.c_str()))
        {
            [self toLuaFunc:_pickCallFunC backMsg:path];
            _pickCallFunC = -1;
        }
    }
    pcimage->release();
    [picker release];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self toLuaFunc:_pickCallFunC backMsg:""];
    _pickCallFunC = -1;
    [picker release];
}

#pragma mark -
#pragma mark loginDelegate
- (void) onLoginStart:(NSString *)plat backMsg:(NSString *)msg
{
    [self toLuaToast:"登陆开始"];
}

- (void) onLoginSuccess:(NSString *)plat backMsg:(NSString *)msg
{
    NSLog(@"success");
    [self toLuaFunc:_loginCallFunC backMsg:[msg UTF8String]];
    _loginCallFunC = -1;
}

- (void) onLoginFail:(NSString *)plat backMsg:(NSString *)msg
{
    NSLog(@"Fail");
    if (nil != msg)
    {
        [self toLuaToast:[msg UTF8String]];
    }
    else
    {
        [self toLuaToast:"登陆失败"];
    }
    [self toLuaFunc:_loginCallFunC backMsg:""];
    _loginCallFunC = -1;
}

- (void) onLoginCancel:(NSString *)plat backMsg:(NSString *)msg
{
    NSLog(@"Cancel ==> %@", msg);
    [self toLuaToast:"登陆取消"];
    [self toLuaFunc:_loginCallFunC backMsg:""];
    _loginCallFunC = -1;
}

#pragma mark -
#pragma mark shareDelegate

- (void) onComplete:(NSString *)plat backCode:(int) eCode backMsg:(NSString *)msg
{
    NSLog(@"onComplete");
    [self toLuaFunc:_shareCallFunC backMsg:"true"];
    _shareCallFunC = -1;
}

- (void) onError:(NSString *)plat backMsg:(NSString *)msg
{
    NSLog(@"onError");
    [self toLuaFunc:_shareCallFunC backMsg:[msg UTF8String]];
    _shareCallFunC = -1;
}

- (void) onCancel:(NSString *)plat
{
    NSLog(@"onCancel");
    [self toLuaFunc:_shareCallFunC backMsg:"false"];
    _shareCallFunC = -1;
}

#pragma mark -
#pragma mark payDelegate
- (void) onPaySuccess:(NSString *)plat backMsg:(NSString *)msg
{
    NSLog(@"onPaySuccess");
    [self toLuaFunc:_payCallFunC backMsg:"true"];
    _payCallFunC = -1;
}

- (void) onPayFail:(NSString *)plat backMsg:(NSString *)msg
{
    NSLog(@"onPayFail");
    [self toLuaFunc:_payCallFunC backMsg:"false"];
    _payCallFunC = -1;
}

- (void) onPayNotify:(NSString *)plat backMsg:(NSString *)msg
{
    NSLog(@"onPayNotify");
    [self toLuaToast:[msg UTF8String]];
}

- (void) onGetPayList:(BOOL)bOk backMsg:(NSString *)msg
{
    std::string rmsg = [msg UTF8String];
    if (FALSE == bOk)
    {
        rmsg = "";
        [self toLuaToast:[msg UTF8String]];
    }
    [self toLuaFunc:_payCallFunC backMsg:rmsg];
    _payCallFunC = -1;
}

#pragma mark -
#pragma mark LocationDelegate
- (void) onLocationResult:(BOOL)bSuccess backCode:(int)code backMsg:(NSString *)msg
{
    std::string rmsg = [msg UTF8String];
    if (FALSE == bSuccess)
    {
        rmsg = "";
        [self toLuaToast:[msg UTF8String]];
    }
    [self toLuaFunc:_locationCallFunC backMsg:rmsg];
    _locationCallFunC = -1;
}

#pragma mark -
#pragma mark pick contact
-(void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact
{
    rapidjson::Document doc;
    doc.SetObject();
    rapidjson::Document::AllocatorType &alloc = doc.GetAllocator();
    
    CNPhoneNumber * num = nil;
    NSString * str = [NSString stringWithFormat:@"%@%@",contact.familyName,contact.givenName];
    if (nil != str)
    {
        std::string szstr = [str UTF8String];
        doc.AddMember("contactName", rapidjson::Value(szstr.c_str(), alloc), alloc);
    }
    
    if (contact.phoneNumbers.count >0)
    {
        num = contact.phoneNumbers[0].value;
        str = [NSString stringWithFormat:@"%@",[num valueForKey:@"digits"]];
        if (nil != str)
        {
            std::string szstr = [str UTF8String];
            doc.AddMember("contactNumber", rapidjson::Value(szstr.c_str(), alloc), alloc);
        }
    }
    rapidjson::StringBuffer buffer;
    rapidjson::Writer<rapidjson::StringBuffer> writer(buffer);
    doc.Accept(writer);
    
    [self toLuaFunc:_contactCallFunC backMsg:buffer.GetString()];
    _contactCallFunC = -1;
    [picker release];
}


#pragma mark -
#pragma mark luabridge
@synthesize PickCallFunC = _pickCallFunC;
@synthesize LoginCallFunC = _loginCallFunC;
@synthesize PayCallFunC = _payCallFunC;
@synthesize ShareCallFunC = _shareCallFunC;
@synthesize LocationCallFunC = _locationCallFunC;
@synthesize ContactCallFunC = _contactCallFunC;

- (void) initAppController
{
    _pickCallFunC = -1;
    _loginCallFunC = -1;
    _payCallFunC = -1;
    _shareCallFunC = -1;
}

- (int) getPickCallFunC
{
    return _pickCallFunC;
}

- (void) toLuaFunc: (int)funC backMsg:(std::string)msg
{
#if CC_ENABLE_SCRIPT_BINDING
    int handler = funC;
    if (-1 != handler)
    {
        LuaBridge::pushLuaFunctionById(handler);
        LuaStack *stack = LuaBridge::getStack();
        stack->pushString(msg.c_str());
        stack->executeFunction(1);
        LuaBridge::releaseLuaFunctionById(handler);
    }
#endif
}

- (void) toLuaToast: (std::string) msg
{
    [self toLuaGlobalFunC:g_LuaToastFun msg:msg];
}

- (void) toLuaGlobalFunC: (std::string) funName msg:(std::string) msg
{
#if CC_ENABLE_SCRIPT_BINDING
    lua_State* tolua_S = LuaEngine::getInstance()->getLuaStack()->getLuaState();
    lua_getglobal(tolua_S, funName.c_str());
    if (!lua_isfunction(tolua_S, -1))
    {
        CCLOG("value at stack [%d] is not function", -1);
        lua_pop(tolua_S, 1);
    }
    else
    {
        lua_pushstring(tolua_S, msg.c_str());
        int iRet = lua_pcall(tolua_S, 1, 0, 0);
        if (iRet)
        {
            log("call lua fun error:%s", lua_tostring(tolua_S, -1));
            lua_pop(tolua_S, 1);
        }
    }
#endif
}

+ (NSString*) getUUID
{
    return [Utils getUUID];
}

+ (NSString*) getHostAdress
{    
    return [Utils getHostAdress];
}

//选择图片
+ (void) pickImg:(NSDictionary*) dict
{
    UIImagePickerController *pickerImage = [[UIImagePickerController alloc] init];
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        pickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        pickerImage.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:pickerImage.sourceType];        
    }
    AppController * pApp = (AppController*)[[UIApplication sharedApplication] delegate];
    pickerImage.delegate = pApp;
    pickerImage.allowsEditing = [[dict objectForKey:@"needClip"] boolValue];
    //设置回调
    [pApp setPickCallFunC:[[dict objectForKey:@"scriptHandler"] intValue]];
    [pApp->viewController  presentViewController:((UIImagePickerController *)pickerImage) animated:YES completion:nil];
}

//配置第三方平台
+ (void) thirdPartyConfig:(NSDictionary *)dict
{
    
    NSObject* obj = [dict objectForKey:@"_nidx"];
    if (nil != obj)
    {
//        NSString *platstr = [[ThirdParty getInstance] getPlatform:[(NSString*)obj intValue]];
        NSLog(@"in thirdPartyConfig");
//        [[ThirdParty getInstance] configThirdParty:platstr platConfig:dict];
    }
}

//配置分享
+ (void) socialShareConfig:(NSDictionary *)dict
{
    NSLog(@"in socialShareConfig");
//    [[ThirdParty getInstance] configSocialShare:dict];
}

//第三方登陆
+ (void) thirdLogin:(NSDictionary *)dict
{
    NSLog(@"in thirdLogin");
    
    NSObject* obj = [dict objectForKey:@"_nidx"];
    if (nil != obj)
    {
//        NSString *platstr = [[ThirdParty getInstance] getPlatform:[(NSString*)obj intValue]];
        
        AppController * pApp = (AppController*)[[UIApplication sharedApplication] delegate];
        //设置回调
        [pApp setLoginCallFunC:[[dict objectForKey:@"scriptHandler"] intValue]];        
//        [[ThirdParty getInstance] thirdPartyLogin:platstr delegate:pApp];
    }
    
    return [AppController sendWeChatAuth];
}

//分享
+ (void) startShare:(NSDictionary *)dict
{
    NSLog(@"in startShare");

//    ShareConfig* share = [[ThirdParty getInstance] getDefaultShareConfig];
//    NSString* title = [NSString stringWithString:share.ShareTitle];
//    NSString* content = [NSString stringWithString:share.ShareContent];
//    NSString* url = [NSString stringWithString:share.ShareUrl];
//    struct tagShareParam param = {0, title, content, url, @"", FALSE};
    
    AppController * pApp = (AppController*)[[UIApplication sharedApplication] delegate];
    //设置回调
    [pApp setShareCallFunC:[[dict objectForKey:@"scriptHandler"] intValue]];
//    [[ThirdParty getInstance] openShare:pApp share:param];
}

//自定义分享
+ (void) customShare:(NSDictionary *)dict
{
    NSLog(@"in customShare");

//    struct tagShareParam param = [AppController getShareParam: dict];
    AppController * pApp = (AppController*)[[UIApplication sharedApplication] delegate];
    //设置回调
    [pApp setShareCallFunC:[[dict objectForKey:@"scriptHandler"] intValue]];
//    [[ThirdParty getInstance] openShare:pApp share:param];
}

// 分享到指定平台
+ (void) shareToTarget:(NSDictionary *)dict
{
    NSLog(@"in shareToTarget");

    AppController * pApp = (AppController*)[[UIApplication sharedApplication] delegate];
    int nLuaFunC = [[dict objectForKey:@"scriptHandler"] intValue];
    //设置回调
    [pApp setShareCallFunC:[[dict objectForKey:@"scriptHandler"] intValue]];
    NSString* obj = [dict objectForKey:@"target"];
    if (nil != obj)
    {
       [AppController getShareParam: dict];
//       param.nTarget = [obj intValue];
//       [pApp setShareCallFunC:nLuaFunC];
//
//       // 是不是分享图片
//       bool isImageShare = param.bImageOnly;
//       if (param.bImageOnly == true)
//       {
//           WXMediaMessage *message = [WXMediaMessage message];
//           [message setThumbImage:[UIImage imageNamed:@"图片.png"]];
//           //缩略图
//           WXImageObject *imageObject = [WXImageObject object];
//           NSString *filePaht = param.img;
//           imageObject.imageData = [NSD]
//
//           SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
//           req.bText = NO;
//           req.message = message;
//           req.scene = param.nTarget;    // 0 是分享到好友, 1是分享到朋友圈
//           [WXApi sendReq:req];
//       }
//       else
//       {
//           // 分享链接
//           WXMediaMessage *message = [WXMediaMessage message];
//           message.title = param.title;
//           message.description = param.content;
//           [message setThumbImage:[UIImage imageNamed:@"res2.png"]];
//
//           WXWebpageObject *webpageObject = [WXWebpageObject object];
//           webpageObject.webpageUrl = param.url;
//           message.mediaObject = webpageObject;
//
//           SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
//           req.bText = NO;
//           req.message = message;
//           req.scene = param.nTarget;    // 0 是分享到好友, 1是分享到朋友圈
//           [WXApi sendReq:req];
//       }
       // [[ThirdParty getInstance] targetShare:pApp share:param];
    }
    else
    {
        [pApp toLuaFunc:nLuaFunC backMsg:"do not support target"];
    }
}

//+ (tagShareParam) getShareParam:(NSDictionary *)dict
+ (void) getShareParam:(NSDictionary *)dict
{
        NSLog(@"in getShareParam");

//    ShareConfig* share = [[ThirdParty getInstance] getDefaultShareConfig];
       NSString* title = [dict objectForKey:@"title"];
       if (nil == title)
       {
           title=@"十三水";    //share.ShareTitle;
       }
       NSString* content = [dict objectForKey:@"content"];
       if (nil == content)
       {
           content =@"十三水";    //share.ShareContent;
       }
       NSString* url = [dict objectForKey:@"url"];
       if (nil == url)
       {
           url = @"十三水";    //share.ShareUrl;
       }
       NSString* img = [dict objectForKey:@"img"];
       if (nil == img)
       {
           img = @"十三水";    //share.ShareMediaPath;
       }
       NSString* imageOnly = [dict objectForKey:@"imageOnly"];
       BOOL bImageOnly = FALSE;
       if (nil != imageOnly && [imageOnly isEqualToString:@"true"])
       {
           bImageOnly = TRUE;
       }
    NSNumber* target = [dict objectForKey:@"target"];

    if (bImageOnly == true)
    {
        [AppController sendWeChatImage:img withTitle:title andDescription:content inScene:target withTransaction:@""];
    }
    else{
        [AppController sendWeChatURL:url withTitle:title andDescription:content inScene:target withTransaction:@""];
    }
    return;
}

//支付
+ (void) thirdPartyPay:(NSDictionary*) dict
{
    NSLog(@"in thirdPartyPay");

//    NSObject* obj = [dict objectForKey:@"_nidx"];
//    if (nil != obj)
//    {
//        NSString *platstr = [[ThirdParty getInstance] getPlatform:[(NSString*)obj intValue]];
//
//        AppController * pApp = (AppController*)[[UIApplication sharedApplication] delegate];
//        //设置回调
//        [pApp setPayCallFunC:[[dict objectForKey:@"scriptHandler"] intValue]];
//        [[ThirdParty getInstance] thirdPartyPay:platstr delegate:pApp payparam:dict];
//    }
}

//获取竣付通支付列表
+ (void) getPayList:(NSDictionary*) dict
{
    NSLog(@"in getPayList");

    AppController * pApp = (AppController*)[[UIApplication sharedApplication] delegate];
    //设置回调
    [pApp setPayCallFunC:[[dict objectForKey:@"scriptHandler"] intValue]];
    //token
    NSString *token = [dict objectForKey:@"token"];
//    [[ThirdParty getInstance] getPayList:token delegate:pApp];
}

//
+ (char) isPlatformInstalled:(NSDictionary*) dict
{
    NSLog(@"in isPlatformInstalled");

//    NSObject* obj = [dict objectForKey:@"_nidx"];
//    if (nil != obj)
//    {
//        NSString *platstr = [[ThirdParty getInstance] getPlatform:[(NSString*)obj intValue]];
//        if (TRUE == [[ThirdParty getInstance] isPlatformInstalled: platstr])
//        {
//            return 1;
//        }
//    }
    return 0;
}

+ (char) saveImgToSystemGallery:(NSDictionary*) dict
{
    NSString *path = [dict objectForKey:@"_filepath"];
    NSString *filename = [dict objectForKey:@"_filename"];
    if (nil != path && nil != filename)
    {
        NSData* imgdata = [NSData dataWithContentsOfFile:path];
        if (nil != imgdata)
        {
            UIImage* saveImg = [[UIImage alloc] initWithData:imgdata];
            if (nil != saveImg)
            {
                UIImageWriteToSavedPhotosAlbum(saveImg, nil, nil, nil);
                return 1;
            }            
        }
    }
    return 0;
}

+ (void) updateBaseClient:(NSDictionary*) dict
{
    NSString *url = [dict objectForKey:@"url"];
    if (nil != url)
    {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]])
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
    }
}

+ (char) isHaveRecordPermission:(NSDictionary*) dict
{
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                bCanRecord = granted;
            }];
        }
    }
    if (TRUE == bCanRecord)
    {
        return 1;
    }
    return 0;
}

+ (void) requestLocation:(NSDictionary*) dict
{
    NSLog(@"in requestLocation");

//    AppController * pApp = (AppController*)[[UIApplication sharedApplication] delegate];
//    //设置回调
//    [pApp setLocationCallFunC:[[dict objectForKey:@"scriptHandler"] intValue]];
//    [[ThirdParty getInstance] requestLocation:pApp];
}

+ (NSString*) metersBetweenLocation:(NSDictionary*) dict
{
    NSLog(@"in metersBetweenLocation");
    return @"1000000";
//    return [[ThirdParty getInstance] metersBetweenLocation:dict];
}

+ (void) requestContact:(NSDictionary*) dict
{
    AppController * pApp = (AppController*)[[UIApplication sharedApplication] delegate];
    //设置回调
    [pApp setContactCallFunC:[[dict objectForKey:@"scriptHandler"] intValue]];
    
    // 权限请求
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status == CNAuthorizationStatusNotDetermined)
    {
        CNContactStore *store = [[CNContactStore alloc] init];
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error)
        {
            if (error)
            {
                NSLog(@"no permission");
                [pApp toLuaToast:"通讯录授权获取异常"];
            }
            else
            {
                //用户给权限了
                NSLog(@"have permission");
                CNContactPickerViewController * picker = [CNContactPickerViewController new];
                picker.delegate = pApp;
                //只显示手机号
                picker.displayedPropertyKeys = @[CNContactPhoneNumbersKey];
                [pApp->viewController presentViewController: picker  animated:YES completion:nil];
            }
        }];
        if (nil != store)
        {
            return;
        }
    }
    
    if (status == CNAuthorizationStatusAuthorized)
    {
        //有权限时
        CNContactPickerViewController * picker = [CNContactPickerViewController new];
        picker.delegate = pApp;
        picker.displayedPropertyKeys = @[CNContactPhoneNumbersKey];
        [pApp->viewController presentViewController: picker  animated:YES completion:nil];
    }
    else
    {
        [pApp toLuaToast:"您未开启通讯录权限,请前往设置中心开启"];
    }
}

+ (void)openBrowser:(NSDictionary*) dict
{
    NSString *url = [dict objectForKey:@"url"];
    if (nil != url)
    {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]])
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
    }
}

+ (char)copyToClipboard:(NSDictionary*) dict
{
    NSString *msg = [dict objectForKey:@"msg"];
    if (nil != msg)
    {
        UIPasteboard *pastboard = [UIPasteboard generalPasteboard];
        pastboard.string = msg;
        return 1;
    }
    return 0;
}

//微信登录
+(void)sendWeChatAuth{
    NSLog(@"---发送微信登录消息---");
    
    if (![WXApi isWXAppInstalled])  {
        NSString *func = NULL;
        NSString *jsFuncFormat = @"cc.poker.NativeEventHandler('onWeChatLoginResp', %d, '%@');";
        func = [NSString stringWithFormat:jsFuncFormat, -7, @""];
        const char*stringFunc = [func UTF8String];
        // TODO 通知微信没有按照
//        se::ScriptEngine::getInstance()->evalString(stringFunc);
    }
    
    SendAuthReq *req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo";
    req.state = @"jchzbz";
    [WXApi sendReq:req];
}

//微信分享URL
+(void)sendWeChatURL:(NSString*)urlString
           withTitle:(NSString*)title
      andDescription:(NSString*)description
             inScene:(NSNumber*)scene
     withTransaction:(NSString*)transaction{
    NSLog(@"---发送微信分享URL消息---");
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = urlString;
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = description;
    message.mediaObject = ext;
    [message setThumbImage:[UIImage imageNamed:@"share.png"]];
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.scene = [scene intValue];
    req.message = message;
    
    [WXApi sendReq:req];
}

//微信分享本地图片
+(BOOL)sendWeChatImage:(NSString*)filePath
             withTitle:(NSString*)title
        andDescription:(NSString*)description
               inScene:(NSNumber*)scene
       withTransaction:(NSString*)transaction{
    NSLog(@"---发送微信分享图片消息--- %@", filePath);
    
    NSData *imageData = [NSData dataWithContentsOfFile:filePath];
    
    BOOL ret = [self sendImgToWeChat:imageData withTitle:title andDescription:description inScene:scene withTransaction:transaction];
    return ret;
}

//微信分享URL图片
+(BOOL)sendWeChatUrlImage:(NSString*)iurl
                withTitle:(NSString*)title
           andDescription:(NSString*)description
                  inScene:(NSNumber*)scene
          withTransaction:(NSString*)transaction{
    NSLog(@"---发送微信分享url图片消息--- %@", iurl);
    
    NSURL *url=[NSURL URLWithString:iurl];
    NSData *imageData=[NSData dataWithContentsOfURL:url];
    
    BOOL ret = [self sendImgToWeChat:imageData withTitle:title andDescription:description inScene:scene withTransaction:transaction];
    return ret;
}

// 将nsdata数据发送给微信分享。
+(BOOL)sendImgToWeChat:(NSData*)imageData
             withTitle:(NSString*)title
        andDescription:(NSString*)description
               inScene:(NSNumber*)scene
       withTransaction:(NSString*)transaction{
    // 压缩缩略图
    UIImage *thumbImage2 = [UIImage imageWithData:imageData];
    if(thumbImage2 == nil)
    { return NO;}
    
    CGFloat origanSize = [self getImageLengthWithImage:thumbImage2];
    NSLog(@"ori image s = %d size 0 = %f w %f h %f", (int)(imageData.length), origanSize, thumbImage2.size.width, thumbImage2.size.height);
    
    CGSize newSize;
    newSize.width = 256;
    newSize.height = 144;
    UIImage * thumbImage = [self imageWithImage:thumbImage2 scaledToSize:newSize];
    origanSize = [self getImageLengthWithImage:thumbImage];
    NSLog(@"ori size 3 = %f w %f h %f", origanSize, thumbImage.size.width, thumbImage.size.height);
    
    
    WXImageObject *ext = [WXImageObject object];
    ext.imageData = imageData;
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = description;
    message.mediaObject = ext;
    message.messageExt = @"messageExt";
    message.messageAction = @"action";
    message.mediaTagName = @"tagName";
    [message setThumbImage:thumbImage];
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.scene = [scene intValue];
    req.message = message;
    
    [WXApi sendReq:req];
    
    return YES;
}

// 压缩图片
+ (UIImage *)scaleImageCompression:(UIImage *)image {
    CGFloat origanSize = [self getImageLengthWithImage:image];
    
    NSLog(@"ori size = %f", origanSize);
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    if (origanSize > 512) {
        imageData=UIImageJPEGRepresentation(image, 0.1);
    } else if (origanSize > 256) {
        imageData=UIImageJPEGRepresentation(image, 0.5);
    }
    UIImage *image1 = [UIImage imageWithData:imageData];
    
    origanSize = [self getImageLengthWithImage:image1];
    NSLog(@"ori size 2 = %f", origanSize);
    
    return image1;
}

+ (UIImage *)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    NSInteger newWidth = (NSInteger)newSize.width;
    NSInteger newHeight = (NSInteger)newSize.height;
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    
    [image drawInRect:CGRectMake(0 , 0,newWidth, newHeight)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

+ (CGFloat)getImageLengthWithImage:(UIImage *)image {
    NSData * imageData = UIImageJPEGRepresentation(image,1);
    CGFloat length = [imageData length]/1000;
    return length;
}

// 微信回调
- (void)onResp:(BaseResp *)resp {
    NSString *func = NULL;
    NSString *backMsg = NULL;
    
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        NSLog(@"--------微信登录onResp-----------");
        SendAuthResp *authResp = (SendAuthResp*)resp;
        switch (resp.errCode) {
            case WXSuccess: {
                [self sendWechatGetAccessToken:authResp];
                break;
            }
            case WXErrCodeUserCancel:
                break;
            case WXErrCodeAuthDeny:
                break;
            case WXErrCodeUnsupport:
                break;
            default:
                break;
        }
    } else if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        NSLog(@"--------微信分享onResp-----------");
        switch (resp.errCode) {
            case WXSuccess:
                break;
            case WXErrCodeUserCancel:
                break;
            default:
                break;
        }
    }
}

- (void)sendWechatGetAccessToken:(SendAuthResp *)authResp
{
    NSString *urlStr = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",@"wx2675e915e32971a4",@"39566d61fc7bf7c96c90c23e64a385d5",authResp.code];
    // 转码URL里面不能包含中文
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlStr];
    // 创建请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url]; // 默认就是GET请求
    request.timeoutInterval = 5; // 设置请求超时
    
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (data) { // 请求成功
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSString *error = dict[@"errcode"];
            if (error) { // 登录失败
                NSLog(@"请求失败!");
            } else {     // 登录成功
                NSString *access_token  =  dict[@"access_token"]; // 接口调用凭证(有效期2h)
                NSString *openid        =  dict[@"openid"];       // 授权用户唯一标识
                
                NSLog(@"请求成功!");
                [self sendWechatGetUserInfo:openid accessToken:access_token];
            }
        } else { // 请求失败
            NSLog(@"网络繁忙, 请稍后再试");
        }
    }];
}

- (void)sendWechatGetUserInfo:(NSString * ) openid accessToken:(NSString *) accesstk
{
    NSString *urlStr = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@&lang=zh_CN",accesstk,openid];
    // 转码URL里面不能包含中文
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url]; // 默认就是GET请求
    request.timeoutInterval = 5; // 设置请求超时
    
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (data) { // 请求成功
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSString *error = dict[@"errcode"];
            if (error) { // 登录失败
                NSLog(@"请求失败!");
            } else {     // 登录成功
                NSString *nickname     =  dict[@"nickname"]; // 接口调用凭证(有效期2h)
                NSString *headimgurl   =  dict[@"headimgurl"];       // 授权用户唯一标识
                NSString *unionid      =  dict[@"unionid"];
                NSString *sex          =  dict[@"sex"];
                NSString *bmsg         =  [NSString stringWithFormat:@"{\"unionid\":\"%@\",\"screen_name\":\"%@\",\"profile_image_url\":\"%@\",\"sex\":%@}",
                                           unionid, nickname, headimgurl, sex];
                NSLog(@"请求成功!");

                AppController * pApp = (AppController*)[[UIApplication sharedApplication] delegate];
                [pApp onLoginSuccess:@"third_WECHAT_CIRCLE" backMsg:bmsg];
            }
        } else { // 请求失败
            NSLog(@"网络繁忙, 请稍后再试");
        }
    }];
}

// 微信回调
- (void)onReq:(BaseReq *)req {
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url
  sourceApplication:(nullable NSString *)sourceApplication
         annotation:(nonnull id)annotation{
    [WXApi handleOpenURL:url delegate:self];  //(微信回调)
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url
            options:(nonnull NSDictionary<NSString *,id> *)options
{
    /*
     if(支付宝回调) return 支付宝回调处理逻辑;
     else if(微信回调) return 微信回调处理逻辑;
     else if(其他第三方回调) return 其他第三方回调处理逻辑;
     else return [MWApi routeMLink:url];
     */
    //必写
    NSLog(@"--------openURL-----------");
    [WXApi handleOpenURL:url delegate:self];  //(微信回调)
    return YES;
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
     cocos2d::Director::getInstance()->purgeCachedData();
}


- (void)dealloc {
    [super dealloc];
}


@end

