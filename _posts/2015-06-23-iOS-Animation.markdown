---
layout: post
title:  "iOS Animation"
date:   2015-06-06 12:42:26
categories: jekyll update
---

#### 1. UITabBarController - tab切换使用动画

    Solution 1: transition from view (simple)
    This is the easiest and makes use of a predefined UIView transition method. With this solution we don't need to manage the views because the method does the work for us.

	// Get views. controllerIndex is passed in as the controller we want to go to. 
	UIView * fromView = tabBarController.selectedViewController.view;
	UIView * toView = [[tabBarController.viewControllers objectAtIndex:controllerIndex] view];

	// Transition using a page curl.
	[UIView transitionFromView:fromView 
                    toView:toView 
                  duration:0.5 
                   options:(controllerIndex > tabBarController.selectedIndex ? UIViewAnimationOptionTransitionCurlUp : UIViewAnimationOptionTransitionCurlDown)
                completion:^(BOOL finished) {
                    if (finished) {
                        tabBarController.selectedIndex = controllerIndex;
                    }
                }];



    Solution 2: scroll (more complex)
    A more complex solution, but gives you more control of the animation. In this example we get the views to slide on and off. With this one we need to manage the views  ourselves.

	// Get the views.
	UIView * fromView = tabBarController.selectedViewController.view;
	UIView * toView = [[tabBarController.viewControllers objectAtIndex:controllerIndex] view];

	// Get the size of the view area.
	CGRect viewSize = fromView.frame;
	BOOL scrollRight = controllerIndex > tabBarController.selectedIndex;

	// Add the to view to the tab bar view.
	[fromView.superview addSubview:toView];

	// Position it off screen.
	toView.frame = CGRectMake((scrollRight ? 320 : -320), viewSize.origin.y, 320, viewSize.size.height);

	[UIView animateWithDuration:0.3 
                 animations: ^{

                     // Animate the views on and off the screen. This will appear to slide.
                     fromView.frame =CGRectMake((scrollRight ? -320 : 320), viewSize.origin.y, 320, viewSize.size.height);
                     toView.frame =CGRectMake(0, viewSize.origin.y, 320, viewSize.size.height);
                 }

                 completion:^(BOOL finished) {
                     if (finished) {

                         // Remove the old view from the tabbar view.
                         [fromView removeFromSuperview];
                         tabBarController.selectedIndex = controllerIndex;                
                     }
                 }];


#### 2. Animation 的锚点变换

    //动画的变换都是相对于中心点进行的, 这个中心点就是锚点, 然而某些情况下我们需要改变这个默认的中心点(0.5, 0.5) 
    -(void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view
    {
        CGPoint newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x,
                                       view.bounds.size.height * anchorPoint.y);
        CGPoint oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x,
                                       view.bounds.size.height * view.layer.anchorPoint.y);
        
        newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
        oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);
        
        CGPoint position = view.layer.position;
        
        position.x -= oldPoint.x;
        position.x += newPoint.x;
        
        position.y -= oldPoint.y;
        position.y += newPoint.y;
        
        view.layer.position = position;
        view.layer.anchorPoint = anchorPoint;
    }


#### 3. pop Animation 倒计时
    
    POPBasicAnimation *anim = [POPBasicAnimation animation];
    anim.duration = 10.0;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    POPAnimatableProperty * prop = [POPAnimatableProperty propertyWithName:@"count" initializer:^(POPMutableAnimatableProperty *prop) {
        // read value
        prop.readBlock = ^(id obj, CGFloat values[]) {
            values[0] = [[obj description] floatValue];
        };
        // write value
        prop.writeBlock = ^(id obj, const CGFloat values[]) {
            [obj setText:[NSString stringWithFormat:@"%.2f",values[0]]];
        };
        // dynamics threshold
        prop.threshold = 0.01;
    }];
    
    anim.property = prop;
    
    anim.fromValue = @(0.0);
    anim.toValue = @(100.0);
    
    [self.countingLabel pop_addAnimation:anim forKey:@"counting"];


#### 4. pop animation Shake 震动

    POPSpringAnimation *positionAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
    positionAnimation.velocity = @2000;
    positionAnimation.springBounciness = 20;
    [positionAnimation setCompletionBlock:^(POPAnimation *animation, BOOL finished) {
        self.button.userInteractionEnabled = YES;
    }];
    [self.button.layer pop_addAnimation:positionAnimation forKey:@"positionAnimation"];


