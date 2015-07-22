---
layout: post
title:  iOS-sensor
date:   2015-07-22-18:21:20
categories: jekyll update
---

#### 1. 距离传感器

	[[UIDevice currentDevice] setProximityMonitoringEnabled:YES]; //default is NO

	[[NSNotificationCenter defaultCenter] addObserver:self
	                                         selector:@selector(didSensorStateChanged:)
	                                             name:@"UIDeviceProximityStateDidChangeNotification"
	                                           object:nil];

	#pragma mark - UIDeviceProximityStateDidChangeNotification
	-(void)didSensorStateChanged:(NSNotificationCenter *)notification{
	    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电）
	    if ([[UIDevice currentDevice] proximityState] == YES){
	        NSLog(@"Device is close to user");
	        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];  //听筒
	    }else{
	        NSLog(@"Device is not close to user");
	        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];  //扬声器
	    }
	}


[jekyll]:      http://jekyllrb.com
[jekyll-gh]:   https://github.com/jekyll/jekyll
[jekyll-help]: https://github.com/jekyll/jekyll-help
