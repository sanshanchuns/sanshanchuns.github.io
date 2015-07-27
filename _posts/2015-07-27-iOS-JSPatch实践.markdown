---
layout: post
title:  iOS-JSPatch实践
date:   2015-07-27-17:54:43
categories: jekyll update
---

1. 如何定义 @selector(tapAction:)

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

2. 引入新类
	
	require('UIView, UIColor')
	var view = UIView.alloc().init()
	var red = UIColor.redColor()

3. property

	view.setBackgroundColor(redColor);
	var bgColor = view.backgroundColor();


[jekyll]:      http://jekyllrb.com
[jekyll-gh]:   https://github.com/jekyll/jekyll
[jekyll-help]: https://github.com/jekyll/jekyll-help
