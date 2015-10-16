---
layout: post
title:  Core_Animation
date:   2015-09-08-12:34:55
categories: jekyll update
---

1.1 图层与视图

	CALayer类在概念上和UIView类似，同样也是一些被层级关系树管理的矩形块，同样也可以包含一些内容（像图片，文本或者背景色），管理子图层的位置。它们有一些方法和属性用来做动画和变换。和UIView最大的不同是CALayer不处理用户的交互

	但是为什么iOS要基于UIView和CALayer提供两个平行的层级关系呢？为什么不用一个简单的层级来处理所有事情呢？原因在于要做职责分离，这样也能避免很多重复代码。在iOS和Mac OS两个平台上，事件和用户交互有很多地方的不同，基于多点触控的用户界面和基于鼠标键盘有着本质的区别，这就是为什么iOS有UIKit和UIView，但是Mac OS有AppKit和NSView的原因。他们功能上很相似，但是在实现上有着显著的区别。

	实际上，这里并不是两个层级关系，而是四个，每一个都扮演不同的角色，除了视图层级和图层树之外，还存在呈现树和渲染树.

1.2 图层的能力

	我们已经证实了图层不能像视图那样处理触摸事件，那么他能做哪些视图不能做的呢？这里有一些UIView没有暴露出来的CALayer的功能：

	a. 阴影，圆角，带颜色的边框
	b. 3D变换
	c. 非矩形范围
	透明遮罩
	多级非线性动画

1.3 使用图层

2.1 contents 属性

2.2 自定义绘制

3.1 布局

3.2 锚点

3.3 坐标系

3.4 Hit Testing

3.5 自动布局

4.1 圆角 conrnerRadius

	CALayer有一个叫做conrnerRadius的属性控制着图层角的曲率。它是一个浮点数，默认为0（为0的时候就是直角），但是你可以把它设置成任意值。默认情况下，这个曲率值只影响背景颜色而不影响背景图片或是子图层。不过，如果把masksToBounds设置成YES的话，图层里面的所有东西都会被截取


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

  	button2.layer.shouldRasterize = YES;
  	button2.layer.rasterizationScale = [UIScreen mainScreen].scale;

5.1 仿射变换

	UIView可以通过设置transform属性做变换，但实际上它只是封装了内部图层的变换.
	注意哦, (^_^) CALayer同样也有一个transform属性，但它的类型是CATransform3D，而不是CGAffineTransform
	CALayer对应于UIView的transform属性叫做affineTransform

	CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_4);
    	self.layerView.layer.affineTransform = transform;

    	C的数学函数库（iOS会自动引入）提供了pi的一些简便的换算，M_PI_4于是就是pi的四分之一，如果对换算不太清楚的话，可以用如下的宏做换算：

    	#define RADIANS_TO_DEGREES(x) ((x)/M_PI*180.0)

5.1.1 混合变换

	如果需要混合两个已经存在的变换矩阵，就可以使用如下方法，在两个变换的基础上创建一个新的变换

	CGAffineTransformConcat(CGAffineTransform t1, CGAffineTransform t2);

	CGAffineTransform transform = CGAffineTransformIdentity; 
    	transform = CGAffineTransformScale(transform, 0.5, 0.5);//scale by 50%
    	transform = CGAffineTransformRotate(transform, M_PI / 180.0 * 30.0);//rotate by 30 degrees
    	transform = CGAffineTransformTranslate(transform, 200, 0);

    	self.layerView.layer.affineTransform = transform;

    	有些需要注意的地方：图片向右边发生了平移，但并没有指定距离那么远（200像素），另外它还有点向下发生了平移。原因在于当你按顺序做了变换，上一个变换的结果将会影响之后的变换，所以200像素的向右平移同样也被旋转了30度，缩小了50%，所以它实际上是斜向移动了100像素

    	这意味着变换的顺序会影响最终的结果，也就是说旋转之后的平移和平移之后的旋转结果可能不同

5.2 3D变换
	
	和CGAffineTransform矩阵类似，Core Animation提供了一系列的方法用来创建和组合CATransform3D类型的矩阵，和Core Graphics的函数类似，但是3D的平移和旋转多处了一个z参数，并且旋转函数除了angle之外多出了x,y,z三个参数，分别决定了每个坐标轴方向上的旋转

	CATransform3DMakeRotation(CGFloat angle, CGFloat x, CGFloat y, CGFloat z)
	CATransform3DMakeScale(CGFloat sx, CGFloat sy, CGFloat sz) 
	CATransform3DMakeTranslation(Gloat tx, CGFloat ty, CGFloat tz)

	CATransform3D transform = CATransform3DMakeRotation(M_PI_4, 0, 1, 0);
    	self.layerView.layer.transform = transform;

5.2.1 透视投影 (生成虚像)

	为了做一些修正，我们需要引入投影变换（又称作z变换）来对除了旋转之外的变换矩阵做一些修改，Core Animation并没有给我们提供设置透视变换的函数，因此我们需要手动修改矩阵值，幸运的是，很简单：

	CATransform3D的透视效果通过一个矩阵中一个很简单的元素来控制：m34。m34用于按比例缩放X和Y的值来计算到底要离视角多远.m34的默认值是0，我们可以通过设置m34为-1.0 / d来应用透视效果，d代表了想象中视角相机和屏幕之间的距离，以像素为单位，那应该如何计算这个距离呢？实际上并不需要，大概估算一个就好了.

	因为视角相机实际上并不存在，所以可以根据屏幕上的显示效果自由决定它的防止的位置。通常500-1000就已经很好了，但对于特定的图层有时候更小后者更大的值会看起来更舒服，减少距离的值会增强透视效果，所以一个非常微小的值会让它看起来更加失真，然而一个非常大的值会让它基本失去透视效果

	CATransform3D transform = CATransform3DIdentity;
	transform.m34 = - 1.0 / 500.0;
	transform = CATransform3DRotate(transform, M_PI_4, 0, 1, 0);
	self.layerView.layer.transform = transform;


5.2.2 组透视 sublayerTransform

	CALayer有一个属性叫做sublayerTransform。它也是CATransform3D类型，但和对一个图层的变换不同，它影响到所有的子图层。这意味着你可以一次性对包含这些图层的容器做变换，于是所有的子图层都自动继承了这个变换方法

	CATransform3D perspective = CATransform3DIdentity;
	perspective.m34 = - 1.0 / 500.0;
	self.containerView.layer.sublayerTransform = perspective;

	//rotate layerView1 by 45 degrees along the Y axis
	CATransform3D transform1 = CATransform3DMakeRotation(M_PI_4, 0, 1, 0);
	self.layerView1.layer.transform = transform1;

	//rotate layerView2 by 45 degrees along the Y axis
	CATransform3D transform2 = CATransform3DMakeRotation(-M_PI_4, 0, 1, 0);
	self.layerView2.layer.transform = transform2;


