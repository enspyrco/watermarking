docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker rmi wm3
docker build -t wm3 .
docker run wm3
