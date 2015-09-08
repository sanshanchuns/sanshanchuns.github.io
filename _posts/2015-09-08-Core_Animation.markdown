---
layout: post
title:  Core_Animation
date:   2015-09-08-12:34:55
categories: jekyll update
---

4.1 圆角 conrnerRadius

4.2 图层边框 borderWidth, borderColor
	
	borderColor是CGColorRef类型，而不是UIColor，所以它不是Cocoa的内置对象。不过呢，你肯定也清楚图层引用了borderColor，虽然属性声明并不能证明这一点。CGColorRef在引用/释放时候的行为表现得与NSObject极其相似。但是Objective-C语法并不支持这一做法，所以CGColorRef属性即便是强引用也只能通过assign关键字来声明

	边框是跟随图层的边界变化的，而不是图层里面的内容

4.3 阴影 shadowColor，shadowOffset, shadowRadius
	
	shadowColor属性控制着阴影的颜色，和borderColor和backgroundColor一样，它的类型也是CGColorRef。阴影默认是黑色，大多数时候你需要的阴影也是黑色的（其他颜色的阴影看起来是不是有一点点奇怪。。）

	shadowOffset属性控制着阴影的方向和距离。它是一个CGSize的值，宽度控制这阴影横向的位移，高度控制着纵向的位移。shadowOffset的默认值是 {0, -3}，意即阴影相对于Y轴有3个点的向上位移

	shadowRadius属性控制着阴影的模糊度，当它的值是0的时候，阴影就和视图一样有一个非常确定的边界线。当值越来越大的时候，边界线看上去就会越来越模糊和自然。苹果自家的应用设计更偏向于自然的阴影，所以一个非零值再合适不过了

4.3.1 阴影裁剪

	和图层边框不同，图层的阴影继承自内容的外形，而不是根据边界和角半径来确定。为了计算出阴影的形状，Core Animation会将寄宿图（包括子视图，如果有的话）考虑在内，然后通过这些来完美搭配图层形状从而创建一个阴影

	当阴影和裁剪扯上关系的时候就有一个头疼的限制：阴影通常就是在Layer的边界之外，如果你开启了masksToBounds属性，所有从图层中突出来的内容都会被才剪掉。如果我们在我们之前的边框示例项目中增加图层的阴影属性时，你就会发现问题所在

	maskToBounds属性裁剪掉了阴影和内容

	如果你想沿着内容裁切，你需要用到两个图层：一个只画阴影的空的外图层，和一个用masksToBounds裁剪内容的内图层

	//set the corner radius on our layers
	self.layerView1.layer.cornerRadius = 20.0f;
	self.layerView2.layer.cornerRadius = 20.0f;

	//add a border to our layers
	self.layerView1.layer.borderWidth = 5.0f;
	self.layerView2.layer.borderWidth = 5.0f;

	//add a shadow to layerView1
	self.layerView1.layer.shadowOpacity = 0.5f;
	self.layerView1.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
	self.layerView1.layer.shadowRadius = 5.0f;

	//add same shadow to shadowView (not layerView2)
	self.shadowView.layer.shadowOpacity = 0.5f;
	self.shadowView.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
	self.shadowView.layer.shadowRadius = 5.0f;

	//enable clipping on the second layer
	self.layerView2.layer.masksToBounds = YES;

4.3.2 阴影形状 shadowPath

	我们已经知道图层阴影并不总是方的，而是从图层内容的形状继承而来。这看上去不错，但是实时计算阴影也是一个非常消耗资源的，尤其是图层有多个子图层，每个图层还有一个有透明效果的寄宿图的时候。

    如果你事先知道你的阴影形状会是什么样子的，你可以通过指定一个shadowPath来提高性能。shadowPath是一个CGPathRef类型（一个指向CGPath的指针）。CGPath是一个Core Graphics对象，用来指定任意的一个矢量图形。我们可以通过这个属性单独于图层形状之外指定阴影的形状

	//create a square shadow
	CGMutablePathRef squarePath = CGPathCreateMutable();
	CGPathAddRect(squarePath, NULL, self.layerView1.bounds);
	self.layerView1.layer.shadowPath = squarePath; CGPathRelease(squarePath);

	￼//create a circular shadow
	CGMutablePathRef circlePath = CGPathCreateMutable();
	CGPathAddEllipseInRect(circlePath, NULL, self.layerView2.bounds);
	self.layerView2.layer.shadowPath = circlePath; CGPathRelease(circlePath);

	如果是一个矩形或者是圆，用CGPath会相当简单明了。但是如果是更加复杂一点的图形，UIBezierPath类会更合适，它是一个由UIKit提供的在CGPath基础上的Objective-C包装类