5.2.3 背面 doubleSided

	我们既然可以在3D场景下旋转图层，那么也可以从背面去观察它。如果我们在清单5.4中把角度修改为M_PI（180度）而不是当前的M_PI_4（45度），那么将会把图层完全旋转一个半圈，于是完全背对了相机视角

	那么从背部看图层是什么样的呢? 视图的背面，一个镜像对称的图片
	如你所见，图层是双面绘制的，反面显示的是正面的一个镜像图片。

	但这并不是一个很好的特性，因为如果图层包含文本或者其他控件，那用户看到这些内容的镜像图片当然会感到困惑。另外也有可能造成资源的浪费：想象用这些图层形成一个不透明的固态立方体，既然永远都看不见这些图层的背面，那为什么浪费GPU来绘制它们呢？

	CALayer有一个叫做 doubleSided 的属性来控制图层的背面是否要被绘制。这是一个BOOL类型，默认为YES，
	如果设置为NO，那么当图层正面从相机视角消失的时候，它将不会被绘制.

5.3 立方体

	#import "ViewController.h"
	#import <GLKit/GLKit.h>

	#define LIGHT_DIRECTION 0, 1, -0.5
	#define AMBIENT_LIGHT 0.5

	@interface ViewController ()

	@property (nonatomic, strong) UIView *containerView;
	@property (nonatomic, strong) NSMutableArray *faces;

	@end

	@implementation ViewController

	- (void)addFace:(NSInteger)index withTransform:(CATransform3D)transform
	{
	    //get the face view and add it to the container
	    UIView *face = self.faces[index];
	    [self.containerView addSubview:face];
	    //center the face view within the container
	    CGSize containerSize = self.containerView.bounds.size;
	    face.center = CGPointMake(containerSize.width / 2.0, containerSize.height / 2.0);
	    // apply the transform
	    face.layer.transform = transform;
	    //apply lighting
	    [self applyLightingToFace:face.layer];
	}

	- (void)viewDidLoad
	{
	    [super viewDidLoad];
	    
	    self.containerView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	    [self.view addSubview:self.containerView];
	    
	    self.faces = [NSMutableArray arrayWithCapacity:6];
	    
	    for (int i = 0; i < 6; i++) {
	        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
	        view.backgroundColor = [UIColor whiteColor];
	        view.layer.borderWidth = 1;
	        if (i == 2 || i == 1 || i == 0) {
	            view.userInteractionEnabled = YES;
	        } else {
	            view.userInteractionEnabled = NO;
	        }
	        
	        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	        button.frame = CGRectMake(0, 0, 100, 100);
	        button.layer.cornerRadius = 10;
	        [button setTitle:[NSString stringWithFormat:@"%d", i] forState:UIControlStateNormal];
	        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	        [button setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
	        button.backgroundColor = [UIColor blueColor];
	        button.center = view.center;
	        button.titleLabel.font = [UIFont systemFontOfSize:50];
	        button.titleLabel.textAlignment = NSTextAlignmentCenter;
	        
	        [view addSubview:button];
	        [self.faces addObject:view];
	        [self.containerView addSubview:view];
	    }
	    
	    //set up the container sublayer transform
	    CATransform3D perspective = CATransform3DIdentity;
	    perspective.m34 = -1.0 / 500.0;
	    perspective = CATransform3DRotate(perspective, -M_PI_4, 1, 0, 0);
	    perspective = CATransform3DRotate(perspective, -M_PI_4, 0, 1, 0);
	    self.containerView.layer.sublayerTransform = perspective;
	    //add cube face 1
	    CATransform3D transform = CATransform3DMakeTranslation(0, 0, 100);
	    [self addFace:0 withTransform:transform];
	    //add cube face 2
	    transform = CATransform3DMakeTranslation(100, 0, 0);
	    transform = CATransform3DRotate(transform, M_PI_2, 0, 1, 0);
	    [self addFace:1 withTransform:transform];
	    //add cube face 3
	    transform = CATransform3DMakeTranslation(0, -100, 0);
	    transform = CATransform3DRotate(transform, M_PI_2, 1, 0, 0);
	    [self addFace:2 withTransform:transform];
	    //add cube face 4
	    transform = CATransform3DMakeTranslation(0, 100, 0);
	    transform = CATransform3DRotate(transform, -M_PI_2, 1, 0, 0);
	    [self addFace:3 withTransform:transform];
	    //add cube face 5
	    transform = CATransform3DMakeTranslation(-100, 0, 0);
	    transform = CATransform3DRotate(transform, -M_PI_2, 0, 1, 0);
	    [self addFace:4 withTransform:transform];
	    //add cube face 6
	    transform = CATransform3DMakeTranslation(0, 0, -100);
	    transform = CATransform3DRotate(transform, M_PI, 0, 1, 0);
	    [self addFace:5 withTransform:transform];
	}

	- (void)applyLightingToFace:(CALayer *)face
	{
	    //add lighting layer
	    CALayer *layer = [CALayer layer];
	    layer.frame = face.bounds;
	    [face addSublayer:layer];
	    //convert the face transform to matrix
	    //(GLKMatrix4 has the same structure as CATransform3D)
	    //译者注：GLKMatrix4和CATransform3D内存结构一致，但坐标类型有长度区别，所以理论上应该做一次float到CGFloat的转换，感谢[@zihuyishi](https://github.com/zihuyishi)同学~
	    CATransform3D transform = face.transform;
	    GLKMatrix4 matrix4 = *(GLKMatrix4 *)&transform;
	    GLKMatrix3 matrix3 = GLKMatrix4GetMatrix3(matrix4);
	    //get face normal
	    GLKVector3 normal = GLKVector3Make(0, 0, 1);
	    normal = GLKMatrix3MultiplyVector3(matrix3, normal);
	    normal = GLKVector3Normalize(normal);
	    //get dot product with light direction
	    GLKVector3 light = GLKVector3Normalize(GLKVector3Make(LIGHT_DIRECTION));
	    float dotProduct = GLKVector3DotProduct(light, normal);
	    //set lighting layer opacity
	    CGFloat shadow = 1 + dotProduct - AMBIENT_LIGHT;
	    UIColor *color = [UIColor colorWithWhite:0 alpha:shadow];
	    layer.backgroundColor = color.CGColor;
	}

6.1 形状层 CAShaperLayer

	CAShapeLayer是一个通过矢量图形而不是bitmap来绘制的图层子类。你指定诸如颜色和线宽等属性，用CGPath来定义想要绘制的图形，最后CAShapeLayer就自动渲染出来了。当然，你也可以用Core Graphics直接向原始的CALyer的内容中绘制一个路径，相比直下，使用CAShapeLayer有以下一些优点：

	- 渲染快速。CAShapeLayer使用了硬件加速，绘制同一图形会比用Core Graphics快很多。
	- 高效使用内存。一个CAShapeLayer不需要像普通CALayer一样创建一个寄宿图形，所以无论有多大，都不会占用太多的内存。
	- 不会被图层边界剪裁掉。一个CAShapeLayer可以在边界之外绘制。你的图层路径不会像在使用Core Graphics 的普通 CALayer 一样被剪裁掉（如我们在第二章所见）。
	- 不会出现像素化。当你给CAShapeLayer做3D变换时，它不像一个有寄宿图的普通图层一样变得像素化。

	虽然使用CAShapeLayer类需要更多的工作，但是它有一个优势就是可以单独指定每个角。
	我们创建圆角矩形其实就是人工绘制单独的直线和弧度，但是事实上UIBezierPath有自动绘制圆角矩形的构造方法，下面这段代码绘制了一个有三个圆角一个直角的矩形：

	CGRect rect = CGRectMake(50, 50, 100, 100);
	CGSize radii = CGSizeMake(20, 20);
	UIRectCorner corners = UIRectCornerTopRight | UIRectCornerBottomRight | UIRectCornerBottomLeft;

	UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:radii];

