# expected arguments are: 'file path', 'image name', 'message', marking strength' 

gsutil cp "$1" "/tmp/$2" # 

./mark-image "/tmp/$2" $2 $3 $4 


