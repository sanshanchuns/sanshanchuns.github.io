---
layout: post
title:  "About UIButton"
date:   2015-06-06 12:42:26
categories: jekyll update
---

关卡1 创建一个自定义button
-------------------------------------------------------------------------------

	1. UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	2. button.frame = CGRectMake(0, 0, 100, 100);
	3. button.center = self.view.center; //居中

//使用图片的颜色扩展来生成纯色的图片
[button setImage:[UIImage imageWithColor:[UIColor redColor] size:button.bounds.size] forState:UIControlStateNormal]; //常态为红色

[button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
[self.view addSubview:button];

- (void)buttonAction:(UIButton*)button{
    NSLog(@"button clicked");
}


关卡2 给按钮添加选中状态
-------------------------------------------------------------------------------
[button setImage:[UIImage imageWithColor:[UIColor purpleColor] size:button.bounds.size] forState:UIControlStateSelected]; //选中态为紫色

- (void)buttonAction:(UIButton*)button{
    NSLog(@"button clicked");
    button.selected = !button.selected; //点击事件中切换状态
}

问题: 虽然按钮没有设置高亮态 但却会响应 UIControlStateHighlighted, 默认使用了一层灰色蒙层
方法: button.adjustsImageWhenHighlighted = NO; 这样按钮会忽略高亮态

关卡3 按钮圆角
-------------------------------------------------------------------------------
button.layer.cornerRadius = 3.0;

问题: layer 只能控制底层layer的圆角, UIButton 除了底层layer, 还有 backgroundImageLayer, imageLayer(labelLayer)
方法: 可以调用绘图API-CGContextFillPath, (Path 使用贝塞尔圆角矩形创建)绘制圆角矩形, 或者直接PS一个小小的圆角正方形, 比如20*20像素, 调用拉伸方法
[image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height/2, image.size.width/2, image.size.height/2, image.size.width/2) resizingMode:UIImageResizingModeStretch] 来拉伸图片填充整个button

补充: 实践证明, 按钮的 前景图片 和 前景文字 只能存在一个, 因此最佳实践是 使用 背景图片 + 前景文字

关卡4 按钮文字偏移
-------------------------------------------------------------------------------
描述: 通常文字都位于背景图片的上方, 能偏移嘛?
方法: button.titleEdgeInsets = UIEdgeInsetsMake(100, 0, 0, 0)
补充: 同理会有 button.imageEdgeInsets = UIEdgeInsetsMake(-100, 0, 0, 0) 用来偏移前景图片

关卡5 按钮任意一个角圆角
-------------------------------------------------------------------------------
描述: 四个角全部圆角设置 cornerRadius 即可, 那么其中任意一个圆角呢?
方法: 这种时候一般都需要请出底层layer的遮罩来完成任意的, 所谓遮罩mask, 可以理解为对父layer的切割剩下的部分

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