6.2 文本层 CATextLayer

	Core Animation提供了一个CALayer的子类CATextLayer，它以图层的形式包含了UILabel几乎所有的绘制特性，并且额外提供了一些新的特性.
	同样，CATextLayer也要比UILabel渲染得快得多。很少有人知道在iOS 6及之前的版本，UILabel其实是通过WebKit来实现绘制的，这样就造成了当有很多文字的时候就会有极大的性能压力。而CATextLayer使用了Core text，并且渲染得非常快

	CATextLayer *textLayer = [CATextLayer layer];
	textLayer.frame = self.labelView.bounds;
	[self.labelView.layer addSublayer:textLayer];

	//set text attributes
	textLayer.foregroundColor = [UIColor blackColor].CGColor;
	textLayer.alignmentMode = kCAAlignmentJustified;
	textLayer.wrapped = YES;

	//choose a font
	UIFont *font = [UIFont systemFontOfSize:15];

	//set layer font
	CFStringRef fontName = (__bridge CFStringRef)font.fontName;
	CGFontRef fontRef = CGFontCreateWithFontName(fontName);
	textLayer.font = fontRef;
	textLayer.fontSize = font.pointSize;
	CGFontRelease(fontRef);

	//choose some text
	NSString *text = @"test";

	//set layer text
	textLayer.string = text;

	如果你仔细看这个文本，你会发现一个奇怪的地方：这些文本有一些像素化了。这是因为并没有以Retina的方式渲染，第二章提到了这个contentScale属性，用来决定图层内容应该以怎样的分辨率来渲染。contentsScale并不关心屏幕的拉伸因素而总是默认为1.0。如果我们想以Retina的质量来显示文字，我们就得手动地设置CATextLayer的contentsScale属性，如下：

	textLayer.contentsScale = [UIScreen mainScreen].scale;

	CATextLayer的font属性不是一个UIFont类型，而是一个CFTypeRef类型。这样可以根据你的具体需要来决定字体属性应该是用CGFontRef类型还是CTFontRef类型（Core Text字体）。同时字体大小也是用fontSize属性单独设置的，因为CTFontRef和CGFontRef并不像UIFont一样包含点大小。这个例子会告诉你如何将UIFont转换成CGFontRef。

	另外，CATextLayer的string属性并不是你想象的NSString类型，而是id类型。这样你既可以用NSString也可以用NSAttributedString来指定文本了（注意，NSAttributedString并不是NSString的子类）。属性化字符串是iOS用来渲染字体风格的机制，它以特定的方式来决定指定范围内的字符串的原始信息，比如字体，颜色，字重，斜体等

6.2.1 UILabel 的替代品

	我们真正想要的是一个用CATextLayer作为宿主图层的UILabel子类，这样就可以随着视图自动调整大小而且也没有冗余的寄宿图啦。

	就像我们在第一章『图层树』讨论的一样，每一个UIView都是寄宿在一个CALayer的示例上。这个图层是由视图自动创建和管理的，那我们可以用别的图层类型替代它么？一旦被创建，我们就无法代替这个图层了。但是如果我们继承了UIView，那我们就可以重写+layerClass方法使得在创建的时候能返回一个不同的图层子类。UIView会在初始化的时候调用+layerClass方法，然后用它的返回类型来创建宿主图层

	+ (Class)layerClass
	{
		return [CATextLayer class]; //backing layer
	}

6.3 3D变换层 CATransformLayer

	Core Animation图层很容易就可以让你在2D环境下做出这样的层级体系下的变换，但是3D情况下就不太可能，因为所有的图层都把他的孩子都平面化到一个场景中（第五章『变换』有提到）。

	CATransformLayer解决了这个问题，CATransformLayer不同于普通的CALayer，因为它不能显示它自己的内容。只有当存在了一个能作用域子图层的变换它才真正存在。CATransformLayer并不平面化它的子图层，所以它能够用于构造一个层级的3D结构，比如我的手臂示例


6.4 渐变层 CAGradientLayer	

	CAGradientLayer 是用来生成两种或更多颜色平滑渐变的。用Core Graphics 复制一个 CAGradientLayer 并将内容绘制到一个普通图层的寄宿图也是有可能的, 但是 CAGradientLayer 的真正好处在于绘制使用了硬件加速

	//set gradient colors
  	gradientLayer.colors = @[(__bridge id)[UIColor redColor].CGColor, (__bridge id)[UIColor blueColor].CGColor];

  	//set gradient start and end points
  	gradientLayer.startPoint = CGPointMake(0, 0);
  	gradientLayer.endPoint = CGPointMake(1, 1);

6.4.1 多重渐变

	如果你愿意，colors属性可以包含很多颜色，所以创建一个彩虹一样的多重渐变也是很简单的。默认情况下，这些颜色在空间上均匀地被渲染，但是我们可以用locations属性来调整空间。locations属性是一个浮点数值的数组（以NSNumber包装）。这些浮点数定义了colors属性中每个不同颜色的位置，同样的，也是以单位坐标系进行标定。0.0代表着渐变的开始，1.0代表着结束

	locations数组并不是强制要求的，但是如果你给它赋值了就一定要确保locations的数组大小和colors数组大小一定要相同，否则你将会得到一个空白的渐变。

	gradientLayer.locations = @[@0.0, @0.25, @0.5];

6.5 重复图层 CAReplicatorLayer

	反射效果

	@implementation ReflectionView
	+ (Class)layerClass
	{
	    return [CAReplicatorLayer class];
	}

	- (void)setUp
	{
	    //configure replicator
	    CAReplicatorLayer *layer = (CAReplicatorLayer *)self.layer;
	    layer.instanceCount = 2;

	    //move reflection instance below original and flip vertically
	    CATransform3D transform = CATransform3DIdentity;
	    CGFloat verticalOffset = self.bounds.size.height + 2;
	    transform = CATransform3DTranslate(transform, 0, verticalOffset, 0);
	    transform = CATransform3DScale(transform, 1, -1, 0);
	    layer.instanceTransform = transform;

	    //reduce alpha of reflection layer
	    layer.instanceAlphaOffset = -0.6;
	}
	￼
	- (id)initWithFrame:(CGRect)frame
	{
	    //this is called when view is created in code
	    if ((self = [super initWithFrame:frame])) {
	        [self setUp];
	    }
	    return self;
	}

	- (void)awakeFromNib
	{
	    //this is called when view is created from a nib
	    [self setUp];
	}
	@end

6.6 CAScrollLayer 滑动图层, 基本忽略

