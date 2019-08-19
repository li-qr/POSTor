function t2() {
	. ./test2.sh
	echo "ad"$address	
}


t2 &
sleep 1
echo "sd"$address
