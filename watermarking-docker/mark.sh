# expected arguments are: 'file path', 'image name', 'message', marking strength', 'user id'
# $1 = file path 
# $2 = image name 
# $3 = message 
# $4 = strength 
# $5 = uid 
# $6 = timestamp 

gsutil cp "gs://watermarking-print-and-scan.appspot.com/$1" "/tmp/$2" 

./mark-image "/tmp/$2" $2 $3 $4 

gsutil cp $2.png "gs://watermarking-print-and-scan.appspot.com/marked-images/$5/$6/$2.png"