6.7 CATiledLayer 瓦片图层

	能高效绘制在iOS上的图片也有一个大小限制。所有显示在屏幕上的图片最终都会被转化为OpenGL纹理，同时OpenGL有一个最大的纹理尺寸（通常是2048*2048，或4096*4096，这个取决于设备型号）。如果你想在单个纹理中显示一个比这大的图，即便图片已经存在于内存中了，你仍然会遇到很大的性能问题，因为Core Animation强制用CPU处理图片而不是更快的GPU（见第12章『速度的曲调』，和第13章『高效绘图』，它更加详细地解释了软件绘制和硬件绘制）。

	CATiledLayer 为载入大图造成的性能问题提供了一个解决方案：将大图分解成小片然后将他们单独按需载入.

	裁剪成瓦片

	这个示例中，我们将会从一个2048*2048分辨率的雪人图片入手。这个程序将2048*2048分辨率的雪人图案裁剪成了64个不同的256*256的小图。

	CATiledLayer很好地和UIScrollView集成在一起。除了设置图层和滑动视图边界以适配整个图片大小，我们真正要做的就是实现-drawLayer:inContext:方法，当需要载入新的小图时，CATiledLayer就会调用到这个方法

	- (void)viewDidLoad
	{
	    [super viewDidLoad];
	    //add the tiled layer
	    CATiledLayer *tileLayer = [CATiledLayer layer];￼
	    tileLayer.frame = CGRectMake(0, 0, 2048, 2048);
	    tileLayer.contentsScale = [UIScreen mainScreen].scale;
	    tileLayer.delegate = self; [self.scrollView.layer addSublayer:tileLayer];

	    //configure the scroll view
	    self.scrollView.contentSize = tileLayer.frame.size;

	    //draw layer
	    [tileLayer setNeedsDisplay];
	}

	- (void)drawLayer:(CATiledLayer *)layer inContext:(CGContextRef)ctx
	{
	    //determine tile coordinate
	    CGRect bounds = CGContextGetClipBoundingBox(ctx);
	    NSInteger x = floor(bounds.origin.x / layer.tileSize.width);
	    NSInteger y = floor(bounds.origin.y / layer.tileSize.height);

	    //load tile image
	    NSString *imageName = [NSString stringWithFormat: @"Snowman_%02i_%02i", x, y];
	    NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@"jpg"];
	    UIImage *tileImage = [UIImage imageWithContentsOfFile:imagePath];

	    //draw tile
	    UIGraphicsPushContext(ctx);
	    [tileImage drawInRect:bounds];
	    UIGraphicsPopContext();
	}

	当你滑动这个图片，你会发现当CATiledLayer载入小图的时候，他们会淡入到界面中。这是CATiledLayer的默认行为。
	(你可能已经在iOS 6之前的苹果地图程序中见过这个效果) 你可以用fadeDuration属性改变淡入时长或直接禁用掉。
	
	CATiledLayer（不同于大部分的UIKit和Core Animation方法）支持多线程绘制，-drawLayer:inContext: 方法可以在多个线程中同时地并发调用，所以请小心谨慎地确保你在这个方法中实现的绘制代码是线程安全的。


6.8 CAEmitterLayer 粒子效果图层

	- (void)viewDidLoad
	{
	    [super viewDidLoad];
	    ￼
	    //create particle emitter layer
	    CAEmitterLayer *emitter = [CAEmitterLayer layer];
	    emitter.frame = self.containerView.bounds;
	    [self.containerView.layer addSublayer:emitter];

	    //configure emitter
	    emitter.renderMode = kCAEmitterLayerAdditive;
	    emitter.emitterPosition = CGPointMake(emitter.frame.size.width / 2.0, emitter.frame.size.height / 2.0);

	    //create a particle template
	    CAEmitterCell *cell = [[CAEmitterCell alloc] init];
	    cell.contents = (__bridge id)[UIImage imageNamed:@"Spark.png"].CGImage;
	    cell.birthRate = 150;
	    cell.lifetime = 5.0;
	    cell.color = [UIColor colorWithRed:1 green:0.5 blue:0.1 alpha:1.0].CGColor;
	    cell.alphaSpeed = -0.4;
	    cell.velocity = 50;
	    cell.velocityRange = 50;
	    cell.emissionRange = M_PI * 2.0;

	    //add particle template to emitter
	    emitter.emitterCells = @[cell];
	}


	CAEMitterCell的属性基本上可以分为三种：

	- 这种粒子的某一属性的初始值。比如，color属性指定了一个可以混合图片内容颜色的混合色。在示例中，我们将它设置为桔色。
	- 例子某一属性的变化范围。比如emissionRange属性的值是2π，这意味着例子可以从360度任意位置反射出来。如果指定一个小一些的值，就可以创造出一个圆锥形
	- 指定值在时间线上的变化。比如，在示例中，我们将alphaSpeed设置为-0.4，就是说例子的透明度每过一秒就是减少0.4，这样就有发射出去之后逐渐小时的效果。
	
	CAEmitterLayer的属性它自己控制着整个例子系统的位置和形状。一些属性比如birthRate，lifetime和celocity，这些属性在CAEmitterCell中也有。这些属性会以相乘的方式作用在一起，这样你就可以用一个值来加速或者扩大整个例子系统。其他值得提到的属性有以下这些：

	- preservesDepth，是否将3D例子系统平面化到一个图层（默认值）或者可以在3D空间中混合其他的图层
	- renderMode，控制着在视觉上粒子图片是如何混合的。你可能已经注意到了示例中我们把它设置为kCAEmitterLayerAdditive，它实现了这样一个效果：合并例子重叠部分的亮度使得看上去更亮。如果我们把它设置为默认的kCAEmitterLayerUnordered，效果就没那么好看了（见图6.14）.


