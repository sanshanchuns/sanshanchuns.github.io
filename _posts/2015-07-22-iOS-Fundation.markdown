---
layout: post
title:  iOS-Fundation
date:   2015-07-22-16:36:34
categories: jekyll update
---


#### 1. NSTimer 计时器

	RunLoopMode
	
	NSDefaultRunLoopMode 这是大多数操作中使用的模式。
	NSConnectionReplyMode 该模式用来监控NSConnection对象。你通常不需要在你的代码中使用该模式。
	NSModalPanelRunLoopMode Cocoa使用该模式来标识用于modal panel（模态面板）的事件。
	NSEventTracking（UITrackingRunLoopMode） Cocoa使用该模式来处理用户界面相关的事件。
	NSRunLoopCommonModes 这是一组可配置的通用模式。将input sources与该模式关联则同时也将input sources与该组中的其它模式进行了关联。对于Cocoa应用，该模式缺省的包含了default，modal以及event tracking模式。

	一个常见的问题就是，主线程中一个NSTimer添加在default mode中，当界面上有一些scroll view的滚动频繁发生导致run loop运行在UItraking mode中，从而这个timer没能如期望那般的运行。所以，我们就可以把这个timer加到NSRunLoopCommonModes中来解决（iOS中）

#### 2. Method Swizzling

	在 Objective-C 中调用一个方法, 其实是向一个对象发送消息, 查找消息的唯一依据是selector的名字.利用Objective-C的动态特性, 可以实现在运行时偷换selector对应的方法实现, 达到给方法挂钩的目的.
	每个类都有一个方法列表，存放着selector的名字和方法实现的映射关系。IMP有点类似函数指针，指向具体的Method实现
	
	method_exchangeImplementations 来交换2个方法中的IMP
	class_replaceMethod 来修改类
	method_setImplementation 来直接设置某个方法的IMP
	

[jekyll]:      http://jekyllrb.com
[jekyll-gh]:   https://github.com/jekyll/jekyll
[jekyll-help]: https://github.com/jekyll/jekyll-help
