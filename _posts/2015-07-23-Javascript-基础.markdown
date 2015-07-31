---
layout: post
title:  Javascript-基础
date:   2015-07-23-17:13:36
categories: jekyll update
---

#### 1. js的基础
	
	fun 的不定参数 arguments.length

	数组的基本方法
	push, unshift, pop, shift, charAt

	删除元素
	splice(开始, 长度)

	插入元素
	splice(开始, 长度, 元素)

	sort([比较函数])
	a.concat(b) //数组合并
	a.join('-') //数组连接为字符串

	定时器
	setInterval(func, interval) //间隔型
	setTimeout(func, delay) //延时型, 一次

	clearInterval(timer)
	clearTimeout(timer) 

	Date 对象
	getFullYear() 年 
	getMonth()  月(0 ~ 11)
	getDate()  日
	getDay()  星期 (0 ~ 6) 星期日 ~ 星期六

	隐藏和显示
	oDiv.style.display = 'block'
	oDiv.style.display = 'none'

	div移动, 所谓移动就是绝对定位下修改left
	首先 position:absolute; left:0; top:50px;
	offsetLeft / offsetTop  是计算后的左边距 上边距
	offsetWidth / offsetHeight 是计算后的 宽高

	oDiv.style.left = oDiv.offsetLeft + 10 + 'px'


[jekyll]:      http://jekyllrb.com
[jekyll-gh]:   https://github.com/jekyll/jekyll
[jekyll-help]: https://github.com/jekyll/jekyll-help