6.9 CAEAGLLayer 

	当iOS要处理高性能图形绘制，必要时就是OpenGL。应该说它应该是最后的杀手锏，至少对于非游戏的应用来说是的。因为相比Core Animation和UIkit框架，它不可思议地复杂

	OpenGL提供了Core Animation的基础，它是底层的C接口，直接和iPhone，iPad的硬件通信，极少地抽象出来的方法。OpenGL没有对象或是图层的继承概念。它只是简单地处理三角形。OpenGL中所有东西都是3D空间中有颜色和纹理的三角形。用起来非常复杂和强大，但是用OpenGL绘制iOS用户界面就需要很多很多的工作了。

	在iOS 5中，苹果引入了一个新的框架叫做GLKit，它去掉了一些设置OpenGL的复杂性，提供了一个叫做CLKView的UIView的子类，帮你处理大部分的设置和绘制工作。前提是各种各样的OpenGL绘图缓冲的底层可配置项仍然需要你用CAEAGLLayer完成，它是CALayer的一个子类，用来显示任意的OpenGL图形。

	- (void)setUpBuffers
	{
	    //set up frame buffer
	    glGenFramebuffers(1, &_framebuffer);
	    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);

	    //set up color render buffer
	    glGenRenderbuffers(1, &_colorRenderbuffer);
	    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
	    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderbuffer);
	    [self.glContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.glLayer];
	    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_framebufferWidth);
	    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_framebufferHeight);

	    //check success
	    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
	        NSLog(@"Failed to make complete framebuffer object: %i", glCheckFramebufferStatus(GL_FRAMEBUFFER));
	    }
	}

	- (void)tearDownBuffers
	{
	    if (_framebuffer) {
	        //delete framebuffer
	        glDeleteFramebuffers(1, &_framebuffer);
	        _framebuffer = 0;
	    }

	    if (_colorRenderbuffer) {
	        //delete color render buffer
	        glDeleteRenderbuffers(1, &_colorRenderbuffer);
	        _colorRenderbuffer = 0;
	    }
	}

	- (void)drawFrame {
	    //bind framebuffer & set viewport
	    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
	    glViewport(0, 0, _framebufferWidth, _framebufferHeight);

	    //bind shader program
	    [self.effect prepareToDraw];

	    //clear the screen
	    glClear(GL_COLOR_BUFFER_BIT); glClearColor(0.0, 0.0, 0.0, 1.0);

	    //set up vertices
	    GLfloat vertices[] = {
	        -0.5f, -0.5f, -1.0f, 0.0f, 0.5f, -1.0f, 0.5f, -0.5f, -1.0f,
	    };

	    //set up colors
	    GLfloat colors[] = {
	        0.0f, 0.0f, 1.0f, 1.0f, 0.0f, 1.0f, 0.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f,
	    };

	    //draw triangle
	    glEnableVertexAttribArray(GLKVertexAttribPosition);
	    glEnableVertexAttribArray(GLKVertexAttribColor);
	    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, vertices);
	    glVertexAttribPointer(GLKVertexAttribColor,4, GL_FLOAT, GL_FALSE, 0, colors);
	    glDrawArrays(GL_TRIANGLES, 0, 3);

	    //present render buffer
	    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
	    [self.glContext presentRenderbuffer:GL_RENDERBUFFER];
	}

	- (void)viewDidLoad
	{
	    [super viewDidLoad];
	    //设置上下文
	    self.glContext = [[EAGLContext alloc] initWithAPI: kEAGLRenderingAPIOpenGLES2];
	    [EAGLContext setCurrentContext:self.glContext];

	    //设置EAGL图层
	    self.glLayer = [CAEAGLLayer layer];
	    self.glLayer.frame = self.glView.bounds;
	    [self.glView.layer addSublayer:self.glLayer];
	    self.glLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking:@NO, kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8};

	    //set up base effect
	    self.effect = [[GLKBaseEffect alloc] init];

	    //set up buffers
	    [self setUpBuffers];

	    //draw frame
	    [self drawFrame];
	}

	- (void)viewDidUnload
	{
	    [self tearDownBuffers];
	    [super viewDidUnload];
	}

	- (void)dealloc
	{
	    [self tearDownBuffers];
	    [EAGLContext setCurrentContext:nil];
	}


	在一个真正的OpenGL应用中，我们可能会用NSTimer或CADisplayLink周期性地每秒钟调用-drawRrame方法60次，同时会将几何图形生成和绘制分开以便不会每次都重新生成三角形的顶点（这样也可以让我们绘制其他的一些东西而不是一个三角形而已），不过上面这个例子已经足够演示了绘图原则了

6.10    AVPlayerLayer 视频播放图层

	最后一个图层类型是AVPlayerLayer。尽管它不是Core Animation框架的一部分（AV前缀看上去像），AVPlayerLayer是有别的框架（AVFoundation）提供的，它和Core Animation紧密地结合在一起，提供了一个CALayer子类来显示自定义的内容类型

	AVPlayerLayer是用来在iOS上播放视频的。他是高级接口例如MPMoivePlayer的底层实现，提供了显示视频的底层控制。AVPlayerLayer的使用相当简单：你可以用+playerLayerWithPlayer:方法创建一个已经绑定了视频播放器的图层，或者你可以先创建一个图层，然后用player属性绑定一个AVPlayer实例。

		//获取媒体资源
		NSURL *URL = [[NSBundle mainBundle] URLForResource:@"Ship" withExtension:@"mp4"];

		//创建播放器和播放图层
		AVPlayer *player = [AVPlayer playerWithURL:URL];
		AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];

		//设置播放图层的大小
		playerLayer.frame = self.containerView.bounds;
		[self.containerView.layer addSublayer:playerLayer];

		//进行一些变换
		CATransform3D transform = CATransform3DIdentity;
		transform.m34 = -1.0 / 500.0;
		transform = CATransform3DRotate(transform, M_PI_4, 1, 1, 0);
		playerLayer.transform = transform;
		￼
		//添加圆角和边框
		playerLayer.masksToBounds = YES;
		playerLayer.cornerRadius = 20.0;
		playerLayer.borderColor = [UIColor redColor].CGColor;
		playerLayer.borderWidth = 5.0;

		//播放视频
		[player play];

	当然，因为AVPlayerLayer是CALayer的子类，它继承了父类的所有特性。我们并不会受限于要在一个矩形中播放视频；清单6.16演示了在3D，圆角，有色边框，蒙板，阴影等效果


7.3     图层行为

	试着直接对UIView关联的图层做动画而不是一个单独的图层,图层颜色瞬间切换到新的值，而不是之前平滑过渡的动画。发生了什么呢？隐式动画好像被UIView关联图层给禁用了.

	试想一下，如果UIView的属性都有动画特性的话，那么无论在什么时候修改它，我们都应该能注意到的。所以，如果说UIKit建立在Core Animation（默认对所有东西都做动画）之上，那么隐式动画是如何被UIKit禁用掉呢？

	我们知道 Core Animation 通常对 CALayer 的所有属性（可动画的属性）做动画，但是 UIView 把它关联的图层的这个特性关闭了.为了更好说明这一点, 我们需要知道隐式动画是如何实现的。

	我们把改变属性时CALayer自动应用的动画称作行为，当CALayer的属性被修改时候，它会调用-actionForKey: 方法，传递属性的名称.剩下的操作都在 CALayer 的头文件中有详细的说明,实质上是如下几步：

		a. 图层首先检测它是否有委托，并且是否实现CALayerDelegate协议指定的-actionForLayer:forKey方法。如果有，直接调用并返回结果。
		b. 如果没有委托，或者委托没有实现-actionForLayer:forKey方法，图层接着检查包含属性名称对应行为映射的actions字典。
		c. 如果actions字典没有包含对应的属性，那么图层接着在它的style字典接着搜索属性名。
		d. 最后，如果在style里面也找不到对应的行为，那么图层将会直接调用定义了每个属性的标准行为的-defaultActionForKey:方法。

	于是这就解释了UIKit是如何禁用隐式动画的：每个UIView对它关联的图层都扮演了一个委托，并且提供了-actionForLayer:forKey 的实现方法
	当不在一个动画块的实现中，UIView对所有图层行为返回nil，但是在动画block范围之内，它就返回了一个非空值。

	我们可以用一个demo做个简单的实验

		- (void)viewDidLoad
		{
		    [super viewDidLoad];
		    
		    NSLog(@"Outside: %@", [self.layerView actionForLayer:self.layerView.layer forKey:@"backgroundColor"]);

		    [UIView beginAnimations:nil context:nil];
		    NSLog(@"Inside: %@", [self.layerView actionForLayer:self.layerView.layer forKey:@"backgroundColor"]);
		    [UIView commitAnimations];
		}

		$ LayerTest[21215:c07] Outside: <null>
		$ LayerTest[21215:c07] Inside: <CABasicAnimation: 0x757f090>

	于是我们可以预言，当属性在动画块之外发生改变，UIView直接通过返回nil来禁用隐式动画。
	但如果在动画块范围之内，根据动画具体类型返回相应的属性，在这个例子就是CABasicAnimation（第八章“显式动画”将会提到）。

	当然返回nil并不是禁用隐式动画唯一的办法，CATransacition有个方法叫做+setDisableActions:，可以用来对所有属性打开或者关闭隐式动画。
	如果在清单7.2的[CATransaction begin]之后添加下面的代码，同样也会阻止动画的发生：

		[CATransaction setDisableActions:YES];

	总结一下，我们知道了如下几点

	a. UIView关联的图层禁用了隐式动画，对这种图层做动画的唯一办法就是使用UIView的动画函数（而不是依赖CATransaction)
	b. 或者继承UIView，并覆盖-actionForLayer:forKey:方法，或者直接创建一个显式动画（具体细节见第八章）。
	
	对于单独存在的图层，我们可以通过实现图层的-actionForLayer:forKey:委托方法，或者提供一个actions字典来控制隐式动画。

		//add a custom action
		CATransition *transition = [CATransition animation];
		transition.type = kCATransitionPush;
		transition.subtype = kCATransitionFromLeft;
		self.colorLayer.actions = @{@"backgroundColor": transition};

	
