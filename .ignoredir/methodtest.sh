#!/bin/bash


function a() {
	echo "$1"
}
export -f a

function b() {
  $1 sdf
}

b a
