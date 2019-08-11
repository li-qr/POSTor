#!/bin/bash
silent=""

currdir=$(pwd)
scriptdir=$(
    cd $(dirname $0)
    pwd
)
$(cd $currdir)
envdir="$scriptdir/enviroments"
hisdir="$scriptdir/histories"
hisfile="$hisdir/history"
lastfile="$scriptdir/last"
requestdir="$scriptdir/requests"

function help() {
    echo -e 'usage:
    POSTor config -e default-environment.sh'
}

function executeall() {
    local valid=("vim" "less" "tail" "more" "cat")
    for cmd in ${valid[*]}; do
        if [ "$1" = "$cmd" ]; then
            local var1="1"
            local var2=$1
            shift
            echo $* | xargs >&2 -o $var2
        fi
    done
    if [ -z $var1 ]; then
        echo "unsupported command $1"
        exit 1
    fi
}

function configuration() {
    case $1 in
    defaultenv)
        if [ -n "$2" ] && [ "$2"="-e" ]; then
            executeall vim "$envdir/default.sh"
        else
            executeall less "$envdir/default.sh"
        fi
        ;;
    list)
        if [ -n $2 ] && [ $2 = "--more" ]; then
            local more="1"
        fi
        var2=""
        for var1 in "$envdir"/*; do
            var2="$var2$var1\n"
            if [ -n $more ]; then
                while read var0; do
                    if [ ! ${var0:0:1} = "#" ]; then
                        var2="$var2\t${var0:7}\n"
                    fi
                done <$var1
            fi
        done
        echo -e $var2
        ;;
    *) help ;;
    esac
}
function puthis() {
    cd "$hisdir"
    local fs=$(find . -name "*-his.sh" | sort -t '-' -nrk 1.3)
    if [ -n "$fs" ]; then
        local fsl=${fs:2:6}
        ((fsl++))
    else
        local fsl=000000
    fi
    cd $currdir
    local his1="\n##$(printf "%06d" $fsl)######"$(date)"############\n"
    local his2="#!/bin/bash"
    if [ -n "$method" ]; then
        his1="$his1\nmethod: $method"
        his2="$his2\nmethod=\"$method\""
    fi
    if [ -n "$url" ]; then
        his1="$his1\nurl: $url"
        his2="$his2\nurl=\"$url\""
    fi
    if [ -n "$header" ]; then
        his1="$his1\nheader:$header"
        his2="$his2\nheader=\"$header\""
    fi
    if [ -n "$request" ]; then
        his1="$his1\nrequest:\n$request"
        his2="$his2\nrequest='$request'"
    fi
    if [ -n "$response"]; then
        his1="$his1\nresponse:\n$1"
    fi
    echo -e "$his1" >>"$hisfile"
    echo -e "$his2" >"$hisdir/$(printf "%06d" $fsl)-his.sh"
}

function putlast() {
    echo "$1" | tee "$lastfile"
    vim >&2 $lastfile
}

function curlbox() {
    local cmd=()
    local i=0
    if [ -n "$silent" ]; then
        cmd[i]="-s"
        ((i++))
    fi
    if [ -n "$header" ]; then
        cmd[i]="-H"
        ((i++))
        cmd[i]="$header"
        ((i++))
    fi
    if [ -n "$method" ]; then
        cmd[i]="-X"
        ((i++))
        cmd[i]="$method"
        ((i++))
    fi
    if [ -n "$request" ]; then
        cmd[i]="-d"
        ((i++))
        cmd[i]="$request"
        ((i++))
    fi
    if [ -n "$url" ]; then
        cmd[i]="$url"
    else
        echo "no url"
        exit 1
    fi
    local tres=$(curl "${cmd[@]}")
    putlast $tres
    puthis $tres
}

function sourceenv() {
    source "$requestdir/$1"
}

function dealbasic() {
    local var1=0
    for var2 in $(find "$requestdir" -name $(echo $1 | sed -e 's/./*&/g' -e 's/$/&*/g')); do
        local files[$var1]=${var2:${#requestdir}+1}
        ((var1++))
    done
    if [ ${#files[@]} -eq 0 ]; then
        echo "没有找到匹配请求"
        exit 0
    elif [ ${#files[@]} -eq 1 ]; then
        echo ${files[0]}
    elif [ ${#files[@]} -ge 2 ]; then
        PS3="选择一个请求处理："
        select option in ${files[*]}; do
            if [ $REPLY -gt 0 ] 2>/dev/null; then
                if [ $REPLY -le ${#files[@]} ]; then
                    sourceenv ${files[$REPLY - 1]}
                    curlbox
                    break
                fi
            fi
            echo "输入编号"
        done
    fi
}

function single() {
    while [ -n "$1" ]; do
        case $1 in
        -s | --silent)
            silent="1"
            shift
            ;;
        *)
            dealbasic $@
            shift $#
            ;;
        esac
    done
}

function last() {
    if [ -z $1 ] || [ "$1" = "--vim" ]; then
        echo "1 $1"
        vim >&2 $lastfile
    elif [ "$1" = "--less" ]; then
        echo "2 $1"
        less >&2 $lastfile
    fi
}

function histories() {
    if [ -z $1 ] || [ "$1" = "--vim" ]; then
        vim >&2 $hisfile
    elif [ "$1" = "--less" ]; then
        less >&2 $hisfile
    elif [ "$1" = "--tail" ]; then
        echo ""
    fi
    if [ ! "$1" -gt 0 ] 2>/dev/null; then
        echo "请输入历史编号"
    else
        if [ -e "$hisdir/$(printf "%06d" $1)-his.sh" ]; then
            sourceenv "../histories/$(printf "%06d" $1)-his.sh"
            curlbox
        else
            echo "历史$(printf "%06d" $1)-his.sh不存在"
        fi
    fi
}

#main ##################

if [ -f "$envdir/default.sh" ]; then
    source "$envdir/default.sh"
fi

if [ ! -n "$1" ]; then
    help
else
    while [ -n "$1" ]; do
        case $1 in
        -h | --help) help ;;
        config)
            shift
            configuration $@
            shift $#
            ;;
        single)
            shift
            single $@
            shift $#
            ;;
        last)
            shift
            last $@
            shift $#
            ;;
        his)
            shift
            histories $@
            shift $#
            ;;
        *)
            help
            ;;
        esac
        shift
    done
fi
#main end##############
