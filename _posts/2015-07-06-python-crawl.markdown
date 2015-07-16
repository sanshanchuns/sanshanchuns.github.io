---
layout: post
title:  python-basic
date:   2015-07-06:10:39:21
categories: jekyll update
---

#### 1. 阶乘计算
	reduce(lambda x,y : x+y, range(100))

	reduce(...)
    	reduce(function, sequence[, initial]) -> value
    
	    Apply a function of two arguments cumulatively to the items of a sequence,
	    from left to right, so as to reduce the sequence to a single value.
	    For example, reduce(lambda x, y: x+y, [1, 2, 3, 4, 5]) calculates
	    ((((1+2)+3)+4)+5).  If initial is present, it is placed before the items
	    of the sequence in the calculation, and serves as a default when the
	    sequence is empty


#### 2. 包和模块
	
	模块按目录组织就是包
	必需 __init__.py

	for example:

		#!/usr/local/bin/python
		#coding:utf-8

		def ...


		def ...

		if __name__ == "__main__":
			return "直接执行"
		else:
			return "模块调用执行"

	import ...
	import ... as ...
	from ... import ...

	import leopak.cal
	leopak.cal.add(1,2)

	from leopak import cal
	cal.add(1,2)

	from leopak.cal import add
	add(1,2)

#### 3. 正则表达式
	
	[]
	用来指定一个字符集 [abc], [a-z], 
	补集用来匹配不在字符集范围内的字符[^5] [^abc]
	元字符在字符集中不起作用 [abc&abc] [abc^]

	^
	匹配行首

	$
	匹配行尾

	\
	反斜杠通常用来转义, 比如 \^, \$, \\
	\d 相当于 [0-9]
	\D 相当于 [^0-9]
	\s 相当于 [\t\n\r\f\v], 匹配任何空白字符
	\S 相当于 [^\t\n\r\f\v], 匹配任何非空字符
	\w 相当于 [a-zA-Z0-9_]
	\W 取反

	\d{8}
	重复 8 次 数字
	*
	重复 0次或多次
	+
	重复 1次或多次
	?
	重复 0次或1次, 表示可有可无, 贪婪/非贪婪

	比如 re.findall("ab+", "abbbbbbbbbbb") --> ['abbbbbbbbbbbbb']
	re.findall("ab+?", "abbbbbbbbbbbb")  --> ['ab']

	i
	alpha_re = re.compile(r'abcd', re.I)  大小写不敏感 re.IGNORECASE,  compile 是编译命令, 返回编译后的正则对象
	r
	字符串前加 'r' 反斜杠就不会被处理,

	编译之后的正则对象常用的方法

	re.findall()
	re.match(), 匹配字符串头  --> group() 输出, start() 开始位置, end() 结束位置, span() 开始,结束的元组
	re.search(), 匹配整个字符串
	re.finditer()
	re.sub(pattern, replacement, string)  正则替换
	re.split(pattern, string) 分割

	-flags 编译标识


#### 4. 基础的爬虫
	#!/usr/local/bin/python
	#coding=utf-8

	import re, urllib

	def getHtml(url):
		page = urllib.urlopen(url)
	 	html = page.read()
	 	return html

	def getImage(html):
	 	reg = r'<img.+src="(.+\.jpg)"'
	 	imageList = re.findall(reg, html)
	 	count = 0
	 	for l in imageList:
	 		urllib.urlretrieve(l, '%d.jpg' %s count)
	 		count++

	# html = getHtml("http://www.style.com/street/tommy-ton/2015/spring-2016-menswear-street-style/")
	html = getHtml("http://www.style.com/slideshows/slideshows/street/tommy-ton/spring-2016-menswear/slides/")
	getImage(html)


#### 5. scrapy 爬虫框架. xpath

	response.xpath('//div/img/@src').extract()  -- 命令行获取响应里的所有 div下的img的src属性 文本化该属性
		









































