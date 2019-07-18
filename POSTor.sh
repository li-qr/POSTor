#!/bin/bash

help () 
{
 echo -e 'usage:
  POSTor config -e default-environment.sh'
}

config ()
{
	shift
  case $1 in
    -f | --default-env) echo "default" ;;
    *) help ;;
  esac
}


#main ##################
if [ ! -n "$1" ]
then
	help
else
while [ -n "$1" ]
do
case $1 in
	-h | --help) help ;;
	config) 
		config $@ 
		shift $# ;;
	*) help ;;
esac
shift
done
fi
#main end##############
