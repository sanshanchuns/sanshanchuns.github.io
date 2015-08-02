---
layout: post
title:  iOS-JSPatch实践
date:   2015-07-27-17:54:43
categories: jekyll update
---

#### 1. 引入新类test
	
	require('UIView, UIColor')
	var view = UIView.alloc().init()
	var red = UIColor.redColor()

#### 2. 属性 get / set

	view.setBackgroundColor(redColor);
	var bgColor = view.backgroundColor();

	-- 使用 getProp() 和 setProp_forKey() 获取/添加/修改新的 Property

	defineClass("JPTableViewController", {
	  init: function() {
	     self = self.super().init()
	     self.setProp_forKey("JSPatch", "data")     //添加新的 Property (id data)
	     return self;
	  },
	  viewDidLoad: function() {
	     var data = self.getProp("data")     //获取新的 Property 值
	  }
	})

	-- 使用 valueForKey() 和 setValue_forKey() 获取/修改私有成员变量
	// OC
	@implementation JPTableViewController {
	     NSArray *_data;
	}
	@end
	// JS
	defineClass("JPTableViewController", {
	  viewDidLoad: function() {
	     var data = self.valueForKey("_data")     //get member variables
	     self.setValue_forKey(["JSPatch"], "_data")     //set member variables
	  },
	})

#### 3. 多参数方法用 _ 替代, @selector用 "" 替代

	btn.addTarget_action_forControlEvents(self, "handleBtn:", 1 << 6)
	var tap = UITapGestureRecognizer.alloc().initWithTarget_action(self, "tapAction:")

#### 4. 调用super

	self.super()

#### 5. 可变/不可变 数组用 toJS() 转化

	var vcs = self.viewControllers().toJS() //.获取属性  toJS()转换成JS数组
    	vcs.push(navi) //数组追加

    	var subviews = self.view().subviews().toJS()
  	for (var i = 0; i < subviews.length; i++) {
  		subviews[i].removeFromSuperview()
  	}

#### 6. before, instead, after (self.ORIGXXXX)

	a. instead
	viewDidLoad: function() {
  		self.super().viewDidLoad()
  		//新逻辑
  	}

  	b. after
  	viewDidLoad: function() {
  		self.ORIGviewDidLoad() //原逻辑
  		//新逻辑
  	}

  	c. before
  	viewDidLoad: function() {
  		//新逻辑
  		self.ORIGviewDidLoad() //原逻辑
  	}

#### 7. 定义类

	defineClass('JPViewController: UIViewController', {
	  viewDidLoad: function() {
	    self.super.viewDidLoad();
	    var width = require('UIScreen').mainScreen().bounds().width
	    var btn = require('UIButton').alloc().initWithFrame({x:0, y:100, width:width, height:50})
	    btn.setTitle_forState('Push JPTableViewController', 0)
	    btn.addTarget_action_forControlEvents(self, "handleBtn:", 1 << 6)
	    btn.setBackgroundColor(require('UIColor').grayColor())
	    self.view().addSubview(btn)
	  },
	  handleBtn: function(sender) {
	    var tableViewCtrl = JPTableViewController.alloc().init() 
	    self.navigationController().pushViewController_animated(tableViewCtrl, 1)
	  }
	})

#### 8. 全局版本判断函数

	function version () {
	  var version = require('NSBundle').mainBundle().infoDictionary().objectForKey('CFBundleShortVersionString')
	  return version.toJS()
	}

	function build () {
	  var build = require('NSBundle').mainBundle().infoDictionary().objectForKey('CFBundleVersion')
	  return build.toJS()
	}

#### 9. block 作为参数

	OC
	typedef void (^WVJBResponseCallback)(id responseData);

	[_bridge registerHandler:@"platformInfo" handler:^(id data, WVJBResponseCallback responseCallback) {
        	
    	}];

    	JS
    	require('NSBlock')
      	self.bridge().registerHandler_handler("testObjcCallback", block("id, NSBlock*", function(data, responseCallback){
        
      	}))





[jekyll]:      http://jekyllrb.com
[jekyll-gh]:   https://github.com/jekyll/jekyll
[jekyll-help]: https://github.com/jekyll/jekyll-help
