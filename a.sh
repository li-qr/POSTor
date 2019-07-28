#!/bin/bash
#>&2 vim n.txt < 'EOF
#echo "sdfsdf" | tee a.txt -a b.txt
#echo "sdfdsfds" | tee 1>&/dev/null c.txt d.txt
#echo "nnn" | tee a.txt | tee -a b.txt 1>/dev/null
cd /Users/user/Documents/script/POSTor/histories
t=`find . -name "*-his.sh" | sort -t '-' -nrk 1.3`
tt=${t:2:6}
(( tt++ ))
echo $tt
