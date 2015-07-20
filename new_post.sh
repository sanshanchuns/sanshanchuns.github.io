#!/bin/sh

now=`date +%Y-%m-%d`
now_time=`date +%Y-%m-%d-%H:%M:%S`
file_name="./_posts/$now-$1.markdown"
touch $file_name
echo "---
layout: post
title:  $1
date:   $now_time
categories: jekyll update
---" > $file_name
