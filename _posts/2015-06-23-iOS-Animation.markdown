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







[jekyll]:      http://jekyllrb.com
[jekyll-gh]:   https://github.com/jekyll/jekyll
[jekyll-help]: https://github.com/jekyll/jekyll-help
