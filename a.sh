#!/bin/bash
a="dd"
var="echo sdf"
if [ 2 -gt 1 ];then
	var=$var$a
fi
$var