7.4 	呈现与模型 presentationLayer, modelLayer

	在iOS中，屏幕每秒钟重绘60次。如果动画时长比60分之一秒要长，Core Animation就需要在设置一次新值和新值生效之间，对屏幕上的图层进行重新组织。这意味着CALayer除了“真实”值（就是你设置的值）之外，必须要知道当前显示在屏幕上的属性值的记录。

	每个图层属性的显示值都被存储在一个叫做呈现图层的独立图层当中，他可以通过-presentationLayer方法来访问。这个呈现图层实际上是模型图层的复制，但是它的属性值代表了在任何指定时刻当前外观效果。换句话说，你可以通过呈现图层的值来获取当前屏幕上真正显示出来的值

	你可能注意到有一个叫做–modelLayer的方法。在呈现图层上调用–modelLayer将会返回它正在呈现所依赖的CALayer。通常在一个图层上调用-modelLayer会返回–self（实际上我们已经创建的原始图层就是一种数据模型)

	大多数情况下，你不需要直接访问呈现图层，你可以通过和模型图层的交互，来让Core Animation 更新显示。 
	两种情况下呈现图层会变得很有用，一个是同步动画，一个是处理用户交互。

	a. 如果你在实现一个基于定时器的动画（见第11章“基于定时器的动画”），而不仅仅是基于事务的动画，这个时候准确地知道在某一时刻图层显示在什么位置就会对正确摆放图层很有用了。
	b. 如果你想让你做动画的图层响应用户输入，你可以使用-hitTest:方法（见第三章“图层几何学”）来判断指定图层是否被触摸，这时候对呈现图层而不是模型图层调用-hitTest:会显得更有意义，因为呈现图层代表了用户当前看到的图层位置，而不是当前动画结束之后的位置。
	我们可以用一个简单的案例来证明后者（见清单7.7）。

	在这个例子中，点击屏幕上的任意位置将会让图层平移到那里。点击图层本身可以随机改变它的颜色。我们通过对呈现图层调用-hitTest:来判断是否被点击。
	如果修改代码让-hitTest:直接作用于colorLayer而不是呈现图层，你会发现当图层移动的时候它并不能正确显示。
	这时候你就需要点击图层将要移动到的位置而不是图层本身来响应点击（这就是为什么用呈现图层来响应交互的原因


		- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
		{
		    //get the touch point
		    CGPoint point = [[touches anyObject] locationInView:self.view];
		    //check if we've tapped the moving layer
		    if ([self.colorLayer.presentationLayer hitTest:point]) {  //动画变换过程中任一时刻的层
		        //randomize the layer background color
		        CGFloat red = arc4random() / (CGFloat)INT_MAX;
		        CGFloat green = arc4random() / (CGFloat)INT_MAX;
		        CGFloat blue = arc4random() / (CGFloat)INT_MAX;
		        self.colorLayer.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0].CGColor;
		    } else {
		        //otherwise (slowly) move the layer to new position
		        [CATransaction begin];
		        [CATransaction setAnimationDuration:4.0];
		        self.colorLayer.position = point;
		        [CATransaction commit];
		    }
		}


8.1 属性动画
	
	当使用-addAnimation:forKey:把动画添加到图层，这里有一个到目前为止我们都设置为nil的key参数。这里的键是-animationForKey:方法找到对应动画的唯一标识符，而当前动画的所有键都可以用animationKeys获取。如果我们对每个动画都关联一个唯一的键，就可以对每个图层循环所有键，然后调用-animationForKey:来比对结果。尽管这不是一个优雅的实现。

	幸运的是，还有一种更加简单的方法。像所有的NSObject子类一样，CAAnimation实现了KVC（键-值-编码）协议，于是你可以用-setValue:forKey:和-valueForKey:方法来存取属性。但是CAAnimation有一个不同的性能：它更像一个NSDictionary，可以让你随意设置键值对，即使和你使用的动画类所声明的属性并不匹配

		[animation setValue:handView forKey:@"handView"];

		- (void)animationDidStop:(CABasicAnimation *)anim finished:(BOOL)flag
		{
		    //set final position for hand view
		    UIView *handView = [anim valueForKey:@"handView"];
		    handView.layer.transform = [anim.toValue CATransform3DValue];
		}


	不幸的是，即使做了这些，还是有个问题，清单8.4在模拟器上运行的很好，但当真正跑在iOS设备上时，我们发现在-animationDidStop:finished:委托方法调用之前，指针会迅速返回到原始值，这个清单8.3图层颜色发生的情况一样。

	问题在于回调方法在动画完成之前已经被调用了，但不能保证这发生在属性动画返回初始状态之前。这同时也很好地说明了为什么要在真实的设备上测试动画代码，而不仅仅是模拟器。

	我们可以用一个fillMode属性来解决这个问题，下一章会详细说明，这里知道在动画之前设置它比在动画结束之后更新属性更加方便

8.1.2	关键帧动画

	关键帧起源于传动动画，意思是指主导的动画在显著改变发生时重绘当前帧（也就是关键帧），每帧之间剩下的绘制（可以通过关键帧推算出）将由熟练的艺术家来完成。CAKeyframeAnimation也是同样的道理：你提供了显著的帧，然后Core Animation在每帧之间进行插入

		UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
	    	[bezierPath moveToPoint:CGPointMake(0, 150)];
	    	[bezierPath addCurveToPoint:CGPointMake(300, 150) controlPoint1:CGPointMake(75, 0) controlPoint2:CGPointMake(225, 300)];

		CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
	    	animation.keyPath = @"position";
	    	animation.duration = 4.0;
	    	animation.path = bezierPath.CGPath;
	    	[shipLayer addAnimation:animation forKey:nil];

	运行示例，你会发现飞船的动画有些不太真实，这是因为当它运动的时候永远指向右边，而不是指向曲线切线的方向。你可以调整它的affineTransform来对运动方向做动画，但很可能和其它的动画冲突。

	幸运的是，苹果预见到了这点，并且给CAKeyFrameAnimation添加了一个rotationMode的属性。设置它为常量kCAAnimationRotateAuto（清单8.7），图层将会根据曲线的切线自动旋转（图8.2）

