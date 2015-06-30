---
layout: post
title:  "iOS Animation"
date:   2015-06-06 12:42:26
categories: jekyll update
---

UITabBarController - tab切换使用动画
----------------------------------
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

A more complex solution, but gives you more control of the animation. In this example we get the views to slide on and off. With this one we need to manage the views ourselves.

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

UIButton - state 切换使用动画
------------------------------
    for (UIButton* btn in self.topButtons) {
        [UIView transitionWithView:btn
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{ btn.selected = NO; }
                        completion:nil];
    }
    if (index < self.topButtons.count) {
        UIButton* button = self.topButtons[index];
        [UIView transitionWithView:button
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{ button.selected = YES; }
                        completion:nil];
    }



[jekyll]:      http://jekyllrb.com
[jekyll-gh]:   https://github.com/jekyll/jekyll
[jekyll-help]: https://github.com/jekyll/jekyll-help
