#!/bin/bash
url="http://$address:8314/member/isOldMember"
method="POST"
header="content-type:application/json"
request='{
"cardNo": 18000
}'
