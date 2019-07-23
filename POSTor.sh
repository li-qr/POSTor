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

function curll
{
	local cmd="curl"
	if [ -n "$header" ];then
	  cmd="$cmd -H $header"
	fi
	if [ -n "$method" ];then
		cmd="$cmd -X $method"
	fi 
	if [ -n "$request" ];then
	  cmd="$cmd -d '$request'"
	fi
	if [ -n "$url" ];then
		cmd="$cmd $url"
	else
		echo "no url"
		exit 1
	fi
		
	$cmd
}

function sourceenv
{
	source "$scriptdir$requestdir/$1"
	curll
}

function dealbasic
{
	local var1=0
	for var2 in $(find "$scriptdir$requestdir" -name $(echo $1 | sed -e 's/./*&/g' -e 's/$/&*/g'))
	do
		local files[$var1]=${var2:${#scriptdir}+${#requestdir}+1}
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
					sourceenv ${files[$REPLY-1]}
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
