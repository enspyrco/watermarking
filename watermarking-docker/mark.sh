# $1 = file path 
# $2 = image name 
# $3 = message 
# $4 = strength 
# $5 = uid 

gsutil cp $1 ./temp/$2 

./mark-image ./temp/$2 $3 $4 

gsutil $2.png gs://watermarking-print-and-scan.appspot.com/marked-images/$5
