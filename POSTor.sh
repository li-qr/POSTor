#!/bin/bash
envdir="/enviroments"
hisdir="/histories"
requestdir="/requests"
currdir=$(pwd)
scriptdir=$(cd $(dirname $0);pwd)
$(cd $currdir)



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

function dealbasic
{
	local var1=0
	for var2 in $(find "$scriptdir$requestdir" -name $(echo $1 | sed -e 's/./*&/g' -e 's/$/&*/g'))
	do
		local files[$var1]=$(basename "$var2")
		 (( var1++ ))
	done
  if [ ${#files[@]} -eq 0 ] ;then
		echo "没有找到匹配请求"; exit 0
	elif [ ${#files[@]} -eq 1 ] ;then
		echo ${files[0]}
	elif [ ${#files[@]} -ge 2 ];then
		PS3="选择一个请求处理："
		select option in ${files[*]}
		do
			if [ $REPLY -gt 0 ] 2>/dev/null ;then 
  			if [ $REPLY -le ${#files[@]} ];then
					echo ${files[$REPLY-1]}
				 break;
				fi
			fi
			echo "输入编号"
		done
	fi
}

#main ##################

if [ -f "$scriptdir$envdir/default.sh" ]
then
  source "$scriptdir$envdir/default.sh"
fi

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
	 dealbasic $@
    shift $#	;;
esac
shift
done
fi
#main end##############