8.1.3 	虚拟属性

		CABasicAnimation *animation = [CABasicAnimation animation];
	    	animation.keyPath = @"transform.rotation";
	    	animation.duration = 2.0;
	    	animation.byValue = @(M_PI * 2);
	    	[shipLayer addAnimation:animation forKey:nil];

    	结果运行的特别好，用transform.rotation而不是transform做动画的好处如下：

		a. 我们可以不通过关键帧一步旋转多于180度的动画。
		b. 可以用相对值而不是绝对值旋转（设置byValue而不是toValue）。
		c. 可以不用创建CATransform3D，而是使用一个简单的数值来指定角度。
		d. 不会和transform.position或者transform.scale冲突（同样是使用关键路径来做独立的动画属性）。
	
	transform.rotation属性有一个奇怪的问题是它其实并不存在。
	这是因为CATransform3D并不是一个对象，它实际上是一个结构体，也没有符合KVC相关属性，transform.rotation实际上是一个CALayer用于处理动画变换的虚拟属性

8.2 	动画组
	
	CABasicAnimation和CAKeyframeAnimation仅仅作用于单独的属性，而CAAnimationGroup可以把这些动画组合在一起。CAAnimationGroup是另一个继承于CAAnimation的子类，它添加了一个animations数组的属性，用来组合别的动画。我们把清单8.6那种关键帧动画和调整图层背景色的基础动画组合起来

		CAKeyframeAnimation *animation1 = [CAKeyframeAnimation animation];
		animation1.keyPath = @"position";
		animation1.path = bezierPath.CGPath;
		animation1.rotationMode = kCAAnimationRotateAuto;
		
		CABasicAnimation *animation2 = [CABasicAnimation animation];
		animation2.keyPath = @"backgroundColor";
		animation2.toValue = (__bridge id)[UIColor redColor].CGColor;
		
		CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
		groupAnimation.animations = @[animation1, animation2]; 
		groupAnimation.duration = 4.0;
		
		[colorLayer addAnimation:groupAnimation forKey:nil];

8.3 	过度

	有时候对于iOS应用程序来说，希望能通过属性动画来对比较难做动画的布局进行一些改变。比如交换一段文本和图片，或者用一段网格视图来替换，等等。属性动画只对图层的可动画属性起作用，所以如果要改变一个不能动画的属性（比如图片），或者从层级关系中添加或者移除图层，属性动画将不起作用。

	于是就有了过渡的概念.

		CATransition *transition = [CATransition animation];
		transition.type = kCATransitionFade;
		transition.subtype = kCATransitionFromLeft;
		[self.imageView.layer addAnimation:transition forKey:nil];


8.3.1   隐式过度

	CATransision可以对图层任何变化平滑过渡的事实使得它成为那些不好做动画的属性图层行为的理想候选。苹果当然意识到了这点，并且当设置了CALayer的content属性的时候，CATransition的确是默认的行为。但是对于视图关联的图层，或者是其他隐式动画的行为，这个特性依然是被禁用的，但是对于你自己创建的图层，这意味着对图层contents图片做的改动都会自动附上淡入淡出的动画

8.3.2   对图层树的动画

	CATransition并不作用于指定的图层属性，这就是说你可以在即使不能准确得知改变了什么的情况下对图层做动画，例如，在不知道UITableView哪一行被添加或者删除的情况下，直接就可以平滑地刷新它，或者在不知道UIViewController内部的视图层级的情况下对两个不同的实例做过渡动画

	这里用到了一个小诡计，要确保CATransition添加到的图层在过渡动画发生时不会在树状结构中被移除，否则CATransition将会和图层一起被移除。一般来说，你只需要将动画添加到被影响图层的superlayer.

		- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
		{
		    ￼//set up crossfade transition
		    CATransition *transition = [CATransition animation];
		    transition.type = kCATransitionFade;
		    //apply transition to tab bar controller's view
		    [self.tabBarController.view.layer addAnimation:transition forKey:nil];
		}

9.1.1 	持续和重复

	我们用了autoreverses来使门在打开后自动关闭，在这里我们把repeatDuration设置为INFINITY，于是动画无限循环播放，设置repeatCount为INFINITY也有同样的效果。注意repeatCount和repeatDuration可能会相互冲突，所以你只要对其中一个指定非零值。对两个属性都设置非0值的行为没有被定义

		CATransform3D perspective = CATransform3DIdentity;
		perspective.m34 = -1.0 / 500.0;
		self.containerView.layer.sublayerTransform = perspective;

		CABasicAnimation *animation = [CABasicAnimation animation];
		animation.keyPath = @"transform.rotation.y";
		animation.toValue = @(-M_PI_2);
		animation.duration = 2.0;
		animation.repeatDuration = INFINITY;
		animation.autoreverses = YES;

		[doorLayer addAnimation:animation forKey:nil];

9.3 	手动动画

	通过设置对应layer的 timeOffset (0,1), speed = 0 属性, 可以实现手动控制动画

		//透视效果只能对父容器实施
		CATransform3D perspective = CATransform3DIdentity;
	    	perspective.m34 = -1.0 / 500.0;
	    	self.containerView.layer.sublayerTransform = perspective;

	    	self.doorLayer.speed = 0.0;  //停止层上的所有动画

		CABasicAnimation *animation = [CABasicAnimation animation];
		animation.keyPath = @"transform.rotation.y";
		animation.toValue = @(-M_PI_2);
		animation.duration = 1.0;
		[self.doorLayer addAnimation:animation forKey:nil];


		- (void)pan:(UIPanGestureRecognizer *)pan
		{
		    CGFloat x = [pan translationInView:self.view].x;
		    x /= 200.0f; //using a reasonable scale factor
		    
		    CFTimeInterval timeOffset = self.doorLayer.timeOffset;
		    timeOffset = MIN(0.999, MAX(0.0, timeOffset - x));
		    self.doorLayer.timeOffset = timeOffset;
		    
		    //reset pan gesture
		    //初始化sender中的坐标位置。如果不初始化，移动坐标会一直积累起来。
		    [pan setTranslation:CGPointZero inView:self.view];
		    
		}


	这其实是个小诡计，也许相对于设置个动画然后每次显示一帧而言，用移动手势来直接设置门的transform会更简单。
	在这个例子中的确是这样，但是对于比如说关键这这样更加复杂的情况，或者有多个图层的动画组，相对于实时计算每个图层的属性而言，这就显得方便的多了

10.1    动画速度

	CAMediaTimingFunction

	这里有一些方式来创建CAMediaTimingFunction，最简单的方式是调用+timingFunctionWithName:的构造方法。这里传入如下几个常量之一：

		kCAMediaTimingFunctionLinear 
		kCAMediaTimingFunctionEaseIn 
		kCAMediaTimingFunctionEaseOut 
		kCAMediaTimingFunctionEaseInEaseOut
		kCAMediaTimingFunctionDefault

		[CATransaction begin];
		[CATransaction setAnimationDuration:1.0];
		[CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
		self.colorLayer.position = [[touches anyObject] locationInView:self.view];
		[CATransaction commit];

	UIView的动画缓冲

		[UIView animateWithDuration:1.0 delay:0.0
	                        options:UIViewAnimationOptionCurveEaseOut
	                     animations:^{
	                            //set the position
	                            self.colorView.center = [[touches anyObject] locationInView:self.view];
	                        }
	                     completion:NULL];


	缓冲和关键帧动画

	CAKeyframeAnimation有一个NSArray类型的timingFunctions属性，我们可以用它来对每次动画的步骤指定不同的计时函数。但是指定函数的个数一定要等于keyframes数组的元素个数减一，因为它是描述每一帧之间动画速度的函数

		CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
		animation.keyPath = @"backgroundColor";
		animation.duration = 2.0;
		animation.values = @[
		                 (__bridge id)[UIColor blueColor].CGColor,
		                 (__bridge id)[UIColor redColor].CGColor,
		                 (__bridge id)[UIColor greenColor].CGColor,
		                 (__bridge id)[UIColor blueColor].CGColor ];
		//add timing function
		CAMediaTimingFunction *fn = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseIn];
		animation.timingFunctions = @[fn, fn, fn];
		//apply animation to layer
		[self.colorLayer addAnimation:animation forKey:nil];


