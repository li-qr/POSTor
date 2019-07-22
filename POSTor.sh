#!/bin/bash
scriptdir=
echo $0
echo $(basename $0)
echo $(dirname $0)

function help
{
 echo -e 'usage:
  POSTor config -e default-environment.sh'
}

function configuration
{
	shift
  case $1 in
    -f | --default-env) echo "default" ;;
    *) help ;;
  esac
}

function deal
{
  
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
		configuration $@ 
		shift $# ;;
	*)
	 deal $@
    shift $#	;;
esac
shift
done
fi
#main end##############
