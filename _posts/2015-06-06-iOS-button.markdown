---
layout: post
title:  "iOS UIButton"
date:   2015-06-06 12:42:26
categories: jekyll update
---
##### 1. 按钮没有设置高亮态 但却会响应 UIControlStateHighlighted, 默认使用了一层灰色蒙层, 如何忽略高亮?

	button.adjustsImageWhenHighlighted = NO;

##### 2. cornerRadius只能控制底层layer的圆角, UIButton 除了底层layer, 还有 backgroundImageLayer, imageLayer(labelLayer), 如何更改上层layer的圆角?

	//拉伸前景图片
	[image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height/2, image.size.width/2, image.size.height/2, image.size.width/2) resizingMode:UIImageResizingModeStretch]

	实践证明, 按钮的 前景图片 和 前景文字 只能存在一个, 因此最佳实践是 使用 背景图片 + 前景文字

#### 3. 按钮文字偏移, 前景图片偏移

	button.titleEdgeInsets = UIEdgeInsetsMake(100, 0, 0, 0)
	button.imageEdgeInsets = UIEdgeInsetsMake(-100, 0, 0, 0)

#### 4. 按钮任意一个角圆角

	//这种时候一般都需要请出底层layer的遮罩来完成任意的, 所谓遮罩mask, 可以理解为对父layer的切割所剩下的部分

	UIBezierPath *leftPath = [UIBezierPath bezierPathWithRoundedRect:self.leftTabButton.bounds
                                                   byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerBottomLeft)
                                                         cornerRadii:CGSizeMake(3.0, 3.0)];
    
	CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
	maskLayer.frame = headView.bounds;
	maskLayer.path = leftPath.CGPath;
	button.layer.mask = maskLayer;



[jekyll]:      http://jekyllrb.com
[jekyll-gh]:   https://github.com/jekyll/jekyll
[jekyll-help]: https://github.com/jekyll/jekyll-help
