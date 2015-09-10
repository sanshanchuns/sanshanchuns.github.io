---
layout: post
title:  Core_Animation
date:   2015-09-08-12:34:55
categories: jekyll update
---

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

6.1 CAShaperLayer

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

6.2 CATextLayer

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

[jekyll]:      http://jekyllrb.com
[jekyll-gh]:   https://github.com/jekyll/jekyll
[jekyll-help]: https://github.com/jekyll/jekyll-help