4.4 图层蒙版 mask

	CALayer有一个属性叫做mask可以解决这个问题。这个属性本身就是个CALayer类型，有和其他图层一样的绘制和布局属性。它类似于一个子图层，相对于父图层（即拥有该属性的图层）布局，但是它却不是一个普通的子图层。不同于那些绘制在父图层中的子图层，mask图层定义了父图层的部分可见区域。

    mask图层的Color属性是无关紧要的，真正重要的是图层的轮廓。mask属性就像是一个饼干切割机，mask图层实心的部分会被保留下来，其他的则会被抛弃.

    如果mask图层比父图层要小，只有在mask图层里面的内容才是它关心的，除此以外的一切都会被隐藏起来

	//create mask layer
	CALayer *maskLayer = [CALayer layer];
	maskLayer.frame = self.layerView.bounds;
	UIImage *maskImage = [UIImage imageNamed:@"Cone.png"];
	maskLayer.contents = (__bridge id)maskImage.CGImage;

	//apply mask to image layer￼
	self.imageView.layer.mask = maskLayer;

4.5 拉伸过滤 magnificationFilter 
	
	最后我们再来谈谈 minificationFilter 和 magnificationFilter 属性。总得来讲，当我们视图显示一个图片的时候，都应该正确地显示这个图片（意即：以正确的比例和正确的1：1像素显示在屏幕上）。原因如下：

	- 能够显示最好的画质，像素既没有被压缩也没有被拉伸。
	- 能更好的使用内存，因为这就是所有你要存储的东西。
	- 最好的性能表现，CPU不需要为此额外的计算。

    不过有时候，显示一个非真实大小的图片确实是我们需要的效果。比如说一个头像或是图片的缩略图，再比如说一个可以被拖拽和伸缩的大图。这些情况下，为同一图片的不同大小存储不同的图片显得又不切实际
	
	当图片需要显示不同的大小的时候，有一种叫做拉伸过滤的算法就起到作用了。它作用于原图的像素上并根据需要生成新的像素显示在屏幕上。

    事实上，重绘图片大小也没有一个统一的通用算法。这取决于需要拉伸的内容，放大或是缩小的需求等这些因素。CALayer为此提供了三种拉伸过滤方法，他们是：

	- kCAFilterLinear
	- kCAFilterNearest
	- kCAFilterTrilinear

    minification（缩小图片）和magnification（放大图片）默认的过滤器都是 kCAFilterLinear, 这个过滤器采用双线性滤波算法, 它在大多数情况下都表现良好.

    kCAFilterTrilinear 和 kCAFilterLinear 非常相似，大部分情况下二者都看不出来有什么差别。但是，较双线性滤波算法而言，三线性滤波算法存储了多个大小情况下的图片（也叫多重贴图），并三维取样，同时结合大图和小图的存储进而得到最后的结果。

    这个方法的好处在于算法能够从一系列已经接近于最终大小的图片中得到想要的结果，也就是说不要对很多像素同步取样。这不仅提高了性能，也避免了小概率因舍入错误引起的取样失灵的问题

    总的来说，对于比较小的图或者是差异特别明显，极少斜线的大图，kCAFilterNearest 会保留这种差异明显的特质以呈现更好的结果。但是对于大多数的图尤其是有很多斜线或是曲线轮廓的图片来说，kCAFilterNearest 会导致更差的结果。 换句话说，线性过滤保留了形状，最近过滤则保留了像素的差异。

    UIImage *digits = [UIImage imageNamed:@"Digits.png"];

    //set up digit views
  	for (UIView *view in self.digitViews) {
    	//set contents
    	view.layer.contents = (__bridge id)digits.CGImage;
    	view.layer.contentsRect = CGRectMake(0, 0, 0.1, 1.0); //大图的一部分
    	view.layer.contentsGravity = kCAGravityResizeAspect;
    	view.layer.magnificationFilter = kCAFilterNearest;
  	}

  	- (void)setDigit:(NSInteger)digit forView:(UIView *)view
	{
  		//adjust contentsRect to select correct digit
  		view.layer.contentsRect = CGRectMake(digit * 0.1, 0, 0.1, 1.0);
	}


4.6 组透明 shouldRasterize

	UIView有一个叫做alpha的属性来确定视图的透明度。CALayer有一个等同的属性叫做opacity，这两个属性都是影响子层级的.也就是说，如果你给一个图层设置了opacity属性，那它的子图层都会受此影响。

	你可以设置CALayer的一个叫做shouldRasterize属性（见清单4.7）来实现组透明的效果，如果它被设置为YES，在应用透明度之前，图层及其子图层都会被整合成一个整体的图片，这样就没有透明度混合的问题了

	为了启用shouldRasterize属性，我们设置了图层的rasterizationScale属性。默认情况下，所有图层拉伸都是1.0， 所以如果你使用了shouldRasterize属性，你就要确保你设置了rasterizationScale属性去匹配屏幕，以防止出现Retina屏幕像素化的问题。

    当shouldRasterize和UIViewGroupOpacity一起的时候，性能问题就出现了

  	//enable rasterization for the translucent button
  	button2.layer.shouldRasterize = YES;
  	button2.layer.rasterizationScale = [UIScreen mainScreen].scale;



[jekyll]:      http://jekyllrb.com
[jekyll-gh]:   https://github.com/jekyll/jekyll
[jekyll-help]: https://github.com/jekyll/jekyll-help
