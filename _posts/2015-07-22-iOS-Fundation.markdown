---
layout: post
title:  iOS-Fundation
date:   2015-07-22-16:36:34
categories: jekyll update
---


#### 1. RunLoop
	
	请戳这里 <http://blog.ibireme.com/2015/05/18/runloop/>

	RunLoopMode
	
		NSDefaultRunLoopMode 这是大多数操作中使用的模式。
		NSConnectionReplyMode 该模式用来监控NSConnection对象。你通常不需要在你的代码中使用该模式。
		NSModalPanelRunLoopMode Cocoa使用该模式来标识用于modal panel（模态面板）的事件。
		NSEventTracking（UITrackingRunLoopMode） Cocoa使用该模式来处理用户界面相关的事件。
		NSRunLoopCommonModes 这是一组可配置的通用模式。将input sources与该模式关联则同时也将input sources与该组中的其它模式进行了关联。对于Cocoa应用，该模式缺省的包含了default，modal以及event tracking模式。

		一个常见的问题就是，主线程中一个NSTimer添加在default mode中，当界面上有一些scroll view的滚动频繁发生导致run loop运行在UItraking mode中，从而这个timer没能如期望那般的运行。所以，我们就可以把这个timer加到NSRunLoopCommonModes中来解决（iOS中）

	NSTimer 

		其实就是 CFRunLoopTimerRef，他们之间是 toll-free bridged 的。一个 NSTimer 注册到 RunLoop 后，RunLoop 会为其重复的时间点注册好事件。例如 10:00, 10:10, 10:20 这几个时间点。RunLoop为了节省资源，并不会在非常准确的时间点回调这个Timer。Timer 有个属性叫做 Tolerance (宽容度)，标示了当时间点到后，容许有多少最大误差。

		如果某个时间点被错过了，例如执行了一个很长的任务，则那个时间点的回调也会跳过去，不会延后执行。就比如等公交，如果 10:10 时我忙着玩手机错过了那个点的公交，那我只能等 10:20 这一趟了。

	CADisplayLink 

		是一个和屏幕刷新率一致的定时器（但实际实现原理更复杂，和 NSTimer 并不一样，其内部实际是操作了一个 Source）。如果在两次屏幕刷新之间执行了一个长任务，那其中就会有一帧被跳过去（和 NSTimer 相似），造成界面卡顿的感觉。在快速滑动TableView时，即使一帧的卡顿也会让用户有所察觉。Facebook 开源的 AsyncDisplayLink 就是为了解决界面卡顿的问题，其内部也用到了 RunLoop.

#### 2. Method Swizzling

	在 Objective-C 中调用一个方法, 其实是向一个对象发送消息, 查找消息的唯一依据是selector的名字.利用Objective-C的动态特性, 可以实现在运行时偷换selector对应的方法实现, 达到给方法挂钩的目的.
	每个类都有一个方法列表，存放着selector的名字和方法实现的映射关系。IMP有点类似函数指针，指向具体的Method实现
	
	method_exchangeImplementations 来交换2个方法中的IMP
	class_replaceMethod 来修改类
	method_setImplementation 来直接设置某个方法的IMP

#### 3. block

	As a local variable:

		returnType (^blockName)(parameterTypes) = ^returnType(parameters) {...};

	As a property:

		@property (nonatomic, copy) returnType (^blockName)(parameterTypes);

	As a method parameter:

		- (void)someMethodThatTakesABlock:(returnType (^)(parameterTypes))blockName;

	As an argument to a method call:

		[someObject someMethodThatTakesABlock:^returnType (parameters) {...}];

	As a typedef:

		typedef returnType (^TypeName)(parameterTypes);
		TypeName blockName = ^returnType(parameters) {...};


#### 4. 通讯录中文字首字母

	firstChar = [[NSString stringWithFormat:@"%c", pinyinFirstLetter([name characterAtIndex:0])] uppercaseString];


#### 5. runtime.h

	/** 
	 * Adds a new method to a class with a given name and implementation.
	 * 
	 * @param cls The class to which to add a method.
	 * @param name A selector that specifies the name of the method being added.
	 * @param imp A function which is the implementation of the new method. The function must take at least two arguments—self and _cmd.
	 * @param types An array of characters that describe the types of the arguments to the method. 
	 * 
	 * @return YES if the method was added successfully, otherwise NO 
	 *  (for example, the class already contains a method implementation with that name).
	 *
	 * @note class_addMethod will add an override of a superclass's implementation, 
	 *  but will not replace an existing implementation in this class. 
	 *  To change an existing implementation, use method_setImplementation.
	 */
	OBJC_EXPORT BOOL class_addMethod(Class cls, SEL name, IMP imp, const char *types)

	类中添加一个方法, 当且仅当该类存在同名方法, 添加失败. 其他情况比如父类有同名方法, 则当前类重写该方法
	如果想要改变一个已经存在的方式实现, 需要使用 method_setImplementation


	/** 
	 * Replaces the implementation of a method for a given class.
	 * 
	 * @param cls The class you want to modify.
	 * @param name A selector that identifies the method whose implementation you want to replace.
	 * @param imp The new implementation for the method identified by name for the class identified by cls.
	 * @param types An array of characters that describe the types of the arguments to the method. 
	 *  Since the function must take at least two arguments—self and _cmd, the second and third characters
	 *  must be “@:” (the first character is the return type).
	 * 
	 * @return The previous implementation of the method identified by \e name for the class identified by \e cls.
	 * 
	 * @note This function behaves in two different ways:
	 *  - If the method identified by \e name does not yet exist, it is added as if \c class_addMethod were called. 
	 *    The type encoding specified by \e types is used as given.
	 *  - If the method identified by \e name does exist, its \c IMP is replaced as if \c method_setImplementation were called.
	 *    The type encoding specified by \e types is ignored.
	 */
	OBJC_EXPORT IMP class_replaceMethod(Class cls, SEL name, IMP imp, const char *types)


#### 6. Cookie

	NSURL *cookieHost = [NSURL URLWithString:kServerAddress];
    
    	NSHTTPCookie *cookieSkey = [NSHTTPCookie cookieWithProperties: @{NSHTTPCookieDomain:[cookieHost host], NSHTTPCookiePath:[cookieHost path], NSHTTPCookieName:@"skey", NSHTTPCookieValue:skey}];
    	NSHTTPCookie *cookieDeviceId = [NSHTTPCookie cookieWithProperties: @{NSHTTPCookieDomain:[cookieHost host], NSHTTPCookiePath:[cookieHost path], NSHTTPCookieName:@"deviceId", NSHTTPCookieValue:[YJ_OpenUDID value]}];
    	[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookieSkey];
    	[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookieDeviceId];

#### 7. 系统声音播放
        SystemSoundID sounds[0];
	NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"msgcome" ofType:@"wav"];
        CFURLRef soundURL = (__bridge CFURLRef)[NSURL fileURLWithPath:soundPath];
        AudioServicesCreateSystemSoundID(soundURL, &sounds[0]);
        AudioServicesPlaySystemSound(sounds[0]);

        OR

        AudioServicesPlaySystemSound (1007);   编号参考这里 <http://iphonedevwiki.net/index.php/AudioServices>



[jekyll]:      http://jekyllrb.com
[jekyll-gh]:   https://github.com/jekyll/jekyll
[jekyll-help]: https://github.com/jekyll/jekyll-help
