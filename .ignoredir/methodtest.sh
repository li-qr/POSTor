#!/bin/bash


function a() {
	echo "$1"
}
export -f a

function b() {
  echo "sdf" |	xargs -I {} bash -c "$1 \"{}\""
}

b a