10.2    自定义缓冲函数

		CABasicAnimation *animation = [CABasicAnimation animation];
	        animation.keyPath = @"transform";
	        animation.fromValue = [handView.layer.presentationLayer valueForKey:@"transform"];
	        animation.toValue = [NSValue valueWithCATransform3D:transform];
	        animation.duration = 0.5;
	        animation.delegate = self;
	        animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:1 :0 :0.75 :1];
	        [handView.layer addAnimation:animation forKey:nil];

	        CATransform3D transform = CATransform3DMakeRotation(angle, 0, 0, 1);
	        handView.layer.transform = transform;



11.1    基于定时器的动画

	我们之前提到过iOS按照每秒60次刷新屏幕，然后CAAnimation计算出需要展示的新的帧，然后在每次屏幕更新的时候同步绘制上去，CAAnimation最机智的地方在于每次刷新需要展示的时候去计算插值和缓冲

	NSTimer

	很赞，而且和基于关键帧例子的代码一样很多，但是如果想一次性在屏幕上对很多东西做动画，很明显就会有很多问题

	NSTimer并不是最佳方案，为了理解这点，我们需要确切地知道NSTimer是如何工作的。iOS上的每个线程都管理了一个NSRunloop，字面上看就是通过一个循环来完成一些任务列表。但是对主线程，这些任务包含如下几项：

		a. 处理触摸事件
		b. 发送和接受网络数据包
		c. 执行使用gcd的代码
		d. 处理计时器行为
		e. 屏幕重绘

	当你设置一个NSTimer，他会被插入到当前任务列表中，然后直到指定时间过去之后才会被执行。但是何时启动定时器并没有一个时间上限，而且它只会在列表中上一个任务完成之后开始执行。这通常会导致有几毫秒的延迟，但是如果上一个任务过了很久才完成就会导致延迟很长一段时间。

	屏幕重绘的频率是一秒钟六十次，但是和定时器行为一样，如果列表中上一个执行了很长时间，它也会延迟。这些延迟都是一个随机值，于是就不能保证定时器精准地一秒钟执行六十次。有时候发生在屏幕重绘之后，这就会使得更新屏幕会有个延迟，看起来就是动画卡壳了。有时候定时器会在屏幕更新的时候执行两次，于是动画看起来就跳动了

	我们可以通过一些途径来优化：

		a. 我们可以用CADisplayLink让更新频率严格控制在每次屏幕刷新之后。
		b. 基于真实帧的持续时间而不是假设的更新频率来做动画。
		c. 调整动画计时器的run loop模式，这样就不会被别的事件干扰。

	CADisplayLink

	CADisplayLink是CoreAnimation提供的另一个类似于NSTimer的类，它总是在屏幕完成一次更新之前启动，它的接口设计的和NSTimer很类似，所以它实际上就是一个内置实现的替代，但是和timeInterval以秒为单位不同，CADisplayLink有一个整型的frameInterval属性，指定了间隔多少帧之后才执行。默认值是1，意味着每次屏幕更新之前都会执行一次。但是如果动画的代码执行起来超过了六十分之一秒，你可以指定frameInterval为2，就是说动画每隔一帧执行一次（一秒钟30帧）或者3，也就是一秒钟20次，等等。

	用CADisplayLink而不是NSTimer，会保证帧率足够连续，使得动画看起来更加平滑，但即使CADisplayLink也不能保证每一帧都按计划执行，一些失去控制的离散的任务或者事件（例如资源紧张的后台程序）可能会导致动画偶尔地丢帧。当使用NSTimer的时候，一旦有机会计时器就会开启，但是CADisplayLink却不一样：如果它丢失了帧，就会直接忽略它们，然后在下一次更新的时候接着运行

	计算帧的持续时间

	无论是使用NSTimer还是CADisplayLink，我们仍然需要处理一帧的时间超出了预期的六十分之一秒。由于我们不能够计算出一帧真实的持续时间，所以需要手动测量。我们可以在每帧开始刷新的时候用CACurrentMediaTime()记录当前时间，然后和上一帧记录的时间去比较


		self.lastStep = CACurrentMediaTime();

		CFTimeInterval thisStep = CACurrentMediaTime();
		CFTimeInterval stepDuration = thisStep - self.lastStep;
		self.lastStep = thisStep;
		self.timeOffset = MIN(self.timeOffset + stepDuration, self.duration);

	Run Loop 模式

		注意到当创建CADisplayLink的时候，我们需要指定一个run loop和run loop mode，对于run loop来说，我们就使用了主线程的run loop，因为任何用户界面的更新都需要在主线程执行，但是模式的选择就并不那么清楚了，每个添加到run loop的任务都有一个指定了优先级的模式，为了保证用户界面保持平滑，iOS会提供和用户界面相关任务的优先级，而且当UI很活跃的时候的确会暂停一些别的任务。

	一个典型的例子就是当是用UIScrollview滑动的时候，重绘滚动视图的内容会比别的任务优先级更高，所以标准的NSTimer和网络请求就不会启动，一些常见的run loop模式如下：

		a. NSDefaultRunLoopMode - 标准优先级
		b. NSRunLoopCommonModes - 高优先级
		c. UITrackingRunLoopMode - 用于UIScrollView和别的控件的动画


	在我们的例子中，我们是用了NSDefaultRunLoopMode，但是不能保证动画平滑的运行，所以就可以用NSRunLoopCommonModes来替代。但是要小心，因为如果动画在一个高帧率情况下运行，你会发现一些别的类似于定时器的任务或者类似于滑动的其他iOS动画会暂停，直到动画结束。

	同样可以同时对CADisplayLink指定多个run loop模式, 于是我们可以同时加入 NSDefaultRunLoopMode 和 UITrackingRunLoopMode 来保证它不会被滑动打断, 也不会被其他UIKit控件动画影响性能, 像这样：

		self.timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(step:)];
		[self.timer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
		[self.timer addToRunLoop:[NSRunLoop mainRunLoop] forMode:UITrackingRunLoopMode];

	和CADisplayLink类似，NSTimer同样也可以使用不同的run loop模式配置，通过别的函数，而不是+scheduledTimerWithTimeInterval:构造器

		self.timer = [NSTimer timerWithTimeInterval:1/60.0
		                                 target:self
		                               selector:@selector(step:)
		                               userInfo:nil
		                                repeats:YES];
		[[NSRunLoop mainRunLoop] addTimer:self.timer
		                          forMode:NSRunLoopCommonModes];




[jekyll]:      http://jekyllrb.com
[jekyll-gh]:   https://github.com/jekyll/jekyll
[jekyll-help]: https://github.com/jekyll/jekyll-help