#### 5. pop animation FlatButton 弹性按钮
    
    [self addTarget:self action:@selector(scaleToSmall) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
    [self addTarget:self action:@selector(scaleAnimation) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(scaleToDefault) forControlEvents:UIControlEventTouchDragExit];

    - (void)scaleToSmall
    {
        POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(0.95f, 0.95f)];
        [self.layer pop_addAnimation:scaleAnimation forKey:@"layerScaleSmallAnimation"];
        [self.layer pop_addAnimation:scaleAnimation forKey:kPOPLayerBounds];
    }

    - (void)scaleAnimation
    {
        POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        scaleAnimation.velocity = [NSValue valueWithCGSize:CGSizeMake(3.f, 3.f)];
        scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.f, 1.f)];
        scaleAnimation.springBounciness = 18.0f;
        [self.layer pop_addAnimation:scaleAnimation forKey:@"layerScaleSpringAnimation"];
    }

    - (void)scaleToDefault
    {
        POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.f, 1.f)];
        [self.layer pop_addAnimation:scaleAnimation forKey:@"layerScaleDefaultAnimation"];
    }


#### 6. CADisplayLink

    CADisplayLink 是一种以屏幕刷新频率触发的时钟机制, 每秒执行大约 60 次左右
    这种计时器, 可以使绘图代码与视图的刷新频率保持同步, 而 NSTimer 无法确保计时器实际被触发的准确时间

    CADisplayLink  *_displayLink; // 游戏时钟
    steps = 0; // 初始化屏幕刷新总次数
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(step)]; // 初始化时钟
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode]; // 初始化时钟之后，有一个必须要做的，就是把游戏时钟，添加到主运行循环

    //[NSTimer scheduledTimerWithTimeInterval:1./60 target:self selector:@selector(step) userInfo:nil repeats:YES]; //效果同上,唯一的不同就是当系统比较繁忙时, 会卡

    #pragma mark - 使用指定时间处理CADisplayLink触发时间的方法（1）
    - (void)updateTimer:(CADisplayLink *)sender{
        // 如果_startTime=0，说明是第一次触发时钟，需要记录时钟的时钟戳记
        if (_startTime == 0) {
            _startTime = sender.timestamp;
        }
        // 时钟触发的时间差值
        CFTimeInterval deltaTime = sender.timestamp - _startTime;
        if (deltaTime > 1.0) {
            NSLog(@"时钟触发了 %f", sender.timestamp);
            // 更新_startTime的数值，记录本次执行任务的时间
            _startTime = sender.timestamp;
        }
    }

    #pragma mark - 使用指定时间处理CADisplayLink触发时间的方法（2）
    // 全局静态变量，记录程序运行开始，屏幕刷新的总次数
    static long steps;
    /**
     使用一个“全局”的长整形记录屏幕刷新的次数，然后，用模的方式判断时间
     在Box2D的物理引擎中，时钟触发的方法也叫做step。
     */
    - (void)step{
        // 假定每隔一秒触发一次方法
        if (steps % 60 == 1) {
            NSLog(@"时钟触发了！ %ld", steps);
        }
        steps++;
    }

#### 7. CALayer

    a.  UIView, CALayer 之间的调用关系

        UIView 收到 setNeedsDisplay 消息, CALayer 会准备好一个 CGContextRef, 然后调用代理,即UIView的 drawLayer:inContext: 方法, 传入准备好的 CGContextRef 对象.
        drawLayer:inContext: 方法中会调用 drawRect: 方法
        drawRect:中通过 UIGraphicsGetCurrentContext() 获取的就是 CALayer 传入的 CGContextRef 对象, 在drawRect:中完成的所有绘制都入填入CALayer的CGContextRef中, 然后被拷贝值屏幕
        CALayer 的 CGContextRef 用的是位图上下文 (Bitmap Graphics Context)

        - (void)viewDidLoad{
            [super viewDidLoad];

            _layer = [CALayer layer];
            [_layer setBounds:CGRectMake(0, 0, 200, 200)];
            [_layer setPosition:CGPointMake(100, 100)];
            [_layer setBackgroundColor:[UIColor redColor].CGColor];
            // 不能再将UIView设置为这个CALayer的delegate，因为UIView对象已经是内部层的delegate，再次设置会出问题
        //    [_layer setDelegate:self.view];
            [_layer setDelegate:self]; // 因为ViewController 是 CALayer 的代理, 所以需要实现 drawLayer: inContext: 方法
            [_layer setNeedsDisplay]; // 这样才会调用 drawLayer: inContext: 方法
            [self.view.layer addSublayer:_layer];
        }

        - (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{
            CGContextSetRGBFillColor(ctx, 1, 1, 0, 1);
            CGContextFillEllipseInRect(ctx, CGRectMake(0, 0, 200, 200));
        }

[jekyll]:      http://jekyllrb.com
[jekyll-gh]:   https://github.com/jekyll/jekyll
[jekyll-help]: https://github.com/jekyll/jekyll-help
