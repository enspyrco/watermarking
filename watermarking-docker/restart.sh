docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker rmi wm4
docker build -t wm4 .
docker run wm4
