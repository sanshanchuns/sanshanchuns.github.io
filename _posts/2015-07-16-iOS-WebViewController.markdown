---
layout: post
title:  iOS-WebViewController
date:   2015-07-16:18:11:06
categories: jekyll update
---


#### 1. 如何hybrid (native + js)

	原生+JS混合app 是一种灵活的写法, 那么该如何做到最大程度的相关调用呢?

	#import "WebViewJavascriptBridge.h" 
	//native, js交互桥 <https://github.com/marcuswestin/WebViewJavascriptBridge>
	//默认是 iOS, Android 看这里 <https://github.com/fangj/WebViewJavascriptBridge>
	//原理看这里 <http://www.v2fs.com/webviewjavascriptbridge/>

	@property(nonatomic, strong) WebViewJavascriptBridge* bridge;
	@property (weak, nonatomic) IBOutlet UIWebView *webView;

	- (void)viewWillAppear:(BOOL)animated{
    	[super viewWillAppear:animated];
    
    	if (_bridge) { return; }
    
	    // [WebViewJavascriptBridge enableLogging]; //打印日志
	    __weak typeof(self) weakSelf = self;
	    _bridge = [WebViewJavascriptBridge bridgeForWebView:weakSelf.webView webViewDelegate:weakSelf handler:^(id data, WVJBResponseCallback responseCallback) {
	        NSLog(@"收到js的数据: %@", data);
	        responseCallback(@"数据传给js");
	    }];
	    
	    [_bridge registerHandler:@"pushViewCtlr" handler:^(id data, WVJBResponseCallback responseCallback) {
	        if ([data isKindOfClass:[NSDictionary class]]) {
	            //js调用native
	            responseCallback(@{@"status":@"1", @"respData":@{@"test":@"test"}});
	        } else {
	            responseCallback(@{@"status":@"0", @"respData":@{@"test":@"test"}});
	        }
	    }];

	    [_bridge send:@"A string sent from ObjC before Webview has loaded." responseCallback:^(id responseData) {
	        NSLog(@"objc got response! %@", responseData);
	    }];
	    
		[_bridge callHandler:@"js_function" data:@{ @"foo":@"before ready" }]; //
	    
	    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]]];
    
	}




















































